# Enhanced Root Hiding Module

This module combines the functionality of Shamiko, TrickyStore, and Zygisk to provide comprehensive root hiding for Android applications.

## Features

- **Multi-layered Root Hiding**: Combines Shamiko, TrickyStore, and Zygisk for maximum effectiveness
- **Web UI**: User-friendly interface to manage root hiding settings
- **App Selection**: Select which apps to hide root from
- **Advanced Settings**: Customize security patch level and other settings
- **Whitelist Mode**: Option to only allow selected apps to access root

## Requirements

- Magisk v24.1+ or KernelSU with Zygisk enabled
- Shamiko module (recommended for best results)

## Installation

1. Install via Magisk/KernelSU Manager
2. Reboot your device
3. Access the web UI through Magisk/KernelSU Manager

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
- **Whitelist Mode**: Only allow selected apps to access root
- **Security Patch Level**: Customize the security patch level for device attestation

## Important Notes

- When using Shamiko, DO NOT enable Magisk's "Enforce DenyList" option
- For best results, use all three components (Shamiko, TrickyStore, and Zygisk)
- Some apps may still detect root despite using this module

## Credits

- Shamiko developers
- TrickyStore by 5ec1cff
- Zygisk module template by 5ec1cff
- KernelSU team for the WebUI API

## License

This module is provided under the GPL-3.0 License.
