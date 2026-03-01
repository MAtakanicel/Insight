//
//  MasteryView.swift
//  Insight
//
//  Created by Atakan on 28.02.2026.
//

import SwiftUI

struct MasteryView: View {
    @EnvironmentObject var navManager: NavigationManager
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isAnimated = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    AppColors.masteryGradientTop,
                    AppColors.masteryGradientBottom
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Main icon
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.yellow.opacity(0.2), Color.clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                    
                    Text("✦")
                        .font(.system(size: 70))
                }
                .scaleEffect(isAnimated ? 1 : 0.5)
                .opacity(isAnimated ? 1 : 0)
                
                Spacer().frame(height: 32)
                
                // Title
                VStack(spacing: 10) {
                    Text("You Have Insight")
                        .font(.system(.largeTitle, design: .rounded).weight(.black))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("All three challenges completed")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.white.opacity(0.45))
                }
                .opacity(isAnimated ? 1 : 0)
                .offset(y: isAnimated ? 0 : 20)
                
                Spacer().frame(height: 40)
                
                // Core stat
                VStack(spacing: 16) {
                    statCard(
                        number: "285M",
                        label: "people live with visual impairment worldwide",
                        icon: "eye.slash"
                    )
                    statCard(
                        number: "1 in 10",
                        label: "blind people in the US can read Braille",
                        icon: "hand.point.up.braille"
                    )
                }
                .padding(.horizontal, 36)
                .opacity(isAnimated ? 1 : 0)
                .offset(y: isAnimated ? 0 : 30)
                
                Spacer().frame(height: 40)
                
                // Closing message
                Text("\"You now understand, even for a moment, what it means to navigate the world through touch.\"")
                    .font(.callout)
                    .italic()
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(isAnimated ? 1 : 0)
                
                Spacer()
                
                // Back button
                Button(action: {
                    HapticManager.shared.navigationHapticBack()
                    navManager.navigate(to: .home)
                }) {
                    Text("Back to Home")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                )
                        )
                }
                .frame(maxWidth: 400)
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
                .opacity(isAnimated ? 1 : 0)
            }
        }
        .onAppear {
            if reduceMotion {
                isAnimated = true
            } else {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.75).delay(0.1)) {
                    isAnimated = true
                }
            }
        }
    }
    
    private func statCard(number: String, label: String, icon: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.cyan.opacity(0.7))
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(number)
                    .font(.system(.title2, design: .rounded).weight(.black))
                    .foregroundColor(.white)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.45))
            }
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

#Preview {
    MasteryView()
        .environmentObject(NavigationManager())
}
