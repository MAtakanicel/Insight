//
//  HomeView.swift
//  Insight
//
//  Created by Atakan on 5.02.2026.
//

import SwiftUI
import UIKit

struct HomeView: View {
    @EnvironmentObject var navManager: NavigationManager
    @State private var isAnimated = false
    @State private var cardPulse = false

    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        ZStack {
            // Dark background
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                Spacer(minLength: 0)
                
                // App header
                VStack(spacing: 8) {
                    Text("Insight")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Feel the Braille")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.white.opacity(0.4))
                        .tracking(3)
                        .textCase(.uppercase)
                }
                .padding(.top, 50)
                .padding(.bottom, 30)
                .opacity(isAnimated ? 1 : 0)
                .offset(y: isAnimated ? 0 : -20)
                    
                Spacer()
                
                // MARK: - Learn Mode Card
                Button(action: {
                    HapticManager.shared.navigationHapticNext()
                    navManager.navigate(to: .learn)
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 28)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        AppColors.blueGradientStart,
                                        AppColors.blueGradientEnd
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Color.blue.opacity(0.3), radius: 20, y: 10)
                        
                        // Subtle glow
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.white.opacity(0.05))
                            .scaleEffect(cardPulse ? 1.02 : 1.0)
                        
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(.white.opacity(0.1))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "hand.point.up.braille.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(.white)
                            }
                            
                            Text("LEARN")
                                .font(.system(size: 32, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Discover the Braille Alphabet")
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .frame(maxWidth: 600)
                    .frame(minHeight: 80, idealHeight: 150, maxHeight: 300)
                    .padding(.horizontal, 40)
                }
                .accessibilityLabel("Learn Mode")
                .accessibilityHint("Opens the Braille alphabet tutorial where you can explore each letter")
                .accessibilityAddTraits(.isButton)
                .scaleEffect(isAnimated ? 1 : 0.9)
                .opacity(isAnimated ? 1 : 0)
                
                Spacer()
                    .frame(minHeight: 25, maxHeight: 50)
                
                // MARK: - Challenge Mode Card
                Button(action: {
                    HapticManager.shared.navigationHapticNext()
                    navManager.navigate(to: .game)
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 28)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        AppColors.orangeGradientStart,
                                        AppColors.orangeGradientEnd
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Color.orange.opacity(0.3), radius: 20, y: 10)
                        
                        // Subtle glow
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.white.opacity(0.05))
                            .scaleEffect(cardPulse ? 1.02 : 1.0)
                        
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(.white.opacity(0.1))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "gamecontroller.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(.white)
                            }
                            
                            Text("CHALLENGE")
                                .font(.system(size: 32, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Test Your Braille Knowledge")
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .frame(maxWidth: 600)
                    .frame(minHeight: 80, idealHeight: 150, maxHeight: 300)
                    .padding(.horizontal, 40)
                }
                .accessibilityLabel("Challenge Mode")
                .accessibilityHint("Starts a quiz game to test your Braille skills")
                .accessibilityAddTraits(.isButton)
                .scaleEffect(isAnimated ? 1 : 0.9)
                .opacity(isAnimated ? 1 : 0)
                
                Spacer(minLength: 16)
                
                    HStack(spacing: 6) {
                        Image(systemName: "speaker.wave.3.fill")
                        Text("Best experienced with sound on")
                    }
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.bottom, 20)
                
            }
        }
        .overlay(
            Button {
                HapticManager.shared.navigationHapticBack()
                navManager.navigate(to: .intro)
            } label: {
                Image(systemName: "arrow.left")
                    .font(.caption)
                    .foregroundColor(.white)
                   

                Text("Intro")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.4))
                
                Image(systemName: "sparkles")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.4))
            }
                .padding(5)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppColors.cardFill)
                )
                .padding(.top,10)
                .padding(.leading, 15)
                .accessibilityLabel("Replay intro experience")
                .scaleEffect(isAnimated ? 1 : 0.9)
                .opacity(isAnimated ? 1 : 0)
            ,alignment: .topLeading)

        .onAppear {
            if reduceMotion {
                isAnimated = true
            } else {
                withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                    isAnimated = true
                }
                // Subtle pulse animation
                withAnimation(.easeInOut(duration: 2)
                    .repeatForever(autoreverses: true)) {
                    cardPulse = true
 
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(NavigationManager())
}
