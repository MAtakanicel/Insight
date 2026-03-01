//
//  LockedBrailleCard.swift
//  Insight
//
//  Created by Atakan on 28.02.2026.
//

import SwiftUI

/// Displays a row of small Braille cells at the top of the Words Game,
/// showing revealed patterns and "?" placeholders for unrevealed letters.
struct LockedBrailleCard: View {
    let word: String
    let revealLetters: [Bool]
    let currentLetterIndex: Int
    let showWordGuess: Bool
    let isAnimated: Bool
    let scale: CGFloat
    
    /// Provides 6-element Bool array for a given cell index.
    let dotStatesProvider: (Int) -> [Bool]
    
    var body: some View {
        HStack(spacing: 12 * scale) {
            ForEach(0..<word.count, id: \.self) { cell in
                cellView(cell, size: 10 * scale)
            }
        }
    }
    
    private func cellView(_ cell: Int, size: CGFloat) -> some View {
        let dotStates = dotStatesProvider(cell)
        let isRevealed = cell < revealLetters.count && revealLetters[cell]
        let isCurrent = cell == currentLetterIndex && !showWordGuess
        
        return ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(isCurrent ? 0.12 : 0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            isCurrent ? Color.cyan.opacity(0.8) :
                            isRevealed ? Color.green.opacity(0.5) :
                            Color.white.opacity(0.2),
                            lineWidth: isCurrent ? 1.5 : 0.8
                        )
                )
            
            if isRevealed {
                HStack(spacing: size * 0.5) {
                    VStack(spacing: size * 0.4) {
                        BrailleDot(id: 0, isOn: dotStates[0], isHiddenLine: true, size: size)
                        BrailleDot(id: 1, isOn: dotStates[1], isHiddenLine: true, size: size)
                        BrailleDot(id: 2, isOn: dotStates[2], isHiddenLine: true, size: size)
                    }
                    VStack(spacing: size * 0.4) {
                        BrailleDot(id: 3, isOn: dotStates[3], isHiddenLine: true, size: size)
                        BrailleDot(id: 4, isOn: dotStates[4], isHiddenLine: true, size: size)
                        BrailleDot(id: 5, isOn: dotStates[5], isHiddenLine: true, size: size)
                    }
                }
                .padding(size * 0.25)
                .transition(.scale.combined(with: .opacity))
            } else {
                Text("?")
                    .font(.system(size: size * 2, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.3))
            }
        }
        .frame(width: 45 * scale, height: 55 * scale)
        .offset(y: isAnimated ? 0 : 100)
        .opacity(isAnimated ? 1 : 0)
    }
}
