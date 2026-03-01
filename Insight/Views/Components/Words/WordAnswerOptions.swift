//
//  WordAnswerOptions.swift
//  Insight
//
//  Created by Atakan on 28.02.2026.
//

import SwiftUI

/// Reusable word option buttons used in both portrait and landscape word-guess phases.
struct WordAnswerOptions: View {
    let options: [String]
    let correctWord: String
    let selectedAnswer: String?
    let isCorrect: Bool?
    let scale: CGFloat
    var compact: Bool = false
    
    let onSelect: (String) -> Void
    
    var body: some View {
        VStack(spacing: (compact ? 10 : 12) * scale) {
            ForEach(options, id: \.self) { word in
                Button(action: { onSelect(word) }) {
                    HStack {
                        Spacer()
                        Text(word)
                            .font(.system(compact ? .headline : .title2, design: .rounded).weight(.bold))
                        Spacer()
                        
                        if let selected = selectedAnswer, selected == word {
                            Image(systemName: isCorrect == true ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .font(compact ? .body : .title2)
                                .foregroundColor(isCorrect == true ? .green : .red)
                                .transition(.scale.combined(with: .opacity))
                        } else if selectedAnswer != nil && isCorrect == false && word == correctWord {
                            Image(systemName: "checkmark.circle.fill")
                                .font(compact ? .body : .title2)
                                .foregroundColor(.green)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, compact ? 16 : 20)
                    .padding(.vertical, (compact ? 12 : 14) * scale)
                    .background(
                        RoundedRectangle(cornerRadius: compact ? 14 : 16)
                            .fill(optionBackground(for: word))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: compact ? 14 : 16)
                            .stroke(optionBorder(for: word), lineWidth: 1)
                    )
                }
                .disabled(selectedAnswer != nil)
                .accessibilityLabel("Option: \(word)")
                .accessibilityHint(selectedAnswer == nil ? "Double tap to select" : "")
            }
        }
        .onChange(of: selectedAnswer) { _, newValue in
            guard let selected = newValue else { return }
            let correct = selected == correctWord
            let announcement = correct
                ? "Correct! The word is \(correctWord)"
                : "Incorrect. The word is \(correctWord)"
            UIAccessibility.post(notification: .announcement, argument: announcement)
        }
    }
    
    private func optionBackground(for word: String) -> Color {
        guard let selected = selectedAnswer else {
            return Color.white.opacity(0.08)
        }
        if selected == word {
            return isCorrect == true ? Color.green.opacity(0.2) : Color.red.opacity(0.2)
        }
        if isCorrect == false && word == correctWord {
            return Color.green.opacity(0.15)
        }
        return Color.white.opacity(0.08)
    }
    
    private func optionBorder(for word: String) -> Color {
        guard let selected = selectedAnswer else {
            return Color.white.opacity(0.1)
        }
        if selected == word {
            return isCorrect == true ? Color.green.opacity(0.5) : Color.red.opacity(0.5)
        }
        if isCorrect == false && word == correctWord {
            return Color.green.opacity(0.4)
        }
        return Color.white.opacity(0.1)
    }
}
