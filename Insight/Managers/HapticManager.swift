//
//  HapticManager.swift
//  Insight
//
//  Created by Atakan on 4.02.2026.
//

import Foundation
import CoreHaptics
import UIKit

@MainActor
class HapticManager {
    static let shared = HapticManager()
    
    private var engine: CHHapticEngine?
    private var appActiveObserver: NSObjectProtocol?

    // MARK: - Haptic Parameter Constants
    private enum HapticConstants {
        static let snapIntensity:       Float = 0.75
        static let snapSharpness:       Float = 1.0
        static let softIntensity:       Float = 0.4
        static let softSharpness:       Float = 0.5
        static let navNextIntensity:    Float = 0.5
        static let navNextSharpness:    Float = 0.7
        static let navBackIntensity:    Float = 0.4
        static let navBackSharpness:    Float = 0.6
        static let successIntensity:    Float = 0.75
        static let successSharpness:    Float = 1.0
        static let breatheIntensity:    Float = 0.8
        static let breatheSharpness:    Float = 0.9
        static let breatheFadeIntensity:Float = 0.15
        static let breatheFadeSharpness:Float = 0.1
        static let nearbySharpness:     Float = 0.3
    }
    
    init() {
        prepareHaptics()
        setupNotifications()
    }
    
    private func setupNotifications() {
        appActiveObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.restartEngineIfNeeded()
            }
        }
    }
    
    private func restartEngineIfNeeded() {
        guard let engine = engine else {
                    prepareHaptics()
            return
        }
        do {
            try engine.start()
        } catch {
            print("Failed to start engine, recreating: \(error)")
            prepareHaptics()
        }
    }
    
    // Start the haptic engine
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            
            // Restart engine if it stops unexpectedly
            engine?.stoppedHandler = { [weak self] reason in
                #if DEBUG
            print("Haptic engine stopped: \(reason.rawValue)")
            #endif
                Task { @MainActor in
                    if reason.rawValue == CHHapticEngine.StoppedReason.audioSessionInterrupt.rawValue {
                                                self?.restartEngineIfNeeded()
                    } else if reason.rawValue == CHHapticEngine.StoppedReason.applicationSuspended.rawValue {
                        // We will restart when app becomes active
                    } else {
                        self?.restartEngineIfNeeded()
                    }
                }
            }
            
            engine?.resetHandler = { [weak self] in
                Task { @MainActor in
                    self?.restartEngineIfNeeded()
                }
            }
            
            try engine?.start()
        } catch {
            #if DEBUG
            print("Haptic Engine Error: \(error.localizedDescription)")
            #endif
        }
    }
    
    // Sharp snap feedback (dot toggle)
    func playHapticsSnap() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        var events = [CHHapticEvent]()
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: HapticConstants.snapIntensity)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: HapticConstants.snapSharpness)
        
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [intensity, sharpness],
            relativeTime: 0
        )
        events.append(event)
        
        playPattern(events: events)
    }
    
    // Soft selection feedback
    func playSelection() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        var events = [CHHapticEvent]()
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: HapticConstants.softIntensity)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: HapticConstants.softSharpness)
        
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [intensity, sharpness],
            relativeTime: 0
        )
        
        events.append(event)
        playPattern(events: events)
    }
    
    func navigationHapticNext() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        var events = [CHHapticEvent]()
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: HapticConstants.navNextIntensity)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: HapticConstants.navNextSharpness)
        
        let event1 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        let event2 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0.15)
        
        events.append(event1)
        events.append(event2)
        
        playPattern(events: events)
    }
    
    func navigationHapticBack() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        var events = [CHHapticEvent]()
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: HapticConstants.navBackIntensity)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: HapticConstants.navBackSharpness)
        
        let event1 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        
        events.append(event1)
        
        playPattern(events: events)
    }
    
    // Correct answer feedback (double tap)
    func playSuccess() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        var events = [CHHapticEvent]()
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: HapticConstants.successIntensity)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: HapticConstants.successSharpness)
        
        let event1 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        let event2 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0.15)
        
        events.append(event1)
        events.append(event2)
        
        playPattern(events: events)
    }
    
    // Wrong answer feedback (continuous rumble)
    func playError() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        var events = [CHHapticEvent]()
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0)
        
        let event1 = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [intensity, sharpness],
            relativeTime: 0,
            duration: 0.3
        )
        
        events.append(event1)
        
        playPattern(events: events)
    }
    
    /// Plays a rhythmic haptic pattern based on active Braille dots.
    /// Each active dot produces a distinct tap, scanned left-to-right, top-to-bottom.
    /// This gives users a tactile sense of the letter's pattern complexity.
    func playBraillePattern(activeDots: [Int]) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        var events = [CHHapticEvent]()
        
        // Braille reading order: 1, 2, 3 (left column), 4, 5, 6 (right column)
        let readingOrder = [1, 2, 3, 4, 5, 6]
        var timeOffset: Double = 0.0
        
        for dot in readingOrder {
            if activeDots.contains(dot) {
                // Active dot: strong, sharp tap
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: HapticConstants.breatheIntensity)
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: HapticConstants.breatheSharpness)
                
                let event = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [intensity, sharpness],
                    relativeTime: timeOffset
                )
                events.append(event)
            } else {
                // Inactive dot: very subtle, soft tap (represents empty space)
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: HapticConstants.breatheFadeIntensity)
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: HapticConstants.breatheFadeSharpness)
                
                let event = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [intensity, sharpness],
                    relativeTime: timeOffset
                )
                events.append(event)
            }
            
            // Small pause between dots (scanning rhythm)
            timeOffset += 0.12
            
            // Slightly longer pause between columns (left → right transition)
            if dot == 3 {
                timeOffset += 0.08
            }
        }
        
        playPattern(events: events)
    }
    
    /// Continuous buzz for Dark mode - plays while finger stays on active dot
    func playContinuousBuzz(intensity: Float = 0.6, duration: Double = 0.15) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        let intensityParam = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: HapticConstants.nearbySharpness)
        
        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [intensityParam, sharpness],
            relativeTime: 0,
            duration: duration
        )
        
        playPattern(events: [event])
    }
    
    private func playPattern(events: [CHHapticEvent]) {
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            #if DEBUG
            print("Playback Error: \(error.localizedDescription)")
            #endif
        }
    }
}
