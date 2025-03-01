#!/system/bin/sh
# This script will be executed in Magisk's installation process

MODDIR=${0%/*}

# Check for Zygisk availability (either built-in or Zygisk Next)
check_zygisk() {
  local ZYGISK_MODULE="/data/adb/modules/zygisksu"
  local MAGISK_DIR="/data/adb/magisk"
  local ZYGISK_MSG="Zygisk is not enabled. Please either:
  - Enable Zygisk in Magisk settings
  - Install ZygiskNext module"

  # Check if Zygisk Next module directory exists
  if [ -d "$ZYGISK_MODULE" ]; then
    ui_print "- Zygisk Next detected"
    return 0
  fi

  # If Magisk is installed, check Zygisk settings
  if [ -d "$MAGISK_DIR" ]; then
    # Check if Zygisk is enabled in Magisk
    if magisk --path | grep -q "zygisk"; then
      ui_print "- Magisk Zygisk detected"
      return 0
    else
      ui_print "$ZYGISK_MSG"
      abort
    fi
  else
    ui_print "- Magisk installation not found"
    ui_print "- Checking for alternative root solutions..."
    
    # Check for KernelSU with Zygisk Next
    if [ -d "$ZYGISK_MODULE" ]; then
      ui_print "- KernelSU with Zygisk Next detected"
      return 0
    else
      ui_print "$ZYGISK_MSG"
      abort
    fi
  fi
}

# Verify Zygisk availability
check_zygisk

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

# Configure for the detected Zygisk implementation
if [ -d /data/adb/modules/zygisksu ]; then
  ui_print "- Configuring for Zygisk Next compatibility"
  # Create symbolic links or copy necessary files if needed
  if [ -f /data/adb/zygisksu/zygiskd ]; then
    ui_print "- Integrating with existing Zygisk Next installation"
  fi
else
  # Check if standard Magisk Zygisk is enabled
  if magisk --path | grep -q "zygisk"; then
    ui_print "- Configuring for standard Magisk Zygisk"
    # Ensure compatibility with built-in Zygisk
    touch "$MODPATH/.zygisk-enabled"
  fi
fi

ui_print "- Installation completed"
ui_print "- Please reboot your device"
ui_print "- After reboot, access the web UI through KernelSU/Magisk manager"
