#!/bin/bash

# Enhanced Root Hiding Module Build Script

echo "Building Enhanced Root Hiding Module..."

# Set up variables
MODULE_ID="enhanced-root-hiding"
MODULE_VERSION="v1.0.0"
OUTPUT_DIR="./module/release"
TEMPLATE_DIR="./module/template"
WEBROOT_DIR="./webroot"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Copy webroot files to template directory
echo "Copying webroot files to template directory..."
mkdir -p "$TEMPLATE_DIR/webroot"
cp -r "$WEBROOT_DIR"/* "$TEMPLATE_DIR/webroot/"

# Create the module zip file
echo "Creating module zip file..."
cd "$TEMPLATE_DIR"
zip -r "$OUTPUT_DIR/$MODULE_ID-$MODULE_VERSION.zip" ./*
cd -

echo "Build completed!"
echo "Module zip file created at: $OUTPUT_DIR/$MODULE_ID-$MODULE_VERSION.zip"

# Check if adb is available for installation
if command -v adb &> /dev/null; then
    echo ""
    echo "Would you like to install the module on your device? (y/n)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "Pushing module to device..."
        adb push "$OUTPUT_DIR/$MODULE_ID-$MODULE_VERSION.zip" /sdcard/
        echo "Installing module via Magisk..."
        adb shell "su -c 'magisk --install-module /sdcard/$MODULE_ID-$MODULE_VERSION.zip'"
        echo "Would you like to reboot the device now? (y/n)"
        read -r reboot_response
        if [[ "$reboot_response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            echo "Rebooting device..."
            adb shell "su -c 'reboot'"
        else
            echo "Please reboot your device manually to activate the module."
        fi
    fi
fi
