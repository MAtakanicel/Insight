//
//  GameQuestionPrompt.swift
//  Insight
//
//  Created by Atakan on 20.02.2026.
//

import SwiftUI



struct GameQuestionPrompt: View {
    let maxQuestions: Int
    let currentQuestion: Int
    
    
    var body: some View {
        VStack(spacing: 8) {

            Text("Question \(currentQuestion) of \(maxQuestions)")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.cyan.opacity(0.35))
            
            Text("Which Letter is this?")
                .font(.title3.weight(.semibold))
                .foregroundColor(.cyan.opacity(0.6))
                .multilineTextAlignment(.center)
            
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Question \(currentQuestion) of \(maxQuestions). Which Letter is this?")
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        GameQuestionPrompt(maxQuestions: 5, currentQuestion: 1)
    }
}
