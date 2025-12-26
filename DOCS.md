# HA Fusion Add-on Documentation

## About

HA Fusion is a modern, easy-to-use and performant custom Home Assistant dashboard with enhanced features.

## Installation

1. Add this repository to your Home Assistant add-ons:
   - Navigate to **Settings** → **Add-ons** → **Add-on Store**
   - Click the three dots menu (top right) and select **Repositories**
   - Add this repository URL
   - Click **Add**

2. Find "HA Fusion" in the add-on store and click **Install**

3. After installation, click **Start**

## Configuration

### Ingress (Recommended)

By default, this add-on uses Home Assistant Ingress, which provides:
- Seamless integration in Home Assistant's sidebar
- No need for port configuration
- Automatic authentication through Home Assistant

Simply start the add-on and access it through the sidebar or **Settings** → **Add-ons** → **HA Fusion** → **Open Web UI**.

### External Port Access (Optional)

If you want to access HA Fusion outside of Home Assistant's Ingress:

1. In the add-on configuration, set a port mapping:
   ```yaml
   ports:
     5050/tcp: 5050
   ```

2. Optionally configure the `hass_url` option if needed:
   ```yaml
   hass_url: http://homeassistant.local:8123
   ```

3. Save the configuration and restart the add-on

4. Access the dashboard at `http://your-ha-ip:5050`

### Configuration Options

#### Option: `hass_url` (optional)

The URL to your Home Assistant instance. This is typically only needed when running with an external port and in special network configurations.

Example:
```yaml
hass_url: http://192.168.1.100:8123
```

**Note:** When using Ingress (default), this option is not required as the add-on automatically detects your Home Assistant instance.

## Features

### Enhanced Fork Features

This enhanced fork includes:

#### 📊 Graph Component Integration
- Dashboard graphs with interactive line charts
- Entity visualization with customizable time ranges
- Real-time color customization
- Responsive 2:1 aspect ratio design

#### 🔄 Enhanced Binary Sensor Component
- Custom text values instead of "On"/"Off"
- Smart icon detection based on entity type
- Flexible configuration with prefix/suffix support
- Intuitive setup interface

### Using the Dashboard

1. **Access the Dashboard:**
   - Via Ingress: Click "HA Fusion" in the Home Assistant sidebar
   - Via Port: Navigate to `http://your-ha-ip:5050`

2. **Add Components:**
   - Click the "+" button to add dashboard items
   - Choose from various component types (Graph, Binary Sensor, etc.)
   - Configure and customize each component

3. **Customize Your View:**
   - Drag and drop to rearrange items
   - Click gear icons to modify settings
   - Create multiple views for different purposes

### Query Strings

When accessing via external port (not Ingress), you can use query strings:

#### View Parameter
Set a specific view on load:
```
http://your-ha-ip:5050/?view=Bedroom
```

#### Menu Parameter
Disable the menu button (useful for wall tablets):
```
http://your-ha-ip:5050/?menu=false
```

**Note:** Query strings do not work with Ingress access.

## Support

For issues, questions, or contributions:
- GitHub Issues: https://github.com/jaku2019/ha-fusion/issues
- Documentation: See the main [README.md](https://github.com/jaku2019/ha-fusion)

## Original Project

This is an enhanced fork of the original [ha-fusion](https://github.com/matt8707/ha-fusion) project by matt8707.

## License

Same license as the original ha-fusion project.
