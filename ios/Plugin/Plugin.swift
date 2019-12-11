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
            engine = try CHHapticEngine()
        }
        catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
        
    }
    
    @objc func start(_ call: CAPPluginCall) {
        do {
            try engine?.start()
        } catch {
            let message = "There was an error starting the engine: \(error.localizedDescription)"
            print(message)
            return call.error(message)
        }
    
        call.success()
    }
    
    @objc func stop(_ call: CAPPluginCall) {
        engine?.stop()
        call.success()
    }
    
}
