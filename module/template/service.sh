#!/system/bin/sh
# This script will be executed in late_start service mode

MODDIR=${0%/*}

# Create necessary directories for our module
mkdir -p /data/adb/enhanced-root-hiding
mkdir -p /data/adb/enhanced-root-hiding/logs
mkdir -p /data/adb/tricky_store

# Run the configuration script
sh $MODDIR/config.sh

# Run anti-detection script
sh $MODDIR/anti_detection.sh

# Start the web server for the UI
# We use busybox httpd for simplicity
BUSYBOX=$(which busybox)
if [ -n "$BUSYBOX" ]; then
  # Kill any existing httpd instance
  pkill -f "busybox httpd -p 8080"
  # Start httpd on port 8080 with webroot directory
  $BUSYBOX httpd -p 8080 -h $MODDIR/webroot
  echo "Web UI started on port 8080" > /data/adb/enhanced-root-hiding/logs/webui.log
else
  echo "Busybox not found, web UI not started" > /data/adb/enhanced-root-hiding/logs/webui.log
fi

# Set up Shamiko configuration
if [ -d /data/adb/modules/shamiko ]; then
  # Ensure denylist enforcement is disabled for Shamiko to work
  magisk --denylist disable
fi

# Log that our service has started
echo "Enhanced Root Hiding module started at $(date)" > /data/adb/enhanced-root-hiding/logs/service.log
