//
//  SoundManager.swift
//  Insight
//
//  Created by Atakan on 26.02.2026.
//

import AudioToolbox
import AVFoundation

@MainActor
class SoundManager {
    static let shared = SoundManager()

    /// Custom dot-touch sound loaded from bundle
    private var dotBuzzPlayer: AVAudioPlayer?

    private init() {
        prepareDotBuzz()
    }

    private func prepareDotBuzz() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            #if DEBUG
            print("AVAudioSession error: \(error)")
            #endif
        }
        
        guard let url = Bundle.main.url(forResource: "dot_buzz", withExtension: "wav") else {
            #if DEBUG
            print("⚠️ dot_buzz.wav not found in bundle")
            #endif
            return
        }
        dotBuzzPlayer = try? AVAudioPlayer(contentsOf: url)
        dotBuzzPlayer?.volume = 0.25
        dotBuzzPlayer?.prepareToPlay()
    }

    enum SoundID: UInt32 {
        case success = 1057
        case error = 1257
        case navClick = 1104
        case feelPattern = 1016
        case tink = 1157
    }

    // MARK: - UI Feedback

    /// Correct answer — clean positive tick
    func playSuccess() {
        AudioServicesPlaySystemSound(SoundID.success.rawValue)
    }

    /// Wrong answer — intentionally not called.
    /// The shake animation + haptic already communicate the error without
    /// adding a punishing audio tone. Kept here in case UX direction changes.
    func playError() {
        AudioServicesPlaySystemSound(SoundID.error.rawValue)
    }

    /// Letter navigation tap (prev / next arrow)
    func playNavClick() {
        AudioServicesPlaySystemSound(SoundID.navClick.rawValue)
    }

    /// "Feel the Pattern" button
    func playFeel() {
        AudioServicesPlaySystemSound(SoundID.feelPattern.rawValue)
    }

    // MARK: - Dot Touch Feedback
    // Always plays — some iPads (Pro M1/M2, Air M1/M2) report supportsHaptics=true
    // but the haptic motor is weak/absent. Sounds play alongside haptics on devices
    // that support them and stand alone on devices that don't.

    /// Called when finger enters an active Braille dot — sharp click
    func playDotSnap() {
        AudioServicesPlaySystemSound(SoundID.tink.rawValue) // Tink
    }

    /// Called while finger stays on an active dot — custom sound (throttled by caller)
    func playDotBuzz() {
        dotBuzzPlayer?.currentTime = 0
        dotBuzzPlayer?.play()
    }

    // MARK: - Braille Pattern — Synced Haptic + Audio

    /// Plays haptic snap + audio click per active dot, in Braille reading order.
    /// Both fire in the same loop iteration → near-perfect sync (~98%).
    /// Works on all devices: iPhone gets haptic + sound, iPad gets sound only.
    func playBraillePatternSynced(activeDots: [Int]) async {
        // Braille reading order: 1, 2, 3 (left column), 4, 5, 6 (right column)
        let readingOrder = [1, 2, 3, 4, 5, 6]
        var delaySeconds: Double = 0

        for dot in readingOrder {
            if delaySeconds > 0 {
                try? await Task.sleep(for: .milliseconds(Int(delaySeconds * 1000)))
            }

            if activeDots.contains(dot) {
                HapticManager.shared.playHapticsSnap()      // haptic (iPhone)
                AudioServicesPlaySystemSound(SoundID.tink.rawValue)           // Tink (all devices)
            }
            // Inactive dot → silence

            delaySeconds = (dot == 3) ? 0.20 : 0.12
        }
    }
}
