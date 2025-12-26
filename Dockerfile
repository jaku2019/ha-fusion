# first stage, can't use alpine for building armv7
FROM node:22 AS builder
WORKDIR /app

# copy all files
COPY . .

# install, build and prune
RUN npm install --verbose && \
  npm run build && \
  npm prune --omit=dev

# second stage - check if we're building for Home Assistant add-on or standalone
ARG BUILD_FROM
FROM ${BUILD_FROM:-node:22-alpine}
WORKDIR /app

# Install Node.js and npm for Home Assistant base images
RUN \
  if ! command -v node > /dev/null; then \
    apk add --no-cache \
      nodejs \
      npm; \
  fi

# Install bashio for Home Assistant add-on support
ARG BASHIO_VERSION=0.16.2
RUN \
  if [ -d /etc/services.d ]; then \
    apk add --no-cache \
      bash \
      curl \
      jq && \
    curl -L -s -o /tmp/bashio.tar.gz \
      "https://github.com/hassio-addons/bashio/archive/v${BASHIO_VERSION}.tar.gz" && \
    mkdir -p /tmp/bashio && \
    tar zxvf /tmp/bashio.tar.gz --strip 1 -C /tmp/bashio && \
    mv /tmp/bashio/lib /usr/lib/bashio && \
    ln -s /usr/lib/bashio/bashio /usr/bin/bashio && \
    rm -rf /tmp/bashio.tar.gz /tmp/bashio; \
  fi

# copy files to /app
COPY --from=builder /app/build ./build
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/server.js .
COPY --from=builder /app/package.json .

# Copy run script for Home Assistant add-on
COPY run.sh /
RUN chmod a+x /run.sh

# set environment
ENV PORT=5050 \
  NODE_ENV=production \
  ADDON=false

EXPOSE 5050

# Use run.sh if it exists (Home Assistant add-on), otherwise use node directly
CMD [ "/run.sh" ]
