#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
set -e

bashio::log.info "Starting HA Fusion..."

# Get configuration
HASS_URL=$(bashio::config 'hass_url')

# Set environment variables
export ADDON=true
export PORT=5050
export NODE_ENV=production

# Ingress configuration
if bashio::var.has_value "${HASS_URL}"; then
    export HASS_URL="${HASS_URL}"
    bashio::log.info "Using configured HASS_URL: ${HASS_URL}"
else
    # Use ingress if no URL is configured
    bashio::log.info "Using Ingress mode (no HASS_URL configured)"
fi

# Get Home Assistant ports for proxy configuration
export INGRESS_PORT=5050
if EXPOSED_PORT_TMP=$(bashio::addon.port 5050 2>/dev/null); then
    export EXPOSED_PORT="${EXPOSED_PORT_TMP}"
else
    export EXPOSED_PORT=""
    bashio::log.debug "No external port configured (Ingress mode only)"
fi
export HASS_PORT=8123

bashio::log.info "Configuration:"
bashio::log.info "  ADDON: ${ADDON}"
bashio::log.info "  INGRESS_PORT: ${INGRESS_PORT}"
bashio::log.info "  EXPOSED_PORT: ${EXPOSED_PORT}"
bashio::log.info "  HASS_PORT: ${HASS_PORT}"

# Start the application
cd /app
bashio::log.info "Starting Node.js server..."
exec node server.js
