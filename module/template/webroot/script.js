import { exec, toast } from 'kernelsu';

// Global variables
let appList = [];
let deniedApps = [];
let settings = {
    shamiko: true,
    trickyStore: true,
    zygisk: true,
    zygiskNext: true,
    whitelistMode: false,
    securityPatch: '',
    hideMagiskPolicy: true,
    hideSuBinary: true,
    hideMagiskModules: true,
    fixMountInconsistency: true,
    hideLSPosed: true,
    hideLineageOS: true
};

// DOM elements
const appListElement = document.getElementById('app-list');
const searchInput = document.getElementById('search-input');
const saveButton = document.getElementById('save-btn');
const refreshButton = document.getElementById('refresh-btn');
const statusElement = document.getElementById('status');
const saveSettingsButton = document.getElementById('save-settings-btn');
const resetSettingsButton = document.getElementById('reset-settings-btn');

// Tab navigation
const tabButtons = document.querySelectorAll('.tab-btn');
const tabContents = document.querySelectorAll('.tab-content');

// Settings elements
const shamikoToggle = document.getElementById('shamiko-toggle');
const trickyStoreToggle = document.getElementById('trickystore-toggle');
const zygiskToggle = document.getElementById('zygisk-toggle');
const zygiskNextToggle = document.getElementById('zygisk-next-toggle');
const whitelistToggle = document.getElementById('whitelist-toggle');
const securityPatchInput = document.getElementById('security-patch');

// Anti-detection settings elements
const hideMagiskPolicyToggle = document.getElementById('hide-magiskpolicy-toggle');
const hideSuToggle = document.getElementById('hide-su-toggle');
const hideModulesToggle = document.getElementById('hide-modules-toggle');
const fixMountToggle = document.getElementById('fix-mount-toggle');
const hideLSPosedToggle = document.getElementById('hide-lsposed-toggle');
const hideLineageOSToggle = document.getElementById('hide-lineageos-toggle');

// Initialize the app
document.addEventListener('DOMContentLoaded', () => {
    // Set up tab navigation
    tabButtons.forEach(button => {
        button.addEventListener('click', () => {
            const tabName = button.getAttribute('data-tab');
            
            // Update active tab button
            tabButtons.forEach(btn => btn.classList.remove('active'));
            button.classList.add('active');
            
            // Show the selected tab content
            tabContents.forEach(content => {
                content.classList.remove('active');
                if (content.id === `${tabName}-tab`) {
                    content.classList.add('active');
                }
            });
        });
    });
    
    // Load app list and settings
    loadAppList();
    loadDeniedApps();
    loadSettings();
    
    // Event listeners
    searchInput.addEventListener('input', filterApps);
    saveButton.addEventListener('click', saveConfiguration);
    refreshButton.addEventListener('click', loadAppList);
    saveSettingsButton.addEventListener('click', saveSettings);
    resetSettingsButton.addEventListener('click', resetSettings);
    
    // Settings event listeners
    shamikoToggle.addEventListener('change', updateSettings);
    trickyStoreToggle.addEventListener('change', updateSettings);
    zygiskToggle.addEventListener('change', updateSettings);
    zygiskNextToggle.addEventListener('change', updateSettings);
    whitelistToggle.addEventListener('change', updateSettings);
    securityPatchInput.addEventListener('change', updateSettings);
    
    // Anti-detection settings event listeners
    hideMagiskPolicyToggle.addEventListener('change', updateSettings);
    hideSuToggle.addEventListener('change', updateSettings);
    hideModulesToggle.addEventListener('change', updateSettings);
    fixMountToggle.addEventListener('change', updateSettings);
    hideLSPosedToggle.addEventListener('change', updateSettings);
    hideLineageOSToggle.addEventListener('change', updateSettings);
});

// Load the list of installed apps
async function loadAppList() {
    appListElement.innerHTML = '<div class="loading">Loading apps...</div>';
    
    try {
        // Get all installed packages
        const { errno, stdout } = await exec('pm list packages -f');
        
        if (errno !== 0) {
            throw new Error('Failed to get package list');
        }
        
        // Parse the package list
        appList = stdout.split('\n')
            .filter(line => line.trim() !== '')
            .map(line => {
                // Format is package:path=package.name
                const match = line.match(/package:(.+)=(.+)/);
                if (match) {
                    const path = match[1];
                    const packageName = match[2];
                    return { path, packageName };
                }
                return null;
            })
            .filter(app => app !== null);
        
        // Get app labels (names) for each package
        for (const app of appList) {
            const { errno: labelErrno, stdout: labelStdout } = 
                await exec(`dumpsys package ${app.packageName} | grep "labelRes:" | head -n 1`);
            
            if (labelErrno === 0 && labelStdout.trim() !== '') {
                // Try to extract the label
                const labelMatch = labelStdout.match(/labelRes:.+?:(.+?)(?:\s|$)/);
                if (labelMatch) {
                    app.label = labelMatch[1];
                } else {
                    app.label = app.packageName;
                }
            } else {
                app.label = app.packageName;
            }
        }
        
        // Sort apps by label
        appList.sort((a, b) => a.label.localeCompare(b.label));
        
        // Display the apps
        renderAppList(appList);
    } catch (error) {
        appListElement.innerHTML = `<div class="error">Error loading apps: ${error.message}</div>`;
        console.error('Error loading apps:', error);
    }
}

// Load the current denylist configuration
async function loadDeniedApps() {
    try {
        // Check if our module configuration exists
        const { errno: configErrno } = await exec('[ -f /data/adb/enhanced-root-hiding/config/hidden_apps.txt ] && echo "exists"');
        
        if (configErrno === 0) {
            // Read from our own configuration
            const { stdout } = await exec('cat /data/adb/enhanced-root-hiding/config/hidden_apps.txt');
            deniedApps = stdout.split('\n')
                .filter(line => line.trim() !== '' && !line.startsWith('#'))
                .map(line => line.trim());
        } else {
            // Try to get the denylist from Magisk if Shamiko is installed
            const { errno: shamikoErrno } = await exec('[ -d /data/adb/modules/shamiko ] && echo "exists"');
            
            if (shamikoErrno === 0) {
                const { errno, stdout } = await exec('magisk --denylist ls');
                
                if (errno === 0) {
                    deniedApps = stdout.split('\n')
                        .filter(line => line.trim() !== '')
                        .map(line => line.trim());
                }
            }
            
            // Also check TrickyStore targets
            const { errno: trickyErrno } = await exec('[ -f /data/adb/tricky_store/target.txt ] && echo "exists"');
            
            if (trickyErrno === 0) {
                const { stdout } = await exec('cat /data/adb/tricky_store/target.txt');
                const trickyApps = stdout.split('\n')
                    .filter(line => line.trim() !== '' && !line.startsWith('#'))
                    .map(line => {
                        // Remove TrickyStore specific flags (! or ?)
                        if (line.endsWith('!') || line.endsWith('?')) {
                            return line.slice(0, -1);
                        }
                        return line.trim();
                    });
                
                // Merge with deniedApps, avoiding duplicates
                trickyApps.forEach(app => {
                    if (!deniedApps.includes(app)) {
                        deniedApps.push(app);
                    }
                });
            }
        }
        
        // Update the UI to show selected apps
        updateSelectedApps();
    } catch (error) {
        showStatus(`Error loading configuration: ${error.message}`, 'error');
        console.error('Error loading configuration:', error);
    }
}

// Load saved settings
async function loadSettings() {
    try {
        // Check if settings file exists
        const { errno } = await exec('[ -f /data/adb/enhanced-root-hiding/config/settings.txt ] && echo "exists"');
        
        if (errno === 0) {
            const { stdout } = await exec('cat /data/adb/enhanced-root-hiding/config/settings.txt');
            const lines = stdout.split('\n').filter(line => line.trim() !== '');
            
            lines.forEach(line => {
                const [key, value] = line.split('=');
                if (key && value) {
                    switch (key.trim()) {
                        case 'shamiko':
                            settings.shamiko = value.trim() === 'true';
                            break;
                        case 'trickyStore':
                            settings.trickyStore = value.trim() === 'true';
                            break;
                        case 'zygisk':
                            settings.zygisk = value.trim() === 'true';
                            break;
                        case 'whitelistMode':
                            settings.whitelistMode = value.trim() === 'true';
                            break;
                        case 'securityPatch':
                            settings.securityPatch = value.trim();
                            break;
                    }
                }
            });
        }
        
        // Update UI with loaded settings
        shamikoToggle.checked = settings.shamiko;
        trickyStoreToggle.checked = settings.trickyStore;
        zygiskToggle.checked = settings.zygisk;
        whitelistToggle.checked = settings.whitelistMode;
        securityPatchInput.value = settings.securityPatch;
        
        // Check whitelist file existence
        const { errno: whitelistErrno } = await exec('[ -f /data/adb/shamiko/whitelist ] && echo "exists"');
        if (whitelistErrno === 0 && !settings.whitelistMode) {
            settings.whitelistMode = true;
            whitelistToggle.checked = true;
        }
        
        // Check security patch
        if (!settings.securityPatch) {
            const { errno: patchErrno, stdout: patchStdout } = await exec('[ -f /data/adb/tricky_store/security_patch.txt ] && cat /data/adb/tricky_store/security_patch.txt');
            if (patchErrno === 0 && patchStdout.trim() !== '') {
                const patchMatch = patchStdout.match(/(\d{8})/);
                if (patchMatch) {
                    settings.securityPatch = patchMatch[1];
                    securityPatchInput.value = settings.securityPatch;
                }
            }
        }
    } catch (error) {
        console.error('Error loading settings:', error);
    }
}

// Render the app list in the UI
function renderAppList(apps) {
    if (apps.length === 0) {
        appListElement.innerHTML = '<div class="no-apps">No apps found</div>';
        return;
    }
    
    const appListHtml = apps.map(app => `
        <div class="app-item" data-package="${app.packageName}">
            <div class="app-details">
                <div class="app-name">${app.label}</div>
                <div class="app-package">${app.packageName}</div>
            </div>
            <input type="checkbox" class="app-checkbox" data-package="${app.packageName}">
        </div>
    `).join('');
    
    appListElement.innerHTML = appListHtml;
    
    // Add event listeners to checkboxes
    document.querySelectorAll('.app-checkbox').forEach(checkbox => {
        checkbox.addEventListener('change', toggleApp);
    });
    
    // Update checkboxes based on current denylist
    updateSelectedApps();
}

// Update the UI to show which apps are selected
function updateSelectedApps() {
    document.querySelectorAll('.app-checkbox').forEach(checkbox => {
        const packageName = checkbox.getAttribute('data-package');
        checkbox.checked = deniedApps.includes(packageName);
    });
}

// Filter apps based on search input
function filterApps() {
    const searchTerm = searchInput.value.toLowerCase();
    
    const filteredApps = appList.filter(app => 
        app.label.toLowerCase().includes(searchTerm) || 
        app.packageName.toLowerCase().includes(searchTerm)
    );
    
    renderAppList(filteredApps);
}

// Toggle an app in the denylist
function toggleApp(event) {
    const checkbox = event.target;
    const packageName = checkbox.getAttribute('data-package');
    
    if (checkbox.checked) {
        if (!deniedApps.includes(packageName)) {
            deniedApps.push(packageName);
        }
    } else {
        const index = deniedApps.indexOf(packageName);
        if (index !== -1) {
            deniedApps.splice(index, 1);
        }
    }
}

// Update settings from UI
function updateSettings() {
    settings.shamiko = shamikoToggle.checked;
    settings.trickyStore = trickyStoreToggle.checked;
    settings.zygisk = zygiskToggle.checked;
    settings.zygiskNext = zygiskNextToggle.checked;
    settings.whitelistMode = whitelistToggle.checked;
    settings.securityPatch = securityPatchInput.value.trim();
    
    // Update anti-detection settings
    settings.hideMagiskPolicy = hideMagiskPolicyToggle.checked;
    settings.hideSuBinary = hideSuToggle.checked;
    settings.hideMagiskModules = hideModulesToggle.checked;
    settings.fixMountInconsistency = fixMountToggle.checked;
    settings.hideLSPosed = hideLSPosedToggle.checked;
    settings.hideLineageOS = hideLineageOSToggle.checked;
}

// Save the configuration
async function saveConfiguration() {
    try {
        // Create config directory if it doesn't exist
        await exec('mkdir -p /data/adb/enhanced-root-hiding/config');
        
        // Save the list of hidden apps to our config
        const appsConfig = deniedApps.join('\n');
        await exec(`echo '${appsConfig}' > /data/adb/enhanced-root-hiding/config/hidden_apps.txt`);
        
        // Configure Shamiko if enabled
        if (settings.shamiko) {
            // Check if Shamiko is installed
            const { errno: shamikoErrno } = await exec('[ -d /data/adb/modules/shamiko ] && echo "exists"');
            
            if (shamikoErrno === 0) {
                // Clear the current denylist
                await exec('magisk --denylist clear');
                
                // Add each app to the denylist
                for (const packageName of deniedApps) {
                    await exec(`magisk --denylist add ${packageName}`);
                }
                
                // Make sure denylist enforcement is disabled (required for Shamiko)
                await exec('magisk --denylist disable');
                
                // Handle whitelist mode
                if (settings.whitelistMode) {
                    await exec('mkdir -p /data/adb/shamiko');
                    await exec('touch /data/adb/shamiko/whitelist');
                } else {
                    await exec('rm -f /data/adb/shamiko/whitelist');
                }
            } else {
                showStatus('Shamiko module not found. Please install Shamiko for full functionality.', 'error');
            }
        }
        
        // Configure TrickyStore if enabled
        if (settings.trickyStore) {
            // Create TrickyStore directory if it doesn't exist
            await exec('mkdir -p /data/adb/tricky_store');
            
            // Save the list of apps to TrickyStore target.txt
            await exec(`echo '${deniedApps.join('\n')}' > /data/adb/tricky_store/target.txt`);
            
            // Set security patch if provided
            if (settings.securityPatch && settings.securityPatch.match(/^\d{8}$/)) {
                await exec(`echo '${settings.securityPatch}' > /data/adb/tricky_store/security_patch.txt`);
            }
        }
        
        // Show success message
        showStatus('Configuration saved successfully!', 'success');
        
        // Show toast notification
        toast('Configuration saved successfully!');
    } catch (error) {
        showStatus(`Error saving configuration: ${error.message}`, 'error');
        console.error('Error saving configuration:', error);
    }
}

// Save settings
async function saveSettings() {
    try {
        // Update settings from UI
        updateSettings();
        
        // Create config directory if it doesn't exist
        await exec('mkdir -p /data/adb/enhanced-root-hiding/config');
        
        // Save settings to file
        const settingsStr = [
            `shamiko=${settings.shamiko}`,
            `trickyStore=${settings.trickyStore}`,
            `zygisk=${settings.zygisk}`,
            `zygiskNext=${settings.zygiskNext}`,
            `whitelistMode=${settings.whitelistMode}`,
            `securityPatch=${settings.securityPatch}`,
            `hideMagiskPolicy=${settings.hideMagiskPolicy}`,
            `hideSuBinary=${settings.hideSuBinary}`,
            `hideMagiskModules=${settings.hideMagiskModules}`,
            `fixMountInconsistency=${settings.fixMountInconsistency}`,
            `hideLSPosed=${settings.hideLSPosed}`,
            `hideLineageOS=${settings.hideLineageOS}`
        ].join('\n');
        
        await exec(`echo '${settingsStr}' > /data/adb/enhanced-root-hiding/config/settings.txt`);
        
        // Apply settings
        if (settings.shamiko) {
            // Handle whitelist mode
            if (settings.whitelistMode) {
                await exec('mkdir -p /data/adb/shamiko');
                await exec('touch /data/adb/shamiko/whitelist');
            } else {
                await exec('rm -f /data/adb/shamiko/whitelist');
            }
        }
        
        if (settings.trickyStore && settings.securityPatch && settings.securityPatch.match(/^\d{8}$/)) {
            await exec('mkdir -p /data/adb/tricky_store');
            await exec(`echo '${settings.securityPatch}' > /data/adb/tricky_store/security_patch.txt`);
        }
        
        // Apply Zygisk Next settings if enabled
        if (settings.zygiskNext) {
            // Check if Zygisk Next is installed
            const { errno: zygiskNextErrno } = await exec('[ -d /data/adb/modules/zygisksu ] && echo "exists"');
            if (zygiskNextErrno !== 0) {
                showStatus('Zygisk Next module not found. Please install it for better compatibility.', 'warning');
            }
        }
        
        // Apply anti-detection settings
        // These settings will be read by the anti_detection.sh script
        await exec('mkdir -p /data/adb/enhanced-root-hiding/config');
        const antiDetectionSettings = [
            `hide_magiskpolicy=${settings.hideMagiskPolicy}`,
            `hide_su_binary=${settings.hideSuBinary}`,
            `hide_magisk_modules=${settings.hideMagiskModules}`,
            `fix_mount_inconsistency=${settings.fixMountInconsistency}`,
            `hide_lsposed=${settings.hideLSPosed}`,
            `hide_lineageos=${settings.hideLineageOS}`
        ].join('\n');
        
        await exec(`echo '${antiDetectionSettings}' > /data/adb/enhanced-root-hiding/config/anti_detection.conf`);
        
        // Restart anti-detection script to apply new settings
        await exec('pkill -f "anti_detection.sh" || true');
        await exec('sh /data/adb/modules/enhanced-root-hiding/anti_detection.sh &');
        
        // Show success message
        showStatus('Settings saved successfully!', 'success');
        toast('Settings saved successfully!');
    } catch (error) {
        showStatus(`Error saving settings: ${error.message}`, 'error');
        console.error('Error saving settings:', error);
    }
}

// Reset settings to defaults
function resetSettings() {
    settings = {
        shamiko: true,
        trickyStore: true,
        zygisk: true,
        zygiskNext: true,
        whitelistMode: false,
        securityPatch: '',
        hideMagiskPolicy: true,
        hideSuBinary: true,
        hideMagiskModules: true,
        fixMountInconsistency: true,
        hideLSPosed: true,
        hideLineageOS: true
    };
    
    // Update UI
    shamikoToggle.checked = settings.shamiko;
    trickyStoreToggle.checked = settings.trickyStore;
    zygiskToggle.checked = settings.zygisk;
    zygiskNextToggle.checked = settings.zygiskNext;
    whitelistToggle.checked = settings.whitelistMode;
    securityPatchInput.value = settings.securityPatch;
    
    // Update anti-detection UI
    hideMagiskPolicyToggle.checked = settings.hideMagiskPolicy;
    hideSuToggle.checked = settings.hideSuBinary;
    hideModulesToggle.checked = settings.hideMagiskModules;
    fixMountToggle.checked = settings.fixMountInconsistency;
    hideLSPosedToggle.checked = settings.hideLSPosed;
    hideLineageOSToggle.checked = settings.hideLineageOS;
    
    showStatus('Settings reset to defaults. Click Save Settings to apply.', 'success');
}

// Show status message
function showStatus(message, type) {
    statusElement.textContent = message;
    statusElement.className = `status ${type}`;
    
    // Hide the status after 5 seconds
    setTimeout(() => {
        statusElement.className = 'status';
    }, 5000);
}
