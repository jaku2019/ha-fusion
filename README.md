# A ha-fusion enhanced fork

A modern, easy-to-use and performant custom [Home Assistant](https://www.home-assistant.io/) dashboard with enhanced features

<https://www.youtube.com/watch?v=D8mWruSuPOM>

[![preview](/static/preview.png)](https://www.youtube.com/watch?v=D8mWruSuPOM)

## 🚀 Enhanced Fork

This is an enhanced fork of the original [ha-fusion](https://github.com/matt8707/ha-fusion) project by matt8707, featuring additional components and improvements:

### ✨ New Features Added

#### 📊 Graph Component Integration
- **Dashboard Graphs**: Add interactive line charts as main dashboard items
- **Entity Visualization**: Display sensor history with customizable time ranges (1-168 hours)
- **Real-time Configuration**: Live color customization with stroke and fill options
- **Responsive Design**: 2:1 aspect ratio that matches rectangular button layout
- **Smart Sizing**: Automatically spans 2 grid columns for optimal data display

#### 🔄 Enhanced Binary Sensor Component
- **Custom Text Values**: Display meaningful text instead of "On"/"Off" (e.g., "Open"/"Closed", "Detected"/"Clear")
- **Smart Icon Detection**: Automatic icon suggestions based on entity type (doors, motion, contact sensors)
- **Flexible Configuration**: Separate icons for on/off states with prefix/suffix text support
- **Intuitive Setup**: Easy configuration through dedicated modal interface

### 🛠 Technical Improvements
- **TypeScript Enhancement**: Full type safety for new components
- **Demo Integration**: Works seamlessly with demo entities for development
- **Configuration Flow**: Consistent patterns following existing HA-Fusion architecture
- **Documentation**: Comprehensive implementation guides and usage examples

### 📚 Documentation
- [Graph and Binary Sensor Implementation Guide](docs/graph-and-binary-sensor-implementation.md)
- [Modernization Progress](docs/modernization-progress.md)
- [Recent Implementation Summary](docs/recent-implementation-summary.md)

---

## 🌟 Credits

**Original Project**: [ha-fusion](https://github.com/matt8707/ha-fusion) by [matt8707](https://github.com/matt8707)  
**Enhanced Fork**: [bogdanbotezatu/ha-fusion](https://github.com/bogdanbotezatu/ha-fusion)

If you find the original project useful, be sure to 🌟 the [original repository](https://github.com/matt8707/ha-fusion)! If you love it, please consider donating to the original author! ❤️ <https://www.paypal.com/paypalme/matt8707>

---

## 📣 Pre-beta

The current state of this project is **pre-beta**. This means that there's basic functionality missing, incomplete features and unresolved issues. General feedback, bug reports and feature requests are welcome!

---

## Installation

### 🔧 Enhanced Fork Installation

This enhanced fork can be installed using Docker. The original add-on installation method is not available for this fork.

### Docker

Install this enhanced version of ha-fusion via Docker:

1. **Docker Compose File**: Create a docker-compose.yml file using this enhanced version:

   ```yaml
   version: '3.8'
   services:
     ha-fusion:
       image: ghcr.io/bogdanbotezatu/ha-fusion:latest
       container_name: ha-fusion
       ports:
         - "5050:5050"
       volumes:
         - ./data:/app/data
       environment:
         - TZ=Europe/Stockholm
         - HASS_URL=http://192.168.1.241:8123
       restart: unless-stopped
   ```

2. **Create Container**:
   Run the following commands in your terminal to start the container:

   ```bash
   cd path/to/docker-compose.yml
   docker-compose up -d ha-fusion
   ```

#### Update

To update to the latest version of this enhanced fork, run:

```bash
docker-compose pull ha-fusion
docker-compose up -d ha-fusion
```

#### Manual Docker Run

Alternatively, you can run the container directly:

```bash
docker run -d \
  --name ha-fusion \
  --network bridge \
  -p 5050:5050 \
  -v /path/to/ha-fusion:/app/data \
  -e TZ=Europe/Stockholm \
  -e HASS_URL=http://192.168.1.241:8123 \
  --restart always \
  ghcr.io/bogdanbotezatu/ha-fusion:latest
```

### 📦 Original Installation

For the original ha-fusion with add-on support, visit: <https://github.com/matt8707/ha-fusion>

---

## 🎯 Using Enhanced Features

### 📊 Graph Component

1. **Add to Dashboard**: Click the "+" button in the main dashboard area
2. **Select Graph**: Choose "Graph" from the available component options
3. **Configure**:
   - Select a sensor entity (temperature, energy, etc.)
   - Set time range (1-168 hours)
   - Customize stroke and fill colors
   - Preview updates in real-time
4. **Save**: Graph appears on dashboard with 2:1 aspect ratio

### 🔄 Binary Sensor Component

1. **Add to Sidebar**: Click the gear icon in the sidebar, then "+"
2. **Select Binary Sensor**: Choose "Binary Sensor" from available options
3. **Configure**:
   - Select binary sensor entity (door, motion, contact, etc.)
   - Set custom on/off text (e.g., "Open"/"Closed")
   - Add prefix/suffix text if desired
   - Choose custom icons for each state
   - Use suggested icons based on entity type
4. **Save**: Sidebar displays meaningful status text instead of generic "On"/"Off"

#### Binary Sensor Examples

| Entity Type | On Value | Off Value | Result |
|-------------|----------|-----------|---------|
| Door Contact | "Open" | "Closed" | Shows "Open" when door is open |
| Motion Sensor | "Motion Detected" | "No Motion" | Clear motion status |
| Occupancy | "Occupied" | "Empty" | Room occupancy status |

---

## Query strings

These will only function if you have exposed a port in the add-on configuration or by using Docker. Note that when using Ingress, query strings cannot be read.

### View

To set a particular view when the page loads, add the "view" parameter. For example, if you have a "Bedroom" view, append the query string `?view=Bedroom` to the URL.

### Menu

To disable the menu button, append the query string `?menu=false` to the URL. This is useful when you want to avoid unwanted changes to your dashboard, such as on wall-mounted tablets.

---

## Keyboard Shortcuts

| Key                 | Description |
| ------------------- | ----------- |
| **f**               | filter      |
| **esc**             | exit        |
| **cmd + s**         | save        |
| **cmd + z**         | undo        |
| **cmd + shift + z** | redo        |

---

## Debug

To debug any errors, check the "Log" tab if you're using the addon, or use `docker logs ha-fusion` for Docker setups. To inspect frontend issues, open the browser's console.

---

## Develop

To begin contributing to this enhanced fork, you'll first need to install node. It's also recommended to install pnpm. If you're unfamiliar with Svelte, consider doing the tutorial at <https://learn.svelte.dev>

```bash
# prerequisites (macos)
brew install node pnpm

# install this enhanced fork
git clone https://github.com/bogdanbotezatu/ha-fusion.git
cd ha-fusion
pnpm install

# environment
cp .env.example .env
code .env

# server
npm run dev -- --open

# dependencies
pnpm outdated
pnpm update

# lint
npm run check
npm run lint
npm run format
```

### 🔧 Enhanced Features Development

When working with the new features:

#### Graph Component
- Source: `src/lib/Dashboard/Graph.svelte`
- Config: `src/lib/Modal/DashboardGraphConfig.svelte`
- Integration: Added to `src/lib/Modal/MainItemConfig.svelte`

#### Binary Sensor Component
- Source: `src/lib/Sidebar/BinarySensor.svelte`
- Config: `src/lib/Modal/BinarySensorConfig.svelte`
- Integration: Added to `src/lib/Modal/SidebarItemConfig.svelte`

#### Development Guidelines
- Follow existing TypeScript patterns
- Maintain consistency with current component architecture
- Add comprehensive demo entity support
- Include proper error handling and fallbacks
- Update documentation for new features

### 📖 Documentation

See the [docs](docs/) folder for comprehensive implementation guides:
- [Graph and Binary Sensor Implementation](docs/graph-and-binary-sensor-implementation.md)
- [Modernization Progress](docs/modernization-progress.md)
- [Implementation Summary](docs/recent-implementation-summary.md)

---

## 🤝 Contributing

This fork welcomes contributions! Please ensure:
- New features follow existing patterns
- Components include proper TypeScript definitions
- Demo entities are supported for development
- Documentation is updated for significant changes
- Code passes linting and type checking

## 📄 License

Same license as the original ha-fusion project. See the original repository for license details.
