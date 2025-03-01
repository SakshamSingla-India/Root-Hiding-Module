#!/system/bin/sh
# Enhanced Root Hiding Anti-Detection Script

MODDIR=${0%/*}
CONFIG_DIR="/data/adb/enhanced-root-hiding/config"
LOG_DIR="/data/adb/enhanced-root-hiding/logs"

# Create log file
LOGFILE="$LOG_DIR/anti_detection.log"
touch $LOGFILE
echo "Anti-detection script started at $(date)" > $LOGFILE

# Function to hide magiskpolicy binary
hide_magiskpolicy() {
  if [ -f /bin/magiskpolicy ]; then
    echo "Hiding /bin/magiskpolicy..." >> $LOGFILE
    
    # Create a mount namespace
    unshare -m sh -c "
      # Mount tmpfs over /bin to hide magiskpolicy
      mount -t tmpfs tmpfs /bin
      
      # Copy all binaries except magiskpolicy
      for file in /bin/*; do
        if [ \"\$(basename \$file)\" != \"magiskpolicy\" ]; then
          cp \$file /bin/
        fi
      done
      
      # Set proper permissions
      chmod 755 /bin/*
      
      # Keep the namespace alive
      while true; do
        sleep 60
      done
    " &
  fi
}

# Function to hide su binary
hide_su_binary() {
  if [ -f /system/bin/su ]; then
    echo "Hiding /system/bin/su..." >> $LOGFILE
    
    # Create a mount namespace
    unshare -m sh -c "
      # Mount tmpfs over /system/bin to hide su
      mount -t tmpfs tmpfs /system/bin
      
      # Copy all binaries except su
      for file in /system/bin/*; do
        if [ \"\$(basename \$file)\" != \"su\" ]; then
          cp \$file /system/bin/
        fi
      done
      
      # Set proper permissions
      chmod 755 /system/bin/*
      
      # Keep the namespace alive
      while true; do
        sleep 60
      done
    " &
  fi
}

# Function to hide Magisk modules
hide_magisk_modules() {
  echo "Hiding Magisk modules detection..." >> $LOGFILE
  
  # Hide liblspd.so and other detectable module files
  if [ -d /data/adb/modules ]; then
    # Create a mount namespace
    unshare -m sh -c "
      # Mount tmpfs over module directories that might be detected
      for module in /data/adb/modules/*; do
        if [ -d \"\$module\" ]; then
          # Hide specific files that might be detected
          for file in \"\$module\"/*.so \"\$module\"/*.jar; do
            if [ -f \"\$file\" ]; then
              filename=\$(basename \"\$file\")
              dirname=\$(dirname \"\$file\")
              mount -t tmpfs tmpfs \"\$file\"
            fi
          done
        fi
      done
      
      # Keep the namespace alive
      while true; do
        sleep 60
      done
    " &
  fi
}

# Function to fix mount inconsistency
fix_mount_inconsistency() {
  echo "Fixing mount inconsistency..." >> $LOGFILE
  
  # Create a fake /proc/mounts file to hide mount inconsistencies
  unshare -m sh -c "
    # Create a temporary file with clean mount entries
    cat /proc/mounts | grep -v magisk | grep -v lspd > /data/adb/enhanced-root-hiding/clean_mounts
    
    # Mount the clean file over /proc/mounts
    mount --bind /data/adb/enhanced-root-hiding/clean_mounts /proc/mounts
    
    # Keep the namespace alive
    while true; do
      sleep 60
    done
  " &
}

# Function to hide LSPosed detection
hide_lsposed() {
  echo "Hiding LSPosed detection..." >> $LOGFILE
  
  # Hide LSPosed-related files and processes
  if [ -d /data/adb/lspd ]; then
    unshare -m sh -c "
      # Mount tmpfs over LSPosed directory
      mount -t tmpfs tmpfs /data/adb/lspd
      
      # Keep the namespace alive
      while true; do
        sleep 60
      done
    " &
  fi
}

# Function to hide LineageOS detection
hide_lineageos() {
  echo "Hiding LineageOS detection..." >> $LOGFILE
  
  # Modify build.prop to hide LineageOS traces
  if grep -q "ro.lineage" /system/build.prop; then
    unshare -m sh -c "
      # Create a modified build.prop without LineageOS traces
      cat /system/build.prop | grep -v 'ro.lineage' > /data/adb/enhanced-root-hiding/clean_build.prop
      
      # Mount the clean file over build.prop
      mount --bind /data/adb/enhanced-root-hiding/clean_build.prop /system/build.prop
      
      # Keep the namespace alive
      while true; do
        sleep 60
      done
    " &
  fi
}

# Check if anti-detection is enabled in settings
if [ -f "$CONFIG_DIR/settings.conf" ]; then
  . "$CONFIG_DIR/settings.conf"
  
  if [ "$hide_magiskpolicy" = "true" ]; then
    hide_magiskpolicy
  fi
  
  if [ "$hide_su_binary" = "true" ]; then
    hide_su_binary
  fi
  
  if [ "$hide_magisk_modules" = "true" ]; then
    hide_magisk_modules
  fi
  
  if [ "$fix_mount_inconsistency" = "true" ]; then
    fix_mount_inconsistency
  fi
  
  if [ "$hide_lsposed" = "true" ]; then
    hide_lsposed
  fi
  
  if [ "$hide_lineageos" = "true" ]; then
    hide_lineageos
  fi
fi

echo "Anti-detection script completed at $(date)" >> $LOGFILE
exit 0
