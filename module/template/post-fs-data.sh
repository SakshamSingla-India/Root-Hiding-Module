#!/system/bin/sh
# This script will be executed in post-fs-data mode

MODDIR=${0%/*}

# Create necessary directories
mkdir -p /data/adb/enhanced-root-hiding
mkdir -p /data/adb/enhanced-root-hiding/config
mkdir -p /data/adb/enhanced-root-hiding/logs

# Initialize the configuration file if it doesn't exist
if [ ! -f /data/adb/enhanced-root-hiding/config/hidden_apps.txt ]; then
  touch /data/adb/enhanced-root-hiding/config/hidden_apps.txt
fi

# Ensure Zygisk compatibility
if [ -d /data/adb/modules/zygisksu ]; then
  # For Zygisk Next compatibility
  echo "Setting up Zygisk Next compatibility" >> /data/adb/enhanced-root-hiding/logs/post-fs-data.log
  touch "$MODDIR/.zygisk-enabled"
else
  # For built-in Zygisk compatibility
  if [ -x "$(command -v magisk)" ] && magisk --path | grep -q "zygisk"; then
    echo "Setting up built-in Zygisk compatibility" >> /data/adb/enhanced-root-hiding/logs/post-fs-data.log
    touch "$MODDIR/.zygisk-enabled"
  fi
fi

# Log that post-fs-data script has run
echo "Enhanced Root Hiding post-fs-data executed at $(date)" > /data/adb/enhanced-root-hiding/logs/post-fs-data.log
