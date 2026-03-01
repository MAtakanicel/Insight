//
//  GameEndView.swift
//  Insight
//
//  Created by Atakan on 18.02.2026.
//

import SwiftUI

enum CompletedGame {
    case practice, blindfold, decipher
    
    var empathyMessage: String {
        switch self {
        case .practice:
            return "You read Braille with your eyes. The visually impaired read it with their fingertips — at incredible speed."
        case .blindfold:
            return "For 285 million people, this darkness is everyday life. You felt it for just a moment."
        case .decipher:
            return "You decoded a full word through touch alone. Braille literacy opens doors to education and independence."
        }
    }
}

struct GameEndView: View {
    var score: Int
    var gameMode: CompletedGame
    var showMasteryButton: Bool = false
    var restartGame: () -> Void
    var onBack: () -> Void
    var onMastery: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Trophy
            ZStack {
                Circle()
                    .fill(Color.yellow.opacity(0.1))
                    .frame(minWidth: 80, maxWidth: 140, minHeight: 80, maxHeight: 140)
                
                Image(systemName: scoreIcon)
                    .font(.system(size: 50))
                    .foregroundStyle(
                        LinearGradient(
                            colors: scoreGradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            Text(scoreTitle)
                .font(.system(.title, design: .rounded).weight(.black))
                .foregroundColor(.white)
            
            VStack(spacing: 4) {
                Text("You scored")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.5))
                
                Text("\(score)")
                    .font(.system(size: 56, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.cyan, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("points")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            // Empathy message
            Text(gameMode.empathyMessage)
                .font(.footnote)
                .italic()
                .foregroundColor(.white.opacity(0.45))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)
                .padding(.top, 4)
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 12) {
                // Mastery button — only when all 3 games are done
                if showMasteryButton {
                    Button(action: { onMastery?() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                            Text("See Your Insight")
                                .font(.headline)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(
                                    LinearGradient(
                                        colors: [.yellow, .orange],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                    }
                    .accessibilityLabel("See your full journey")
                    .transition(.scale.combined(with: .opacity))
                }
                
                Button(action: restartGame) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Play Again")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: [.cyan, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
                .accessibilityLabel("Play again")
                
                Button(action: onBack) {
                    Text("Back to Challenge")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.08))
                        )
                }
                .accessibilityLabel("Return to Game Mode Menu")
            }
            .frame(maxWidth: 400)
            .padding(.horizontal, 40)
            .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .contain)
    }
    
    private var scoreIcon: String {
        if score >= 70 { return "trophy.fill" }
        if score >= 40 { return "star.fill" }
        return "hand.thumbsup.fill"
    }
    
    private var scoreGradient: [Color] {
        if score >= 70 { return [.yellow, .orange] }
        if score >= 40 { return [.cyan, .blue] }
        return [.white.opacity(0.6), .white.opacity(0.3)]
    }
    
    private var scoreTitle: String {
        if score >= 70 { return "Amazing!" }
        if score >= 40 { return "Great Job!" }
        return "Keep Practicing!"
    }
}

#Preview {
    GameEndView(
        score: 80,
        gameMode: .blindfold,
        showMasteryButton: true,
        restartGame: {},
        onBack: {}
    )
    .background(Color.black)
}
