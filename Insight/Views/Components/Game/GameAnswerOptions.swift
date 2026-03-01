//
//  GameAnswerOptions.swift
//  Insight
//
//  Created by Atakan on 20.02.2026.
//

import SwiftUI

struct GameAnswerOptions: View {
    let options: [String]
    let targetLetter: String
    let selectedAnswer: String?
    let showResult: Bool
    let isCorrect: Bool
    let shakeOffset: CGFloat
    var compact: Bool = false
    
    let onSelect: (String) -> Void
    
    var body: some View {
        Group {
            if options.isEmpty {
                VStack(spacing: 12) {
                    Text("Get Ready...")
                        .font(.title2.weight(.bold))
                        .foregroundColor(.white.opacity(0.4))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.opacity)
            } else {
                VStack(spacing: compact ? 6 : 12) {
                    ForEach(options, id: \.self) { option in
                        Button(action: {
                            onSelect(option)
                        }) {
                            HStack(alignment: .center) {
                                Spacer()
                                Text(option)
                                    .font(compact ? .headline : .system(.title2, design: .rounded).weight(.bold))
                                
                                Spacer()
                                
                                if showResult {
                                    if selectedAnswer == option {
                                        Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                            .font(compact ? .body : .title2)
                                            .foregroundColor(isCorrect ? .green : .red)
                                            .transition(.scale.combined(with: .opacity))
                                    } else if !isCorrect && option == targetLetter {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(compact ? .body : .title2)
                                            .foregroundColor(.green)
                                            .transition(.scale.combined(with: .opacity))
                                    }
                                }
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, compact ? 14 : 20)
                            .padding(.vertical, compact ? 8 : 14)
                            .background(
                                RoundedRectangle(cornerRadius: compact ? 12 : 16)
                                    .fill(optionBackground(for: option))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: compact ? 12 : 16)
                                    .stroke(optionBorder(for: option), lineWidth: 1)
                            )
                        }
                        .disabled(showResult)
                        .accessibilityLabel("Option: Letter \(option)")
                        .accessibilityHint("Double tap to select this answer")
                    }
                }
                .frame(maxWidth: 400)
                .padding(.horizontal, compact ? 20 : 30)
                .offset(x: shakeOffset)
            }
        }
        .onChange(of: showResult) { _, newValue in
            guard newValue else { return }
            let announcement = isCorrect
                ? "Correct!"
                : "Incorrect. The answer is \(targetLetter)"
            UIAccessibility.post(notification: .announcement, argument: announcement)
        }
    }
    
    private func optionBackground(for option: String) -> Color {
        guard showResult else {
            return Color.white.opacity(0.08)
        }
        if selectedAnswer == option {
            return isCorrect ? Color.green.opacity(0.2) : Color.red.opacity(0.2)
        }
        if !isCorrect && option == targetLetter {
            return Color.green.opacity(0.15)
        }
        return Color.white.opacity(0.08)
    }
    
    private func optionBorder(for option: String) -> Color {
        guard showResult else {
            return Color.white.opacity(0.1)
        }
        if selectedAnswer == option {
            return isCorrect ? Color.green.opacity(0.5) : Color.red.opacity(0.5)
        }
        if !isCorrect && option == targetLetter {
            return Color.green.opacity(0.4)
        }
        return Color.white.opacity(0.1)
    }
}


