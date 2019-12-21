import CoreHaptics
import Foundation
import Capacitor

@available(iOS 13.0, *)
public class JSHapticEventParameter {
    public static var stringToHapticParameterID: Dictionary<String, CHHapticEvent.ParameterID> = [
        "hapticIntensity": .hapticIntensity,
        "hapticSharpness": .hapticSharpness
    ]
    
    public static func toCHHapticEventParameter(_ jsEventParameter:[String: Any]) -> CHHapticEventParameter {
        let jsParameterID = jsEventParameter["parameterId"] as! String
        let nativeParameterID = stringToHapticParameterID[jsParameterID]!
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
    public static var stringToHapticParameterId: Dictionary<String, CHHapticDynamicParameter.ID> = [
        "hapticIntensity": .hapticIntensityControl,
        "hapticSharpness": .hapticSharpnessControl
    ]
    
    public static func toCHHapticParameterCurve(_ jsParameterCurve: [String: Any]) -> CHHapticParameterCurve {
        let jsParameterId = jsParameterCurve["parameterId"] as! String
        let controlPoints = jsParameterCurve["controlPoints"] as! Array<[String: Any]>
        let nativeControlPoints = controlPoints.map{ point -> CHHapticParameterCurve.ControlPoint in
            return CHHapticParameterCurve.ControlPoint(relativeTime: point["relativeTime"] as! Double, value: point["value"] as! Float)
        }

        let nativeParameterId = stringToHapticParameterId[jsParameterId]
        return CHHapticParameterCurve(parameterID: nativeParameterId!, controlPoints: nativeControlPoints, relativeTime: jsParameterCurve["relativeTime"] as! Double)
    }
}


/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitor.ionicframework.com/docs/plugins/ios
 */
@available(iOS 13.0, *)
@objc(HapticFeedbackPlugin)
public class HapticFeedbackPlugin: CAPPlugin {
    var stringToHapticEventType: Dictionary<String, CHHapticEvent.EventType> = [
        "hapticContinuous": .hapticContinuous,
        "hapticTransient": .hapticTransient
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
            guard let jsParameterCurves = call.getArray("events", [String:Any].self) else {
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
                return JSHapticParameterCurve.toCHHapticParameterCurve(curve)
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
