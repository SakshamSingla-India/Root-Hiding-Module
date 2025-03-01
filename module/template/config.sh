#!/system/bin/sh
# Enhanced Root Hiding Configuration Script

# This script manages the configuration files for the Enhanced Root Hiding module

MODDIR=${0%/*}
CONFIG_DIR="/data/adb/enhanced-root-hiding/config"
LOG_DIR="/data/adb/enhanced-root-hiding/logs"
TRICKY_STORE_DIR="/data/adb/tricky_store"

# Function to create default configuration if it doesn't exist
create_default_config() {
  # Create directories if they don't exist
  mkdir -p "$CONFIG_DIR"
  mkdir -p "$LOG_DIR"
  mkdir -p "$TRICKY_STORE_DIR"
  
  # Create default hidden apps list if it doesn't exist
  if [ ! -f "$CONFIG_DIR/hidden_apps.txt" ]; then
    touch "$CONFIG_DIR/hidden_apps.txt"
  fi
  
  # Create default settings file if it doesn't exist
  if [ ! -f "$CONFIG_DIR/settings.conf" ]; then
    echo "# Enhanced Root Hiding Settings" > "$CONFIG_DIR/settings.conf"
    echo "use_shamiko=true" >> "$CONFIG_DIR/settings.conf"
    echo "use_tricky_store=true" >> "$CONFIG_DIR/settings.conf"
    echo "use_zygisk=true" >> "$CONFIG_DIR/settings.conf"
    echo "use_zygisk_next=true" >> "$CONFIG_DIR/settings.conf"
    echo "whitelist_mode=false" >> "$CONFIG_DIR/settings.conf"
    echo "security_patch_level=2025-03-01" >> "$CONFIG_DIR/settings.conf"
    echo "# Anti-detection settings" >> "$CONFIG_DIR/settings.conf"
    echo "hide_magiskpolicy=true" >> "$CONFIG_DIR/settings.conf"
    echo "hide_su_binary=true" >> "$CONFIG_DIR/settings.conf"
    echo "hide_magisk_modules=true" >> "$CONFIG_DIR/settings.conf"
    echo "fix_mount_inconsistency=true" >> "$CONFIG_DIR/settings.conf"
    echo "hide_lsposed=true" >> "$CONFIG_DIR/settings.conf"
    echo "hide_lineageos=true" >> "$CONFIG_DIR/settings.conf"
  fi
  
  # Create default TrickyStore target file if it doesn't exist
  if [ ! -f "$TRICKY_STORE_DIR/target.txt" ]; then
    echo "2025-03-01" > "$TRICKY_STORE_DIR/target.txt"
  fi
}

# Function to load settings
load_settings() {
  if [ -f "$CONFIG_DIR/settings.conf" ]; then
    # Source the settings file
    . "$CONFIG_DIR/settings.conf"
    
    # Update TrickyStore target if needed
    if [ "$use_tricky_store" = "true" ] && [ -n "$security_patch_level" ]; then
      echo "$security_patch_level" > "$TRICKY_STORE_DIR/target.txt"
    fi
    
    # Configure Shamiko if needed
    if [ "$use_shamiko" = "true" ] && [ -d "/data/adb/modules/shamiko" ]; then
      # Ensure denylist enforcement is disabled for Shamiko to work
      magisk --denylist disable
    fi
    
    # Log the settings
    echo "Enhanced Root Hiding settings loaded at $(date)" > "$LOG_DIR/settings.log"
    echo "use_shamiko=$use_shamiko" >> "$LOG_DIR/settings.log"
    echo "use_tricky_store=$use_tricky_store" >> "$LOG_DIR/settings.log"
    echo "use_zygisk=$use_zygisk" >> "$LOG_DIR/settings.log"
    echo "whitelist_mode=$whitelist_mode" >> "$LOG_DIR/settings.log"
    echo "security_patch_level=$security_patch_level" >> "$LOG_DIR/settings.log"
  fi
}

# Create default configuration
create_default_config

# Load settings
load_settings

# Exit with success
exit 0
