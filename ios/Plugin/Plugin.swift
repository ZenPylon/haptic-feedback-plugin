import CoreHaptics
import Foundation
import Capacitor


public class JSHapticEventType {
    var duration: Double
    var eventType: String
    var parameters: Array<Any>
    var relativeTime: Double
    
    init(eventType: String, parameters: Array<Any>, relativeTime: Double, duration: Double) {
        self.eventType = eventType
        self.parameters = parameters
        self.relativeTime = relativeTime
        self.duration = duration
    }
    
}

public class JSHapticPattern {
    var events: Array<JSHapticEventType>
    var parameterCurves: Array<Any>
    
    init(events: Array<JSHapticEventType>, parameterCurves: Array<Any>) {
        self.events = events
        self.parameterCurves = parameterCurves
    }
}

@available(iOS 13.0, *)
public class JSHpaticParameterCurve {
    var parameterId: CHHapticPattern.Key
    var controlPoints: Array<CHHapticParameterCurve.ControlPoint>
    var relativeTime: Double
    
    init(parameterId: CHHapticPattern.Key, controlPoints: Array<CHHapticParameterCurve.ControlPoint>, relativeTime: Double) {
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
    let stringToHapticType: Dictionary<String, CHHapticEvent.EventType> = [
        "continuous": .hapticContinuous,
        "transient": .hapticTransient
    ]
    
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
    
    @objc func makeAdvancedPlayer(_ call: CAPPluginCall) {
        do {
            let patternData = call.getObject("pattern") as Any
            patternData.events
            
            try self.player = self.engine?.makeAdvancedPlayer(with: self.pattern!)
        } catch {
            call.error("blah")
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
