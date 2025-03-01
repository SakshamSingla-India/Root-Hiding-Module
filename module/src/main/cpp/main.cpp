#include <cstdlib>
#include <unistd.h>
#include <fcntl.h>
#include <android/log.h>
#include <sys/system_properties.h>
#include <zygisk.hpp>
#include <string>
#include <vector>
#include <fstream>
#include <sstream>

#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG, "EnhancedRootHiding", __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, "EnhancedRootHiding", __VA_ARGS__)

using zygisk::Api;
using zygisk::AppSpecializeArgs;
using zygisk::ServerSpecializeArgs;

// Configuration paths
static const char* CONFIG_PATH = "/data/adb/enhanced-root-hiding/config/hidden_apps.txt";
static const char* SHAMIKO_PATH = "/data/adb/modules/shamiko";
static const char* TRICKY_STORE_TARGET_PATH = "/data/adb/tricky_store/target.txt";

// List of root detection methods to hook
static const char* ROOT_PROPS[] = {
    "ro.debuggable",
    "ro.secure",
    "ro.build.type",
    "ro.build.tags",
    "ro.build.selinux"
};

class EnhancedRootHidingModule : public zygisk::ModuleBase {
public:
    void onLoad(Api *api, JNIEnv *env) override {
        this->api = api;
        this->env = env;
    }

    void preAppSpecialize(AppSpecializeArgs *args) override {
        // Skip if process name is empty
        if (args->nice_name == nullptr) {
            return;
        }

        // Get the process name
        const char *process = args->nice_name;
        LOGD("Processing app: %s", process);

        // Check if this app should be hidden from
        if (shouldHideRoot(process)) {
            LOGD("Hiding root from %s", process);
            api->setOption(zygisk::Option::DLCLOSE_MODULE_LIBRARY);
        }
    }

    void postAppSpecialize(const AppSpecializeArgs *) override {}
    void preServerSpecialize(ServerSpecializeArgs *) override {}
    void postServerSpecialize(const ServerSpecializeArgs *) override {}

private:
    Api *api;
    JNIEnv *env;
    std::vector<std::string> hiddenApps;

    bool shouldHideRoot(const char* processName) {
        // Load the list of apps to hide root from
        if (hiddenApps.empty()) {
            loadHiddenApps();
        }

        std::string process(processName);
        
        // Check if the process is in our list
        for (const auto& app : hiddenApps) {
            if (process == app || process.find(app + ":") == 0 || 
                process.find(app + ".") == 0) {
                return true;
            }
        }
        
        return false;
    }

    void loadHiddenApps() {
        std::ifstream configFile(CONFIG_PATH);
        if (configFile.is_open()) {
            std::string line;
            while (std::getline(configFile, line)) {
                // Skip empty lines and comments
                if (line.empty() || line[0] == '#') {
                    continue;
                }
                hiddenApps.push_back(line);
            }
            configFile.close();
        }
        
        // Also add apps from TrickyStore if it exists
        std::ifstream trickyStoreFile(TRICKY_STORE_TARGET_PATH);
        if (trickyStoreFile.is_open()) {
            std::string line;
            while (std::getline(trickyStoreFile, line)) {
                // Skip empty lines and comments
                if (line.empty() || line[0] == '#') {
                    continue;
                }
                
                // Remove any TrickyStore specific flags (! or ?)
                if (line.back() == '!' || line.back() == '?') {
                    line.pop_back();
                }
                
                // Add to our list if not already there
                if (std::find(hiddenApps.begin(), hiddenApps.end(), line) == hiddenApps.end()) {
                    hiddenApps.push_back(line);
                }
            }
            trickyStoreFile.close();
        }
        
        LOGD("Loaded %zu apps to hide root from", hiddenApps.size());
    }
};

// Module entry point
REGISTER_ZYGISK_MODULE(EnhancedRootHidingModule)
