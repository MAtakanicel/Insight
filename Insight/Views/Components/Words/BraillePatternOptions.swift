//
//  BraillePatternOptions.swift
//  Insight
//
//  Created by Atakan on 28.02.2026.
//

import SwiftUI

/// A 2×2 grid of Braille pattern options for the letter-guessing phase of Words Game.
struct BraillePatternOptions: View {
    let options: [[Int]]
    let selectedIndex: Int?
    let isCorrect: Bool?
    let scale: CGFloat
    var maxWidth: CGFloat? = nil
    
    let onSelect: (Int) -> Void
    
    private var gridMaxWidth: CGFloat { maxWidth ?? (200 * scale) }
    private var dotSize: CGFloat { maxWidth != nil ? (gridMaxWidth * 0.08) : (16 * scale) }
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12 * scale) {
            ForEach(options.indices, id: \.self) { index in
                let pattern = BrailleData.shared.pattern(options[index])
                let isSelected = selectedIndex == index
                
                Button(action: {
                    guard selectedIndex == nil else { return }
                    onSelect(index)
                }) {
                    cellView(pattern: pattern, isSelected: isSelected)
                        .aspectRatio(0.8, contentMode: .fit)
                }
                .disabled(selectedIndex != nil)
                .accessibilityLabel(accessibilityLabel(for: options[index]))
                .accessibilityHint(selectedIndex == nil ? "Double tap to select this Braille pattern" : "")
            }
        }
        .frame(maxWidth: gridMaxWidth)
        .onChange(of: selectedIndex) { _, _ in
            guard let correct = isCorrect else { return }
            let announcement = correct
                ? "Correct!"
                : "Incorrect. Try again"
            UIAccessibility.post(notification: .announcement, argument: announcement)
        }
    }
    
    private func cellView(pattern: [Bool], isSelected: Bool) -> some View {
        let bgColor: Color = {
            guard isSelected, let correct = isCorrect else {
                return Color.white.opacity(0.06)
            }
            return correct ? Color.green.opacity(0.2) : Color.red.opacity(0.2)
        }()
        
        let borderColor: Color = {
            guard isSelected, let correct = isCorrect else {
                return Color.white.opacity(0.15)
            }
            return correct ? Color.green.opacity(0.6) : Color.red.opacity(0.6)
        }()
        
        return ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(bgColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(borderColor, lineWidth: 1)
                )
            
            HStack(spacing: dotSize * 0.6) {
                VStack(spacing: dotSize * 0.45) {
                    BrailleDot(id: 0, isOn: pattern[0], isHiddenLine: true, size: dotSize)
                    BrailleDot(id: 1, isOn: pattern[1], isHiddenLine: true, size: dotSize)
                    BrailleDot(id: 2, isOn: pattern[2], isHiddenLine: true, size: dotSize)
                }
                VStack(spacing: dotSize * 0.45) {
                    BrailleDot(id: 3, isOn: pattern[3], isHiddenLine: true, size: dotSize)
                    BrailleDot(id: 4, isOn: pattern[4], isHiddenLine: true, size: dotSize)
                    BrailleDot(id: 5, isOn: pattern[5], isHiddenLine: true, size: dotSize)
                }
            }
            .allowsHitTesting(false)
            .padding(6)
        }
        .contentShape(RoundedRectangle(cornerRadius: 14))
    }
    
    /// Describes the Braille pattern in plain language for VoiceOver.
    /// e.g. [1,3,4] active → "Braille pattern: dots 1, 3, 4 raised"
    private func accessibilityLabel(for dotNumbers: [Int]) -> String {
        let active = dotNumbers
            .enumerated()
            .compactMap { $0.element != 0 ? $0.offset + 1 : nil }
        if active.isEmpty {
            return "Braille pattern: no dots raised"
        }
        let dotList = active.map { String($0) }.joined(separator: ", ")
        return "Braille pattern: dots \(dotList) raised"
    }
}
