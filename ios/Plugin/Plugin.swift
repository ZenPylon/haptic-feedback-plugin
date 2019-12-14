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
    var hapticEvent: CHHapticEvent?
    var hapticPattern: CHHapticPattern?
    var hapticParameterCurve: CHHapticParameterCurve?
    var hapticDict: [CHHapticPattern.Key : [[CHHapticPattern.Key : [CHHapticPattern.Key : Any]]]]?
    var pattern: CHHapticPattern?
    var player: CHHapticAdvancedPatternPlayer?
    
    override public init!(bridge: CAPBridge!, pluginId: String!, pluginName: String!) {
        do {
            self.hapticDict = [
                CHHapticPattern.Key.pattern: [
                    [CHHapticPattern.Key.event: [CHHapticPattern.Key.eventType: CHHapticEvent.EventType.hapticTransient,
                          CHHapticPattern.Key.time: 0.001,
                          CHHapticPattern.Key.eventDuration: 1.0] // End of first event
                    ] // End of first dictionary entry in the array
                ] // End of array
            ] // End of haptic dictionary
            
            
            let controlPoint1 = CHHapticParameterCurve.ControlPoint.init(relativeTime: 0, value: 0)
            let controlPoint2 = CHHapticParameterCurve.ControlPoint.init(relativeTime: 4, value: 1)
            
            self.hapticParameterCurve = CHHapticParameterCurve.init(
                parameterID: .hapticIntensityControl,
                controlPoints: [controlPoint1, controlPoint2],
                relativeTime: 0)
            
            self.engine = try CHHapticEngine()
            self.hapticEvent = CHHapticEvent.init(eventType: .hapticContinuous, parameters: [], relativeTime: 0, duration: 5)
            self.hapticPattern = try CHHapticPattern.init(events: [self.hapticEvent!], parameterCurves: [self.hapticParameterCurve!])
            
            self.player = try self.engine?.makeAdvancedPlayer(with: self.pattern!)
        }
        catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
        super.init(bridge: bridge, pluginId: pluginId, pluginName: pluginName)
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
