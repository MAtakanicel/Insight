//
//  IntroView.swift
//  Insight
//
//  Created by Atakan on 17.02.2026.
//

import SwiftUI

struct IntroView: View {
    @EnvironmentObject var navManager: NavigationManager
    @State private var currentPage = 0
    @State private var isAnimated = false
    @State private var dotScale: CGFloat = 0.5
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    private let totalPages = 3
    
    var body: some View {
        ZStack {
            // Dynamic background gradient based on page
            backgroundGradient
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.8), value: currentPage)
            
            VStack(spacing: 0) {
                // Page content
                TabView(selection: $currentPage) {
                    // MARK: - Page 1: The Problem
                    page1.tag(0)
                    
                    // MARK: - Page 2: What is Braille
                    page2.tag(1)
                    
                    // MARK: - Page 3: Call to Action
                    page3.tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentPage)
                
                // Custom page indicator
                pageIndicator
                    .padding(.bottom, 20)
                
                // Navigation buttons
                bottomButtons
                    .padding(.horizontal, 30)
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            if reduceMotion {
                isAnimated = true
            } else {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                    isAnimated = true
                }
            }
        }
        .accessibilityAction(.escape) {
            if currentPage > 0 {
                currentPage -= 1
            }
        }
    }
    
    // MARK: - Background
    
    private var backgroundGradient: some View {
        Group {
            switch currentPage {
            case 0:
                LinearGradient(
                    colors: [AppColors.introPage1Start, AppColors.introPage1End],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case 1:
                LinearGradient(
                    colors: [AppColors.introPage2Start, AppColors.introPage2End],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            default:
                LinearGradient(
                    colors: [AppColors.introPage3Start, AppColors.introPage3End],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
    }
    
    // MARK: - Page 1: The Problem
    
    private var page1: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Large statistic
            Text("285M")
                .font(.system(size: 90, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .scaleEffect(isAnimated ? 1 : 0.3)
                .opacity(isAnimated ? 1 : 0)
            
            Text("people worldwide live with\nvisual impairments")
                .font(.title2.weight(.medium))
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .opacity(isAnimated ? 1 : 0)
            
            Spacer()
            
            // Eye icon with subtle glow
            ZStack {
                Circle()
                    .fill(.white.opacity(0.05))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "eye.slash.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .scaleEffect(isAnimated ? 1 : 0.5)
            .opacity(isAnimated ? 1 : 0)
            
            Text("But there is a language\ndesigned for touch")
                .font(.title3.weight(.regular))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .italic()
            
            Spacer()
        }
        .padding(.horizontal, 30)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("285 million people worldwide live with visual impairments. But there is a language designed for touch.")
    }
    
    // MARK: - Page 2: What is Braille
    
    private var page2: some View {
        VStack(spacing: 25) {
            Spacer()
            
            Text("Braille")
                .font(.system(size: 60, weight: .black, design: .serif))
                .foregroundColor(.white)
            
            Text("A system of raised dots that can be\nfelt with fingertips")
                .font(.title3.weight(.medium))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            Spacer()
            
            // Interactive Braille cell demo - showing letter "A"
            brailleCellDemo
            
            Text("Each character is represented by\na pattern of up to 6 dots")
                .font(.callout)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
            
            Spacer()
            
            // Louis Braille credit
            VStack(spacing: 5) {
                Text("Invented by")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.4))
                Text("Louis Braille, 1824")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(.horizontal, 30)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Braille. A system of raised dots that can be felt with fingertips. Each character is represented by a pattern of up to 6 dots. Invented by Louis Braille in 1824.")
    }
    
    // MARK: - Page 3: Call to Action
    
    private var page3: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // App icon / name
            ZStack {
                Circle()
                    .fill(.white.opacity(0.1))
                    .frame(width: 140, height: 140)
                
                Circle()
                    .fill(.white.opacity(0.05))
                    .frame(width: 180, height: 180)
                
                Image("Icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .shadow(color: .cyan.opacity(0.3), radius: 15, y: 5)
            }
            .scaleEffect(dotScale)
            .onAppear {
                if reduceMotion {
                    dotScale = 1.0
                } else {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.5).delay(0.3)) {
                        dotScale = 1.0
                    }
                }
            }
            
            Text("Insight")
                .font(.system(size: 50, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .cyan.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text("Learn Braille through\ntouch and haptics")
                .font(.title3.weight(.medium))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            Spacer()
            
            // Features preview
            VStack(spacing: 15) {
                featureRow(icon: "hand.point.up.left.fill", text: "Interactive Braille cells")
                featureRow(icon: "waveform", text: "Haptic feedback patterns")
                featureRow(icon: "gamecontroller.fill", text: "Challenge yourself with quizzes")
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding(.horizontal, 30)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Insight. Learn Braille through touch and haptics. Features include interactive Braille cells, haptic feedback patterns, and challenge quizzes.")
    }
    
    // MARK: - Components
    
    private var brailleCellDemo: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.white.opacity(0.08))
                .frame(width: 160, height: 220)
            
            HStack(spacing: 40) {
                // Left column (1-2-3)
                VStack(spacing: 25) {
                    introDot(active: true)   // Dot 1 - "A" has dot 1
                    introDot(active: false)  // Dot 2
                    introDot(active: false)  // Dot 3
                }
                
                // Right column (4-5-6)
                VStack(spacing: 25) {
                    introDot(active: false)  // Dot 4
                    introDot(active: false)  // Dot 5
                    introDot(active: false)  // Dot 6
                }
            }
            
            // Letter label
            Text("= A")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.cyan.opacity(0.8))
                .offset(x: 80, y: -80)
        }
    }
    
    private func introDot(active: Bool) -> some View {
        Circle()
            .fill(active ? Color.cyan : Color.white.opacity(0.15))
            .frame(width: 35, height: 35)
            .overlay(
                Circle()
                    .stroke(active ? Color.cyan.opacity(0.5) : Color.white.opacity(0.1), lineWidth: 2)
            )
            .shadow(color: active ? .cyan.opacity(0.4) : .clear, radius: 8)
    }
    
    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.cyan)
                .frame(width: 35)
            
            Text(text)
                .font(.callout.weight(.medium))
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 15)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.05))
        )
    }
    
    // MARK: - Page Indicator
    
    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Capsule()
                    .fill(currentPage == index ? Color.cyan : Color.white.opacity(0.3))
                    .frame(width: currentPage == index ? 24 : 8, height: 8)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
            }
        }
    }
    
    // MARK: - Bottom Buttons
    
    private var bottomButtons: some View {
        HStack {
            if currentPage > 0 {
                Button(action: {
                    HapticManager.shared.playSelection()
                    withAnimation { currentPage -= 1 }
                }) {
                    Text("Back")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.horizontal, 25)
                        .padding(.vertical, 14)
                }
                .accessibilityLabel("Go to previous page")
            }
            
            Spacer()
            
            if currentPage < totalPages - 1 {
                Button(action: {
                    HapticManager.shared.playSelection()
                    withAnimation { currentPage += 1 }
                }) {
                    HStack(spacing: 8) {
                        Text("Next")
                            .font(.headline)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(Color.cyan.opacity(0.3))
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.cyan.opacity(0.5), lineWidth: 1)
                    )
                }
                .accessibilityLabel("Go to next page")
            } else {
                Button(action: {
                    HapticManager.shared.navigationHapticNext()
                    navManager.navigate(to: .insightChallenge)
                }) {
                    HStack(spacing: 8) {
                        Text("Start Learning")
                            .font(.headline.bold())
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.cyan, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .shadow(color: .cyan.opacity(0.4), radius: 10, y: 5)
                }
                .accessibilityLabel("Start learning Braille")
                .accessibilityHint("Navigates to the main menu")
            }
        }
    }
}

#Preview {
    IntroView()
        .environmentObject(NavigationManager())
}
