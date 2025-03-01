# Installation Guide

This guide will help you install and configure the Enhanced Root Hiding Module on your device.

## Prerequisites

- Magisk v24.0+ or KernelSU with Zygisk enabled
- Shamiko module (recommended for best results)
- Zygisk Next (optional, for better compatibility)

## Installation Methods

### Method 1: Via Magisk/KernelSU Manager

1. Download the latest release from [GitHub Releases](https://github.com/SakshamSingla-India/Root-Hiding-Module/releases)
2. Open Magisk/KernelSU Manager
3. Go to Modules section
4. Click on "Install from storage"
5. Select the downloaded zip file
6. Wait for installation to complete
7. Reboot your device

### Method 2: Manual Installation

1. Download the latest release from [GitHub Releases](https://github.com/SakshamSingla-India/Root-Hiding-Module/releases)
2. Extract the zip file
3. Using a root file explorer, copy the extracted files to `/data/adb/modules/enhanced-root-hiding`
4. Set proper permissions: `chmod -R 755 /data/adb/modules/enhanced-root-hiding`
5. Reboot your device

## First-Time Setup

1. After installation and reboot, open Magisk/KernelSU Manager
2. Go to Modules section
3. Find "Enhanced Root Hiding" and click on it
4. Click on "Manage" to open the web UI
5. Configure your settings:
   - Select which apps to hide root from
   - Enable/disable components as needed
   - Configure anti-detection settings

## Troubleshooting

### Module Not Working

1. Make sure Zygisk is enabled in Magisk/KernelSU settings
2. Make sure Denylist Enforcement is disabled (required for Shamiko)
3. Check if Shamiko module is installed and enabled
4. Reboot your device

### Web UI Not Loading

1. Make sure busybox is installed
2. Check the logs at `/data/adb/enhanced-root-hiding/logs/webui.log`
3. Try accessing the web UI through a different browser

### Apps Still Detecting Root

1. Make sure all three components (Shamiko, TrickyStore, and Zygisk) are enabled
2. Try enabling all anti-detection settings
3. Some apps use multiple detection methods; you may need to try different combinations of settings

## Updating

1. Download the latest release
2. Install using the same method as your initial installation
3. Reboot your device

Your settings will be preserved during updates.
