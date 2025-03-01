#!/system/bin/sh
# This script will be executed in Magisk's installation process

MODDIR=${0%/*}

# Ensure Zygisk is enabled
if [ -z "$(magisk --path)" ]; then
  ui_print "- Magisk installation not found"
  abort "! Please install Magisk first"
fi

if ! magisk --path | grep -q "zygisk"; then
  ui_print "! Zygisk is not enabled"
  ui_print "! Please enable Zygisk in Magisk settings and reboot"
  abort
fi

# Create necessary directories
mkdir -p /data/adb/enhanced-root-hiding
mkdir -p /data/adb/enhanced-root-hiding/config
mkdir -p /data/adb/enhanced-root-hiding/logs
mkdir -p /data/adb/tricky_store

# Set proper permissions
set_perm_recursive $MODPATH 0 0 0755 0644
set_perm_recursive $MODPATH/webroot 0 0 0755 0644
set_perm $MODPATH/service.sh 0 0 0755
set_perm $MODPATH/post-fs-data.sh 0 0 0755

# Check if Shamiko is installed
if [ -d /data/adb/modules/shamiko ]; then
  ui_print "- Shamiko module detected"
  ui_print "- Ensuring Magisk denylist enforcement is disabled"
  magisk --denylist disable
else
  ui_print "! Shamiko module not detected"
  ui_print "- For best results, please install Shamiko module"
fi

# Check for Zygisk Next
if [ -d /data/adb/modules/zygisksu ]; then
  ui_print "- Zygisk Next module detected"
  ui_print "- Will use Zygisk Next for additional compatibility"
else
  ui_print "- Zygisk Next not detected"
  ui_print "- Using standard Zygisk implementation"
fi

# Copy Zygisk Next files if needed
if [ -f /data/adb/zygisksu/zygiskd ]; then
  ui_print "- Integrating with existing Zygisk Next installation"
fi

ui_print "- Installation completed"
ui_print "- Please reboot your device"
ui_print "- After reboot, access the web UI through KernelSU/Magisk manager"
