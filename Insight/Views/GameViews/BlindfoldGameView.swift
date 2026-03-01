//
//  DarkGameView.swift
//  Insight
//
//  Created by Atakan on 19.02.2026.
//

import SwiftUI


struct BlindfoldGameView: View {
    @EnvironmentObject var navManager: NavigationManager
    @ObservedObject var vm : BrailleViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    //Game State
    @State private var isViewAnimated = false
    @State private var selectedAnswer: String? = nil
    @State private var showResult : Bool = false
    @State private var isCorrect : Bool = false
    @State private var shakeOffset : CGFloat = 0
    @State private var questionNumber : Int = 1
    @State private var showGameEnd : Bool = false
    

    
    var maxQuestions = GameConstants.questionsPerGame
    
    var body: some View {
        GeometryReader{ geo in
            ZStack{
                if !showGameEnd{
                    Color.black.ignoresSafeArea()
                } else  {
                    LinearGradient(
                        colors: [
                            AppColors.gameGradientTop,
                            AppColors.gameGradientBottom
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                }
                
                if showGameEnd{
                    GameEndView(
                        score: vm.gameScore,
                        gameMode: .blindfold,
                        showMasteryButton: navManager.allGamesCompleted,
                        restartGame: restartGame,
                        onBack: { navManager.navigate(to: .game) },
                        onMastery: { navManager.navigate(to: .mastery) }
                    )
                } else {
                    gameContent(screenSize: geo.size)
                }
            }
            .onAppear {
                Task {
                    vm.generateQuestion()
                }
                if !reduceMotion {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        isViewAnimated = true
                    }
                } else {
                    isViewAnimated = true
                }
            }
            .onDisappear{
                vm.resetGameState()
            }
            .onChange(of: showGameEnd) {
                if showGameEnd {
                    navManager.completedBlindfold = true
                }
            }
        }
    }
    
    private func gameContent(screenSize: CGSize) -> some View {
        let isLandscape = screenSize.width > screenSize.height
        let isCompact   = screenSize.height < 700

        return VStack(spacing: 0) {
            GameTopBar(score: vm.gameScore) { navManager.navigate(to: .game) }

            if isLandscape {
                landscapeContent(screenSize: screenSize)
            } else {
                portraitContent(screenSize: screenSize, isCompact: isCompact)
            }
        }
        .frame(width: screenSize.width, height: screenSize.height, alignment: .center)
        .onChange(of: vm.gameOptions) { _, newOptions in
            if !newOptions.isEmpty {
                vm.showLetter(vm.targetLetter)
            }
        }
    }

    // MARK: - Landscape Layout

    private func landscapeContent(screenSize: CGSize) -> some View {
        HStack(spacing: 0) {
            // LEFT — Braille hücresi
            VStack(spacing: 0) {
                Spacer()
                brailleCell(screenSize: CGSize(
                    width: screenSize.width * 0.45,
                    height: screenSize.height
                ))
                Text("Drag to feel")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.2))
                    .padding(.top, 6)
                Spacer()
            }
            .frame(maxWidth: screenSize.width * 0.45)

            Divider()
                .background(Color.white.opacity(0.1))
                .padding(.vertical, 12)

            // RIGHT — Soru + Cevaplar
            VStack(spacing: 0) {
                Spacer()
                GameQuestionPrompt(
                    maxQuestions: maxQuestions,
                    currentQuestion: questionNumber
                )
                .padding(.vertical, 8)

                Spacer()

                GameAnswerOptions(
                    options: vm.gameOptions,
                    targetLetter: vm.targetLetter,
                    selectedAnswer: selectedAnswer,
                    showResult: showResult,
                    isCorrect: isCorrect,
                    shakeOffset: shakeOffset,
                    compact: true
                ) { option in handleAnswer(option) }
                .id(questionNumber)
                .padding(.horizontal, 16)

                Spacer()
            }
            .frame(maxWidth: screenSize.width * 0.55)
        }
    }

    // MARK: - Portrait Layout

    private func portraitContent(screenSize: CGSize, isCompact: Bool) -> some View {
        VStack(alignment: .center, spacing: 0) {
            Spacer()

            GameQuestionPrompt(
                maxQuestions: maxQuestions,
                currentQuestion: questionNumber
            )
            .padding(.vertical, isCompact ? 5 : 10)

            Spacer()

            brailleCell(screenSize: screenSize)

            Spacer()

            GameAnswerOptions(
                options: vm.gameOptions,
                targetLetter: vm.targetLetter,
                selectedAnswer: selectedAnswer,
                showResult: showResult,
                isCorrect: isCorrect,
                shakeOffset: shakeOffset,
                compact: isCompact
            ) { option in handleAnswer(option) }
            .id(questionNumber)
            .containerRelativeFrame(.vertical) { length, _ in length * 0.3 }
            .padding(.bottom, 10)
            .padding(.horizontal, isCompact ? 25 : 0)

            if !isCompact {
                Spacer()
            }
        }
    }
    
    private func brailleCell(screenSize: CGSize) -> some View {
        let letter = BrailleData.shared.data[vm.targetLetter]
        // Landscape'de sol panel genişliğini, portre'de ekran genişliğini baz al
        let cellWidth = min(screenSize.width * 0.55, screenSize.height * 0.55, 320)
        let dotPattern = BrailleData.shared.pattern(letter)

        return DarkBrailleTouchCell(dotPattern: dotPattern, cellWidth: cellWidth)
    }
    
    
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
    BlindfoldGameView(vm: BrailleViewModel())
}
