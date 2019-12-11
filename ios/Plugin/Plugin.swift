import CoreHaptics
import Foundation
import Capacitor

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitor.ionicframework.com/docs/plugins/ios
 */
@available(iOS 13.0, *)
@objc(HapticFeedbackPlugin)
public class HapticFeedbackPlugin: CAPPlugin {
    var engine: CHHapticEngine?
    
    override init () {
        super.init()
        do {
            self.engine = try CHHapticEngine()
        }
        catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }
    
    override public init!(bridge: CAPBridge!, pluginId: String!, pluginName: String!) {
        super.init(bridge: bridge, pluginId: pluginId, pluginName: pluginName)
    }
    
    @objc func start(_ call: CAPPluginCall) {
        do {
            try self.engine?.start()
        } catch {
            let message = "There was an error starting the engine: \(error.localizedDescription)"
            print(message)
            return call.error(message)
        }
    
        call.success()
    }
    
    @objc func stop(_ call: CAPPluginCall) {
        self.engine?.stop()
        call.success()
    }
    
}
