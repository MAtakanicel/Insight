//
//  InsightChallengeView.swift
//  Insight
//
//  Created by Atakan on 17.02.2026.
//

import SwiftUI

struct InsightChallengeView: View {
    @EnvironmentObject var navManager: NavigationManager
    
    @State private var dots: [Bool] = Array(repeating: false, count: 6)
    
    // Animation phases
    @State private var showPrompt = false
    @State private var showDots = false
    @State private var showInstruction = false
    @State private var showHint = false
    @State private var isSuccess = false
    @State private var successScale: CGFloat = 0.3
    @State private var letterGlow = false
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // "I" in Braille = dots 2 & 4
    private let targetDots: Set<Int> = [1, 3] // 0-indexed positions for dots 2 & 4
    
    var body: some View {
        ZStack {
            // Pure black background
            Color.black.ignoresSafeArea()
            
            if isSuccess {
                successView
            } else {
                challengeContent
            }
        }
        .onAppear {
            startSequence()
        }
    }
    
    // MARK: - Challenge Content
    
    private var challengeContent: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Prompt text
            if showPrompt {
                Text("Can you feel it?")
                    .font(.title.weight(.light))
                    .foregroundColor(.white.opacity(0.3))
                    .transition(.opacity)
                    .accessibilityLabel("Can you feel it? The screen is dark to simulate visual impairment.")
            }
            
            Spacer()
                .frame(height: 50)
            
            // Braille cell
            if showDots {
                VStack(spacing: 25) {
                    // Dark Braille cell
                    ZStack {
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                            .frame(width: 180, height: 250)
                        
                        HStack(spacing: 50) {
                            // Left column (1-2-3)
                            VStack(spacing: 30) {
                                dot(index: 0, dotNumber: 1)
                                dot(index: 1, dotNumber: 2)
                                dot(index: 2, dotNumber: 3)
                            }
                            
                            // Right column (4-5-6)
                            VStack(spacing: 30) {
                                dot(index: 3, dotNumber: 4)
                                dot(index: 4, dotNumber: 5)
                                dot(index: 5, dotNumber: 6)
                            }
                        }
                    }
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Braille input cell. Enter the first letter of Insight.")
                }
                .transition(.opacity)
            }
            
            Spacer()
                .frame(height: 40)
            
            // Instruction
            if showInstruction {
                VStack(spacing: 12) {
                    Text("Enter the letter")
                        .font(.callout)
                        .foregroundColor(.white.opacity(0.25))
                    
                    Text("Insight")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white.opacity(0.4), .cyan.opacity(0.3)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("starts with")
                        .font(.callout)
                        .foregroundColor(.white.opacity(0.25))
                }
                .multilineTextAlignment(.center)
                .transition(.opacity)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Enter the letter that Insight starts with")
            }
            
            Spacer()
                .frame(height: 30)
            
            // Hint
            if showHint {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow.opacity(0.4))
                    Text("Dots 2 & 4")
                        .foregroundColor(.white.opacity(0.3))
                }
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.04))
                )
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .accessibilityLabel("Hint: The letter I uses dots 2 and 4")
            }
            
            Spacer()
        }
    }
    
    // MARK: - Dark Dot
    
    private func dot(index: Int, dotNumber: Int) -> some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(
                    dots[index] ? Color.cyan.opacity(0.6) : Color.white.opacity(0.1),
                    lineWidth: 2
                )
                .frame(width: 50, height: 50)
            
            // Fill when active
            if dots[index] {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.cyan.opacity(0.8), Color.blue.opacity(0.4)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 25
                        )
                    )
                    .frame(width: 50, height: 50)
                    .shadow(color: .cyan.opacity(0.5), radius: 12)
                    .transition(.scale.combined(with: .opacity))
            }
            
            // Subtle dot number
            Text("\(dotNumber)")
                .font(.caption2.weight(.medium))
                .foregroundColor(dots[index] ? .white.opacity(0.7) : .white.opacity(0.12))
        }
        .contentShape(Circle())
        .onTapGesture {
            toggleDot(at: index)
        }
        .accessibilityLabel("Dot \(dotNumber)")
        .accessibilityValue(dots[index] ? "Raised" : "Flat")
        .accessibilityHint("Double tap to toggle")
        .accessibilityAddTraits(.isButton)
    }
    
    // MARK: - Success View
    
    private var successView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Glowing "I"
            Text("I")
                .font(.system(size: 160, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .cyan],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .cyan.opacity(letterGlow ? 0.8 : 0.3), radius: letterGlow ? 40 : 20)
                .scaleEffect(successScale)
            
            Text("Welcome to")
                .font(.title3.weight(.light))
                .foregroundColor(.white.opacity(0.5))
            
            Text("Insight")
                .font(.system(size: 44, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .cyan.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Spacer()
        }
        .transition(.opacity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Correct! Welcome to Insight")
    }
    
    // MARK: - Logic
    
    private func toggleDot(at index: Int) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            dots[index].toggle()
        }
        HapticManager.shared.playHapticsSnap()
        
        // Check if the pattern matches "I"
        checkPattern()
    }
    
    private func checkPattern() {
        let activeDots = Set(dots.indices.filter { dots[$0] })
        
        if activeDots == targetDots {
            // Correct! "I" entered
            Task {
                try? await Task.sleep(for: .milliseconds(300))
                
                HapticManager.shared.playSuccess()
                
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                    isSuccess = true
                    successScale = 1.0
                }
                
                // Glow pulse
                if !reduceMotion {
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        letterGlow = true
                    }
                }
                
                // Navigate to home after celebration
                try? await Task.sleep(for: .seconds(2.5))
                HapticManager.shared.navigationHapticNext()
                navManager.navigate(to: .home)
            }
        }
    }
    
    private func startSequence() {
        Task {
            // Phase 1: Pure darkness (2 seconds)
            try? await Task.sleep(for: .seconds(2))
            
            // Phase 2: "Can you feel it?"
            withAnimation(.easeIn(duration: 1.5)) {
                showPrompt = true
            }
            
            try? await Task.sleep(for: .seconds(2))
            
            // Phase 3: Show Braille dots
            withAnimation(.easeIn(duration: 1.0)) {
                showDots = true
            }
            
            // Haptic pulse to draw attention
            HapticManager.shared.playSelection()
            
            try? await Task.sleep(for: .seconds(1))
            
            // Phase 4: Show instruction
            withAnimation(.easeIn(duration: 1.0)) {
                showInstruction = true
            }
            
            try? await Task.sleep(for: .seconds(5))
            
            // Phase 5: Show hint
            withAnimation(.easeIn(duration: 0.8)) {
                showHint = true
            }
            
            // Haptic nudge with the hint
            HapticManager.shared.playSelection()
        }
    }
}

#Preview {
    InsightChallengeView()
        .environmentObject(NavigationManager())
}
