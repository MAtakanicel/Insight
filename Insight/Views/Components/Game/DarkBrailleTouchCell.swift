//
//  DarkBrailleTouchCell.swift
//  Insight
//
//  Created by Atakan on 28.02.2026.
//

import SwiftUI

/// Reusable dark Braille cell with drag-to-feel haptic/audio feedback.
/// Used by both DarkGameView and WordsGameView.
struct DarkBrailleTouchCell: View {
    let dotPattern: [Bool]
    let cellWidth: CGFloat

    @State private var activeDotIndex: Int? = nil
    @State private var dotFrames: [Int: CGRect] = [:]
    @State private var lastProximityHapticTime: Date = .distantPast

    private var hSpacing: CGFloat { cellWidth * 0.30 }
    private var vSpacing: CGFloat { cellWidth * 0.18 }
    private var dotSize: CGFloat  { cellWidth * 0.27 }

    var body: some View {
        cellContent
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Braille touch cell – drag to explore raised dots")
            .accessibilityHint("Double tap to enter touch mode, then drag to feel raised dots. Active dots vibrate and make a sound.")
            .accessibilityDirectTouch(options: .requiresActivation)
    }

    private var cellContent: some View {
        HStack(spacing: hSpacing) {
            VStack(spacing: vSpacing) {
                DarkDot(index: 0, isActive: dotPattern[0], coordinateSpaceName: "dragArea", size: dotSize) { idx, frame in dotFrames[idx] = frame }
                DarkDot(index: 1, isActive: dotPattern[1], coordinateSpaceName: "dragArea", size: dotSize) { idx, frame in dotFrames[idx] = frame }
                DarkDot(index: 2, isActive: dotPattern[2], coordinateSpaceName: "dragArea", size: dotSize) { idx, frame in dotFrames[idx] = frame }
            }
            VStack(spacing: vSpacing) {
                DarkDot(index: 3, isActive: dotPattern[3], coordinateSpaceName: "dragArea", size: dotSize) { idx, frame in dotFrames[idx] = frame }
                DarkDot(index: 4, isActive: dotPattern[4], coordinateSpaceName: "dragArea", size: dotSize) { idx, frame in dotFrames[idx] = frame }
                DarkDot(index: 5, isActive: dotPattern[5], coordinateSpaceName: "dragArea", size: dotSize) { idx, frame in dotFrames[idx] = frame }
            }
        }
        .padding(dotSize * 0.4)
        .coordinateSpace(name: "dragArea")
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.black)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.cyan.opacity(0.2), lineWidth: 0.5)
        )
        .contentShape(RoundedRectangle(cornerRadius: 20))
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    guard dotFrames.count == 6 else { return }
                    let location = value.location
                    var touchedDotIndex: Int? = nil
                    var closestActiveDistance: CGFloat = .infinity

                    for (index, frame) in dotFrames {
                        let center = CGPoint(x: frame.midX, y: frame.midY)
                        let distance = hypot(location.x - center.x, location.y - center.y)

                        if distance < dotSize * 0.75 {
                            touchedDotIndex = index
                        }
                        if dotPattern[index] && distance < closestActiveDistance {
                            closestActiveDistance = distance
                        }
                    }

                    // Dot changed — play snap on active dot
                    if touchedDotIndex != activeDotIndex {
                        activeDotIndex = touchedDotIndex
                        if let idx = touchedDotIndex, dotPattern[idx] {
                            HapticManager.shared.playHapticsSnap()
                            lastProximityHapticTime = .now
                        }
                    }

                    // Continuous buzz while staying on an active dot
                    if let idx = activeDotIndex, dotPattern[idx] {
                        let now = Date()
                        if now.timeIntervalSince(lastProximityHapticTime) > 0.15 {
                            HapticManager.shared.playContinuousBuzz(intensity: 0.35, duration: 0.05)
                            SoundManager.shared.playDotBuzz()
                            lastProximityHapticTime = now
                        }
                    }
                    // Proximity haptic when approaching an active dot
                    else if closestActiveDistance > dotSize * 0.65 && closestActiveDistance < dotSize * 1.3 {
                        let now = Date()
                        if now.timeIntervalSince(lastProximityHapticTime) > 0.2 {
                            HapticManager.shared.playSelection()
                            lastProximityHapticTime = now
                        }
                    }
                }
                .onEnded { _ in
                    activeDotIndex = nil
                }
        )
    }
}
