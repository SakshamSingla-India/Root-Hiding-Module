#!/bin/bash

# Enhanced Root Hiding Module Build Script

echo "Building Enhanced Root Hiding Module..."

# Set up variables
MODULE_ID="enhanced-root-hiding"
MODULE_VERSION="v1.0.0"
OUTPUT_DIR="module/release"
TEMPLATE_DIR="module/template"
WEBROOT_DIR="webroot"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Copy webroot files to template directory
echo "Copying webroot files to template directory..."
mkdir -p "$TEMPLATE_DIR/webroot"
cp -r "$WEBROOT_DIR"/* "$TEMPLATE_DIR/webroot/"

# Create the module zip file
echo "Creating module zip file..."
cd "$TEMPLATE_DIR"
zip -r "../../$OUTPUT_DIR/$MODULE_ID.zip" .
cd ../..

echo "Build completed!"
echo "Module zip file created at: $OUTPUT_DIR/$MODULE_ID.zip"
