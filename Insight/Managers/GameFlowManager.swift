//
//  GameFlowManager.swift
//  Insight
//
//  Created by Atakan on 26.02.2026.
//

import SwiftUI

/// Shared game flow utilities for Classic & Dark game modes.
/// Eliminates code duplication in QuizGameView and DarkGameView.
@MainActor
enum GameFlowManager {
    
    /// Plays the standard shake animation on incorrect answers.
    static func playShakeAnimation(_ shakeOffset: Binding<CGFloat>) async {
        withAnimation(.spring(response: 0.1, dampingFraction: 0.2)) {
            shakeOffset.wrappedValue = -10
        }
        try? await Task.sleep(for: .milliseconds(100))
        withAnimation(.spring(response: 0.1, dampingFraction: 0.2)) {
            shakeOffset.wrappedValue = 10
        }
        try? await Task.sleep(for: .milliseconds(100))
        withAnimation(.spring(response: 0.1, dampingFraction: 0.5)) {
            shakeOffset.wrappedValue = 0
        }
    }
    
    /// Advances to the next question or triggers game end after a delay.
    static func advanceQuestion(
        questionNumber: Binding<Int>,
        maxQuestions: Int,
        showGameEnd: Binding<Bool>,
        selectedAnswer: Binding<String?>,
        showResult: Binding<Bool>,
        generateNext: @escaping () -> Void
    ) async {
        try? await Task.sleep(for: .seconds(1))
        if questionNumber.wrappedValue >= maxQuestions {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showGameEnd.wrappedValue = true
            }
        } else {
            withAnimation {
                questionNumber.wrappedValue += 1
                selectedAnswer.wrappedValue = nil
                showResult.wrappedValue = false
                generateNext()
            }
        }
    }
    
    /// Resets state shared by QuizGameView and DarkGameView and starts a new round.
    /// WordsGameView has its own reset because it carries different state variables.
    static func restartStandardGame(
        showGameEnd: Binding<Bool>,
        questionNumber: Binding<Int>,
        selectedAnswer: Binding<String?>,
        showResult: Binding<Bool>,
        viewModel: BrailleViewModel
    ) {
        withAnimation {
            showGameEnd.wrappedValue = false
            questionNumber.wrappedValue = 1
            selectedAnswer.wrappedValue = nil
            showResult.wrappedValue = false
            viewModel.gameScore = 0
            viewModel.generateQuestion()
        }
    }
}
