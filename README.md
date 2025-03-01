# Enhanced Root Hiding Module

![GitHub release (latest by date)](https://img.shields.io/github/v/release/saksham/enhanced-root-hiding)
![GitHub](https://img.shields.io/github/license/saksham/enhanced-root-hiding)
![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/saksham/enhanced-root-hiding/build.yml)

A comprehensive root hiding solution for Android that combines the power of Shamiko, TrickyStore, and Zygisk with an easy-to-use web UI.

## Features

- **Multi-layered Root Hiding**: Combines multiple technologies for maximum effectiveness
  - **Shamiko**: Hide Magisk root, Zygisk itself, and Zygisk modules
  - **TrickyStore**: Spoof device attestation for better SafetyNet/Play Integrity passing
  - **Zygisk**: Additional root hiding through Zygisk hooks
  - **Zygisk Next**: Support for standalone Zygisk implementation

- **Advanced Anti-Detection**:
  - Hide `/bin/magiskpolicy` from detection
  - Hide `/system/bin/su` binary
  - Hide Magisk modules like `liblspd.so`
  - Fix mount inconsistencies in `/proc/mounts`
  - Hide LSPosed detection
  - Hide LineageOS detection

- **User-Friendly Web UI**:
  - Select which apps to hide root from
  - Configure all settings through a clean interface
  - Save and restore configurations

- **Flexible Configuration**:
  - Whitelist mode (only allow selected apps to access root)
  - Customize security patch level for device attestation

## Requirements

- Magisk v24.0+ or KernelSU with Zygisk enabled
- Shamiko module (recommended for best results)
- Zygisk Next (optional, for better compatibility)

## Installation

### Via Magisk/KernelSU Manager
1. Download the latest release from [GitHub Releases](https://github.com/saksham/enhanced-root-hiding/releases)
2. Install via Magisk/KernelSU Manager
3. Reboot your device
4. Access the web UI through Magisk/KernelSU Manager

### Manual Installation
1. Download the latest release
2. Extract the zip file
3. Copy the extracted files to `/data/adb/modules/enhanced-root-hiding`
4. Set proper permissions: `chmod -R 755 /data/adb/modules/enhanced-root-hiding`
5. Reboot your device

## Usage

### Hiding Root from Apps

1. Open the web UI from Magisk/KernelSU Manager
2. Go to the "Apps" tab
3. Select the apps you want to hide root from
4. Click "Save Configuration"

### Settings

- **Shamiko**: Enable/disable Shamiko integration
- **TrickyStore**: Enable/disable TrickyStore integration
- **Zygisk Module**: Enable/disable additional Zygisk hooks
- **Zygisk Next**: Use Zygisk Next implementation for better compatibility
- **Whitelist Mode**: Only allow selected apps to access root
- **Security Patch Level**: Customize the security patch level for device attestation

### Anti-Detection Settings

- **Hide Magisk Policy**: Hide `/bin/magiskpolicy` from detection
- **Hide SU Binary**: Hide `/system/bin/su` from detection
- **Hide Magisk Modules**: Hide detectable module files like `liblspd.so`
- **Fix Mount Inconsistency**: Hide mount inconsistencies in `/proc/mounts`
- **Hide LSPosed**: Hide LSPosed detection
- **Hide LineageOS**: Hide LineageOS detection

## Building from Source

### Prerequisites
- JDK 17+
- Android NDK
- Git

### Build Steps
1. Clone the repository:
   ```bash
   git clone https://github.com/saksham/enhanced-root-hiding.git
   cd enhanced-root-hiding
   ```

2. Build the module:
   ```bash
   ./gradlew build
   ```

3. Create the module zip:
   ```bash
   ./build.sh
   ```

The module zip will be available in `module/release/enhanced-root-hiding-v1.0.0.zip`.

## Troubleshooting

### Common Issues

1. **Apps still detect root**
   - Make sure all three components (Shamiko, TrickyStore, and Zygisk) are enabled
   - Try enabling all anti-detection settings
   - Some apps use multiple detection methods; you may need to try different combinations of settings

2. **Web UI not loading**
   - Make sure busybox is installed
   - Check the logs at `/data/adb/enhanced-root-hiding/logs/webui.log`

3. **Module not working after update**
   - Clear Magisk/KernelSU cache
   - Reboot your device
   - Reinstall the module if necessary

### Logs

Logs are stored in `/data/adb/enhanced-root-hiding/logs/`:
- `webui.log`: Web UI server logs
- `anti_detection.log`: Anti-detection script logs
- `post-fs-data.log`: Module initialization logs

## Credits

- Shamiko developers
- TrickyStore by 5ec1cff
- Zygisk Next by 5ec1cff and Nullptr
- KernelSU team for the WebUI API

## License

This module is provided under the GPL-3.0 License.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request
