#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

// Define the plugin using the CAP_PLUGIN Macro, and
// each method the plugin supports using the CAP_PLUGIN_METHOD macro.
CAP_PLUGIN(HapticFeedbackPlugin, "HapticFeedbackPlugin",
    CAP_PLUGIN_METHOD(startEngine, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(stopEngine, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(makeAdvancedPlayer, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(startPlayer, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(stopPlayer, CAPPluginReturnPromise);
)
