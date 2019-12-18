import CoreHaptics
import Foundation
import Capacitor

@available(iOS 13.0, *)
public class JSHapticEvent {
    var duration: Double
    var eventType: String
    var parameters: Array<CHHapticEventParameter>
    var relativeTime: Double
    
    init(eventType: String, parameters: Array<CHHapticEventParameter>, relativeTime: Double, duration: Double) {
        self.eventType = eventType
        self.parameters = parameters
        self.relativeTime = relativeTime
        self.duration = duration
    }
    
}

@available(iOS 13.0, *)
public class JSHapticPattern {
    var events: Array<JSHapticEvent>
    var parameterCurves: Array<Any>
    
    init(events: Array<JSHapticEvent>, parameterCurves: Array<Any>) {
        self.events = events
        self.parameterCurves = parameterCurves
    }
}

@available(iOS 13.0, *)
public class JSHapticParameterCurve {
    var parameterId: String
    var controlPoints: Array<CHHapticParameterCurve.ControlPoint>
    var relativeTime: Double
    
    init(parameterId: String, controlPoints: Array<CHHapticParameterCurve.ControlPoint>, relativeTime: Double) {
        self.parameterId = parameterId
        self.controlPoints = controlPoints
        self.relativeTime = relativeTime
    }
}


/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitor.ionicframework.com/docs/plugins/ios
 */
@available(iOS 13.0, *)
@objc(HapticFeedbackPlugin)
public class HapticFeedbackPlugin: CAPPlugin {
    let stringToHapticEventType: Dictionary<String, CHHapticEvent.EventType> = [
        "continuous": .hapticContinuous,
        "transient": .hapticTransient
    ]
    let stringToHapticParameterId: Dictionary<String, CHHapticDynamicParameter.ID> = [
        "intensity": .hapticIntensityControl,
        "sharpness": .hapticSharpnessControl
    ]
    
    var engine: CHHapticEngine?
    var hapticEvent: CHHapticEvent?
    var hapticPattern: CHHapticPattern?
    var hapticParameterCurve: CHHapticParameterCurve?
    var hapticDict: [CHHapticPattern.Key : [[CHHapticPattern.Key : [CHHapticPattern.Key : Any]]]]?
    var pattern: CHHapticPattern?
    var player: CHHapticAdvancedPatternPlayer?

    @objc func makeAdvancedPlayer(_ call: CAPPluginCall) {
        do {
            let jsEvents = call.options["events"] as! Array<JSHapticEvent>
            let jsParameterCurves = call.options["parameterCurves"] as! Array<JSHapticParameterCurve>
            
            let events = jsEvents.map{ event -> CHHapticEvent in
                return CHHapticEvent.init(eventType: stringToHapticEventType[event.eventType] ?? .hapticContinuous,
                                          parameters: event.parameters,
                                          relativeTime: event.relativeTime,
                                          duration: event.duration
                )
            }
            
            let parameterCurves = jsParameterCurves.map{ curve -> CHHapticParameterCurve in
                return CHHapticParameterCurve.init(parameterID: stringToHapticParameterId[curve.parameterId] ?? .hapticIntensityControl,
                                                   controlPoints: curve.controlPoints,
                                                   relativeTime: curve.relativeTime
                )
            }
            self.pattern = try CHHapticPattern.init(events: events, parameterCurves: parameterCurves)
            try self.player = self.engine?.makeAdvancedPlayer(with: self.pattern!)
            call.success()
        } catch {
            let message = "There was an error while making the advanced player: \(error.localizedDescription)"
            print(message)
            call.error(message)
        }
    }

    @objc func startEngine(_ call: CAPPluginCall) {
        do {
            try self.engine?.start()
            call.success()
        } catch {
            let message = "There was an error starting the engine: \(error.localizedDescription)"
            print(message)
            call.error(message)
        }
    
    }
    
    @objc func stopEngine(_ call: CAPPluginCall) {
        self.engine?.stop()
        call.success()
    }
    
    @objc func startPlayer(_ call: CAPPluginCall) {
           do {
               let atTime = call.getDouble("atTime") ?? 0
               try self.player?.start(atTime: atTime)
               call.success()
           } catch {
               let message = "There was an error starting the player: \(error.localizedDescription)"
               print(message)
               call.error(message)
           }
       }
    
    @objc func stopPlayer(_ call: CAPPluginCall) {
        do {
            let atTime = call.getDouble("atTime") ?? 0
            try self.player?.stop(atTime: atTime)
            call.success()
        } catch {
            let message = "There was an error stopping the player: \(error.localizedDescription)"
            print(message)
            call.error(message)
        }
    }
    
}
