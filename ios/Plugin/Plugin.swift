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
    var hapticDict: [CHHapticPattern.Key : [[CHHapticPattern.Key : [CHHapticPattern.Key : Any]]]]?
    var pattern: CHHapticPattern?
    var player: CHHapticPatternPlayer?
    
    override init() {
        do {
            self.hapticDict = [
                CHHapticPattern.Key.pattern: [
                    [CHHapticPattern.Key.event: [CHHapticPattern.Key.eventType: CHHapticEvent.EventType.hapticTransient,
                          CHHapticPattern.Key.time: 0.001,
                          CHHapticPattern.Key.eventDuration: 1.0] // End of first event
                    ] // End of first dictionary entry in the array
                ] // End of array
            ] // End of haptic dictionary
            
            self.pattern = try CHHapticPattern(dictionary: self.hapticDict!)
            self.engine = try CHHapticEngine()
            self.player = try engine?.makePlayer(with: self.pattern!)
        }
        catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
        super.init()
    }
    

    @objc func start(_ call: CAPPluginCall) {
        do {
            try self.engine?.start()
            try self.player?.start(atTime: 0)
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
