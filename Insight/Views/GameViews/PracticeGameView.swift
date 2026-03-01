//
//  QuizGameView.swift
//  Insight
//
//  Created by Atakan on 5.02.2026.
//

import SwiftUI

struct QuizGameView: View {
    @ObservedObject var vm: BrailleViewModel
    @EnvironmentObject var navManager: NavigationManager
    
    @State private var isViewAnimated = false
    @State private var selectedAnswer: String? = nil
    @State private var showResult = false
    @State private var isCorrect = false
    @State private var shakeOffset: CGFloat = 0
    @State private var questionNumber = 1
    @State private var showGameEnd = false

    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    var maxQuestions = GameConstants.questionsPerGame
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    AppColors.gameGradientTop,
                    AppColors.gameGradientBottom
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if showGameEnd {
                GameEndView(
                    score: vm.gameScore,
                    gameMode: .practice,
                    showMasteryButton: navManager.allGamesCompleted,
                    restartGame: restartGame,
                    onBack: { navManager.navigate(to: .game) },
                    onMastery: { navManager.navigate(to: .mastery) }
                )
            } else {
                gameContent
            }
        }
        .onAppear {
            Task {
                vm.generateQuestion()
            }
            if !reduceMotion {
                withAnimation(.easeOut(duration: 0.5)) {
                    isViewAnimated = true
                }
            } else {
                isViewAnimated = true
            }
        }
        .onDisappear {
            vm.resetGameState()
        }
        .onChange(of: showGameEnd) {
            if showGameEnd {
                navManager.completedPractice = true
            }
        }
    }
    
    // MARK: - Game Content
    
    private var gameContent: some View {
        VStack(spacing: 0) {
            GameTopBar(
                score: vm.gameScore
            ) { navManager.navigate(to: .game) }
            
            Spacer()
            
            GameQuestionPrompt(
                maxQuestions: maxQuestions,
                currentQuestion: questionNumber
            )
            .padding(.bottom, 10)
            
            Spacer()
            
            mysteryBrailleCell
            
            Spacer()
            
            GameAnswerOptions(
                options: vm.gameOptions,
                targetLetter: vm.targetLetter,
                selectedAnswer: selectedAnswer,
                showResult: showResult,
                isCorrect: isCorrect,
                shakeOffset: shakeOffset
            ) { option in
                handleAnswer(option)
            }
            .id(questionNumber)
            .containerRelativeFrame(.vertical){ length,_ in
                length * 0.3
            }
            
            Spacer().frame(height: 20)
        }
        
        .opacity(isViewAnimated ? 1 : 0)
       .onChange(of: vm.gameOptions) { _, newOptions in
            if !newOptions.isEmpty {
                vm.showLetter(vm.targetLetter)
            }
        }
    }

    // MARK: - Mystery Braille Cell
    
    private var mysteryBrailleCell: some View {
        let regular    = sizeClass == .regular
        let dotSize    : CGFloat = regular ? 52  : 35
        let hSpacing   : CGFloat = regular ? 40  : 28
        let vSpacing   : CGFloat = regular ? 26  : 18
        let cardMax    : CGFloat = regular ? 260 : 180
        let outerMax   : CGFloat = regular ? 360 : 250

        return ZStack {
            VStack(spacing: 15) {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .shadow(color: Color.cyan.opacity(0.05), radius: 20, x: 0, y: 10)

                    HStack(spacing: hSpacing) {
                        VStack(spacing: vSpacing) {
                            BrailleDot(id: 1, isOn: vm.dots[0], size: dotSize)
                            BrailleDot(id: 2, isOn: vm.dots[1], size: dotSize)
                            BrailleDot(id: 3, isOn: vm.dots[2], size: dotSize)
                        }
                        VStack(spacing: vSpacing) {
                            BrailleDot(id: 4, isOn: vm.dots[3], size: dotSize)
                            BrailleDot(id: 5, isOn: vm.dots[4], size: dotSize)
                            BrailleDot(id: 6, isOn: vm.dots[5], size: dotSize)
                        }
                    }
                    .padding(20)
                }
                .frame(maxWidth: cardMax, maxHeight: cardMax * 1.22)
                .padding(.top, 15)
                .opacity(isViewAnimated ? 1 : 0)
                .accessibilityElement(children: .contain)

                // Feel the pattern button
                Button(action: {
                    vm.playTargetLetterHaptic()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "waveform")
                            .font(.body.bold())
                        Text("Feel the Pattern")
                            .font(.headline)
                    }
                    .foregroundColor(vm.gameOptions.isEmpty ? .gray : .cyan)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(vm.gameOptions.isEmpty ? Color.white.opacity(0.05) : Color.cyan.opacity(0.15))
                    )
                    .overlay(
                        Capsule()
                            .stroke(vm.gameOptions.isEmpty ? Color.clear : Color.cyan.opacity(0.3), lineWidth: 1)
                    )
                }
                .disabled(vm.gameOptions.isEmpty)
                .accessibilityLabel("Feel the Braille pattern")
                .accessibilityHint("Plays a haptic vibration representing the mystery letter")
            }
        }
        .frame(maxWidth: outerMax)
    }
        
    // MARK: - Logic
    private func handleAnswer(_ option: String) {
        selectedAnswer = option
        
        // Check answer using ViewModel
        let wasCorrect = vm.checkAnswer(option)
        isCorrect = wasCorrect
        showResult = true
        
        if wasCorrect {
            SoundManager.shared.playSuccess()
        } else {
            Task { await GameFlowManager.playShakeAnimation($shakeOffset) }
        }
        
        // Move to next question or end game
        Task {
            await GameFlowManager.advanceQuestion(
                questionNumber: $questionNumber,
                maxQuestions: maxQuestions,
                showGameEnd: $showGameEnd,
                selectedAnswer: $selectedAnswer,
                showResult: $showResult,
                generateNext: { vm.generateQuestion() }
            )
        }
    }
    
    private func restartGame() {
        GameFlowManager.restartStandardGame(
            showGameEnd: $showGameEnd,
            questionNumber: $questionNumber,
            selectedAnswer: $selectedAnswer,
            showResult: $showResult,
            viewModel: vm
        )
    }
    
    
}

#Preview {
    QuizGameView(vm: BrailleViewModel())
        .environmentObject(NavigationManager())
}
