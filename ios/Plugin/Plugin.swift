import CoreHaptics
import Foundation
import Capacitor

@available(iOS 13.0, *)
public class JSHapticEventParameter {
    public static var stringToHapticParameterId: Dictionary<String, CHHapticEvent.ParameterID> = [
        "intensity": .hapticIntensity,
        "sharpness": .hapticSharpness
    ]
    
    public static func toCHHapticEventParameter(_ jsEventParameter:[String: Any]) -> CHHapticEventParameter {
        let jsParameterID = jsEventParameter["parameterId"] as! String
        let nativeParameterID = stringToHapticParameterId[jsParameterID]!
        return CHHapticEventParameter(parameterID: nativeParameterID, value: jsEventParameter["value"] as! Float)
    }
    
    public static func toCHHapticEventParameters(_ jsEventParameters: Array<[String: Any]>) -> Array<CHHapticEventParameter> {
        return jsEventParameters.map{ jsParameter -> CHHapticEventParameter in
            return toCHHapticEventParameter(jsParameter)
        }
    }
}


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
    
    
    var engine: CHHapticEngine?
    var hapticEvent: CHHapticEvent?
    var hapticPattern: CHHapticPattern?
    var hapticParameterCurve: CHHapticParameterCurve?
    var pattern: CHHapticPattern?
    var player: CHHapticAdvancedPatternPlayer?

    @objc func makeAdvancedPlayer(_ call: CAPPluginCall) {
        do {
            guard let jsEvents = call.getArray("events", [String:Any].self) else {
                call.error("Property `events` must be passed in makeAdvancedPlayer()")
                return
            }
            guard let parameterCurves = call.getArray("events", [String:Any].self) else {
                call.error("Property `parameterCurves` must be passed in makeAdvancedPlayer()")
                return
            }
            
            let events = jsEvents.map{ event -> CHHapticEvent in
                let nativeParameters = JSHapticEventParameter.toCHHapticEventParameters(event["parameters"] as! Array<[String : Any]>)
                return CHHapticEvent.init(eventType: stringToHapticEventType[event["eventType"] as! String]!,
                                          parameters: nativeParameters,
                                          relativeTime: event["relativeTime"] as! Double,
                                          duration: event["duration"] as! Double
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
