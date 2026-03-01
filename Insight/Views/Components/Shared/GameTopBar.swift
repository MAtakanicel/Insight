//
//  GameTopBar.swift
//  Insight
//
//  Created by Atakan on 18.02.2026.
//

import SwiftUI

struct GameTopBar: View {
    var score: Int
    var onBack: () -> Void
    
    var body: some View {
        HStack {
            // Back button
            Button(action: {
                HapticManager.shared.navigationHapticBack()
                onBack()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                        .bold()
                    Text("Challenge")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundColor(.white.opacity(0.8))
                .padding(.vertical, 10)
                .padding(.horizontal, 15)
                .background(Color.white.opacity(0.1))
                .clipShape(Capsule())
            }
            .accessibilityLabel("Back to Game Mode Menu")
            
            Spacer()
            
            // Score display
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("\(score)")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.3), value: score)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(Color.white.opacity(0.1))
            .clipShape(Capsule())
            .accessibilityLabel("Score: \(score) points")
        }
        .padding(.horizontal, 15)
        .padding(.top, 10)
    }
}
