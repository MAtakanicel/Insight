//
//  LearnView.swift
//  Insight
//
//  Created by Atakan on 5.02.2026.
//

import SwiftUI

struct LearnView: View {
    @ObservedObject var vm: BrailleViewModel
    @EnvironmentObject var navManager: NavigationManager
    
    @State private var isViewAnimated = false
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        GeometryReader { geo in
            // cardWidth: hem genişlik hem yüksekliğe göre kısıtlanır → landscape iPad'de taşmaz
            let cardWidth = min(geo.size.width * 0.6, geo.size.height * 0.42, 600)
            let dotSize   = cardWidth * 0.25
            let vSpacing  = cardWidth * 0.15
            let hSpacing  = cardWidth * 0.30

            ZStack {
                // Dark background
                AppColors.background
                    .ignoresSafeArea()

                // Background decoration (large faded letter)
                Text(vm.currentLetter)
                    .font(.system(size: 300, weight: .black))
                    .foregroundColor(Color.cyan.opacity(0.03))
                    .offset(x: 80, y: 80)
                    .blur(radius: 3)

                VStack(spacing: 20) {
                    // MARK: - Top Bar
                    HStack {
                        Button(action: {
                            HapticManager.shared.navigationHapticBack()
                            navManager.navigate(to: .home)
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "chevron.left")
                                    .bold()
                                Text("Menu")
                                    .font(.subheadline.weight(.semibold))
                            }
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.vertical, 10)
                            .padding(.horizontal, 15)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Capsule())
                        }
                        .accessibilityLabel("Back to Menu")

                        Spacer()

                        // Letter counter
                        Text("\(currentLetterIndex + 1) / 26")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.white.opacity(0.4))
                            .padding(.vertical, 10)
                            .padding(.horizontal, 15)
                            .background(Color.white.opacity(0.05))
                            .clipShape(Capsule())
                            .accessibilityLabel("Letter \(currentLetterIndex + 1) of 26")
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .scaleEffect(isViewAnimated ? 1 : 0.9)
                    .opacity(isViewAnimated ? 1 : 0)

                    Spacer()

                    // MARK: - Navigation & Letter
                    HStack(spacing: 30) {
                        // Previous button
                        Button(action: {
                            SoundManager.shared.playNavClick()
                            vm.previousLetter()
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.title2.bold())
                                .foregroundColor(vm.currentLetter == "A" ? .gray.opacity(0.3) : .white)
                                .frame(width: 60, height: 60)
                                .background(
                                    Circle()
                                        .fill(vm.currentLetter == "A" ? Color.white.opacity(0.05) : Color.cyan.opacity(0.3))
                                )
                                .overlay(
                                    Circle()
                                        .stroke(vm.currentLetter == "A" ? Color.clear : Color.cyan.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .disabled(vm.currentLetter == "A")
                        .accessibilityLabel("Previous Letter")

                        // Current letter
                        Text(vm.currentLetter)
                            .font(.system(size: 80, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, .cyan.opacity(0.8)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 100)
                            .id("LetterChange-\(vm.currentLetter)")
                            .transition(.scale.combined(with: .opacity))
                            .accessibilityLabel("Letter \(vm.currentLetter)")

                        // Next button
                        Button(action: {
                            SoundManager.shared.playNavClick()
                            vm.nextLetter()
                        }) {
                            Image(systemName: "arrow.right")
                                .font(.title2.bold())
                                .foregroundColor(vm.currentLetter == "Z" ? .gray.opacity(0.3) : .white)
                                .frame(width: 60, height: 60)
                                .background(
                                    Circle()
                                        .fill(vm.currentLetter == "Z" ? Color.white.opacity(0.05) : Color.cyan.opacity(0.3))
                                )
                                .overlay(
                                    Circle()
                                        .stroke(vm.currentLetter == "Z" ? Color.clear : Color.cyan.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .disabled(vm.currentLetter == "Z")
                        .accessibilityLabel("Next Letter")
                    }
                    .padding(.bottom, 20)

                    // MARK: - Braille Card (no nested GeometryReader)
                    ZStack {
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color.white.opacity(0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                            .shadow(color: Color.cyan.opacity(0.05), radius: 20, x: 0, y: 10)

                        HStack(spacing: hSpacing) {
                            // Left Column (1-2-3)
                            VStack(spacing: vSpacing) {
                                BrailleDot(id: 1, isOn: vm.dots[0], size: dotSize, showDotId: true)
                                BrailleDot(id: 2, isOn: vm.dots[1], size: dotSize, showDotId: true)
                                BrailleDot(id: 3, isOn: vm.dots[2], size: dotSize, showDotId: true)
                            }
                            // Right Column (4-5-6)
                            VStack(spacing: vSpacing) {
                                BrailleDot(id: 4, isOn: vm.dots[3], size: dotSize, showDotId: true)
                                BrailleDot(id: 5, isOn: vm.dots[4], size: dotSize, showDotId: true)
                                BrailleDot(id: 6, isOn: vm.dots[5], size: dotSize, showDotId: true)
                            }
                        }
                        .padding(40)
                    }
                    .frame(width: cardWidth, height: cardWidth * 1.3)
                    .offset(y: isViewAnimated ? 0 : 100)
                    .opacity(isViewAnimated ? 1 : 0)
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Braille cell for letter \(vm.currentLetter)")

                    Spacer()

                    // MARK: - Feel the Pattern button
                    Button(action: {
                        vm.playCurrentLetterHaptic()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "waveform")
                                .font(.body.bold())
                            Text("Feel the Pattern")
                                .font(.headline)
                        }
                        .foregroundColor(.cyan)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(Color.cyan.opacity(0.15))
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .accessibilityLabel("Feel the Braille pattern")
                    .accessibilityHint("Plays a haptic vibration representing the letter \(vm.currentLetter)")

                    Spacer()
                }
            }
        }
        .onAppear {
            vm.showLetter(vm.currentLetter)
            if reduceMotion {
                isViewAnimated = true
            } else {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isViewAnimated = true
                }
            }
        }
    }
    
    private var currentLetterIndex: Int {
        BrailleData.shared.allLetters.firstIndex(of: vm.currentLetter) ?? 0
    }
}

#Preview {
    LearnView(vm: BrailleViewModel())
        .environmentObject(NavigationManager())
}
