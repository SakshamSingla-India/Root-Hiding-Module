#!/system/bin/sh
# This script will be executed when the module is uninstalled

# We'll keep the configuration files in case the user reinstalls
# But we'll clean up any temporary files
rm -rf /data/adb/enhanced-root-hiding/logs

# Log the uninstallation
echo "Enhanced Root Hiding module uninstalled at $(date)" > /data/adb/enhanced-root-hiding/uninstall.log

# Notify the user
ui_print "- Enhanced Root Hiding module has been uninstalled"
ui_print "- Your configuration files have been preserved in /data/adb/enhanced-root-hiding/"
ui_print "- Please reboot your device to complete the uninstallation"
