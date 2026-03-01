//
//  WordsGameView.swift
//  Insight
//
//  Created by Atakan on 22.02.2026.
//

import SwiftUI

struct WordsGameView: View {
    @StateObject private var wordsVM = WordsGameViewModel()
    @EnvironmentObject var navManager: NavigationManager
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // Game State
    @State private var showGameEnd = false
    @State private var isViewAnimated = false
    @State private var showWordGuess = false
    
    // Letter answer feedback
    @State private var selectedOptionIndex: Int? = nil
    @State private var letterAnswerCorrect: Bool? = nil
    @State private var shakeOffset: CGFloat = 0
    
    // Word guess feedback
    @State private var selectedWordAnswer: String? = nil
    @State private var wordGuessCorrect: Bool? = nil
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background
                if showGameEnd {
                    LinearGradient(
                        colors: [
                            AppColors.gameGradientTop,
                            AppColors.gameGradientBottom
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                } else {
                    Color.black.ignoresSafeArea()
                
                }
                
                // Content
                if showGameEnd {
                    GameEndView(
                        score: wordsVM.gameScore,
                        gameMode: .decipher,
                        showMasteryButton: navManager.allGamesCompleted,
                        restartGame: restartGame,
                        onBack: { navManager.navigate(to: .game) },
                        onMastery: { navManager.navigate(to: .mastery) }
                    )
                } else {
                    gameContent(screenSize: geo.size)
                }
            }
        }
        .onAppear {
            wordsVM.generateWordQuestion()
            if !reduceMotion {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isViewAnimated = true
                }
            } else {
                isViewAnimated = true
            }
        }
        .onDisappear {
            wordsVM.resetGameState()
        }
        .onChange(of: showGameEnd) {
            if showGameEnd {
                navManager.completedDecipher = true
            }
        }
        .onChange(of: wordsVM.letterBrailleOptions) {
            // Yeni seçenekler UI'a yüklenince haptic → gecikmeyle uyumlu
            HapticManager.shared.playHapticsSnap()
        }
        .onChange(of: showWordGuess) {
            if showWordGuess {
                HapticManager.shared.playHapticsSnap()
            }
        }
    }
    
    // MARK: - Game Content
    
    private func gameContent(screenSize: CGSize) -> some View {
        let isLandscape = screenSize.width > screenSize.height
        let scale = min(max(screenSize.height / 852, 0.7), 1.35)

        return VStack(spacing: 0) {
            // Top bar
            GameTopBar(score: wordsVM.gameScore, onBack: { navManager.navigate(to: .game) })

            // Locked braille card — always on top
            LockedBrailleCard(
                word: wordsVM.currentWord,
                revealLetters: wordsVM.revealLetters,
                currentLetterIndex: wordsVM.currentLetterIndex,
                showWordGuess: showWordGuess,
                isAnimated: isViewAnimated,
                scale: isLandscape ? scale * 0.8 : scale,
                dotStatesProvider: wordsVM.lockedBrailleDotStates
            )
            .frame(height: screenSize.height * (isLandscape ? 0.15 : 0.10))

            if isLandscape {
                landscapeContent(screenSize: screenSize, scale: scale * 0.85)
            } else {
                if showWordGuess {
                    wordGuessContent(screenSize: screenSize, scale: scale)
                } else {
                    letterPhaseContent(screenSize: screenSize, scale: scale)
                }
            }
        }
        .frame(width: screenSize.width, height: screenSize.height)
    }

    // MARK: - Landscape Layout (side by side)

    private func landscapeContent(screenSize: CGSize, scale: CGFloat) -> some View {
        HStack(spacing: 0) {
            // LEFT — Braille touch cell or word-phase title
            VStack(spacing: 8 * scale) {
                if !showWordGuess {
                    Text("Which Letter?")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                }

                Spacer()

                if showWordGuess {
                    VStack(spacing: 8 * scale) {
                        Text("🎉")
                            .font(.system(size: 40 * scale))
                        Text("All letters revealed!")
                            .font(.headline.weight(.bold))
                            .foregroundColor(.white)
                        Text("Which word is it?")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                    }
                } else {
                    brailleCell(screenWidth: screenSize.width * 0.55, scale: scale)
                        .id(wordsVM.currentLetterIndex)
                    Text("Drag to feel")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.2))
                        .padding(.top, 4 * scale)
                }

                Spacer()
            }
            .frame(maxWidth: screenSize.width * 0.45)

            Divider()
                .background(Color.white.opacity(0.1))
                .padding(.vertical, 12)

            // RIGHT — Answer options
            VStack(spacing: 0) {
                Spacer()

                if showWordGuess {
                    WordAnswerOptions(
                        options: wordsVM.wordOptions,
                        correctWord: wordsVM.currentWord,
                        selectedAnswer: selectedWordAnswer,
                        isCorrect: wordGuessCorrect,
                        scale: scale,
                        compact: true,
                        onSelect: handleWordAnswer
                    )
                    .frame(maxWidth: 340 * scale)
                } else {
                    BraillePatternOptions(
                        options: wordsVM.letterBrailleOptions,
                        selectedIndex: selectedOptionIndex,
                        isCorrect: letterAnswerCorrect,
                        scale: scale,
                        maxWidth: screenSize.width * 0.3,
                        onSelect: handleLetterAnswer
                    )
                    .offset(x: shakeOffset)
                    .padding(.horizontal, 16)
                }

                Spacer()
            }
            .frame(maxWidth: screenSize.width * 0.55)
        }
    }

    
    // MARK: - Letter Phase
    
    private func letterPhaseContent(screenSize: CGSize, scale: CGFloat) -> some View {
        VStack(spacing: 0) {
            Text("Which Letter?")
                .font(.title3.weight(.semibold))
                .foregroundColor(.white)
                .padding(.vertical, 8 * scale)
            
            Spacer()
            
            brailleCell(screenWidth: screenSize.width, scale: scale)
                .id(wordsVM.currentLetterIndex)
            
            Text("Drag to feel")
                .font(.caption)
                .foregroundColor(.white.opacity(0.2))
                .padding(.top, 8 * scale)
            
            Spacer()
            
            BraillePatternOptions(
                options: wordsVM.letterBrailleOptions,
                selectedIndex: selectedOptionIndex,
                isCorrect: letterAnswerCorrect,
                scale: scale,
                onSelect: handleLetterAnswer
            )
            .padding(.horizontal, 20)
            .offset(x: shakeOffset)
            
            Spacer().frame(height: 16 * scale)
        }
    }
    
    // MARK: - Word Guess Phase
    
    private func wordGuessContent(screenSize: CGSize, scale: CGFloat) -> some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 12 * scale) {
                Text("🎉")
                    .font(.system(size: 50 * scale))
                
                Text("All letters revealed!")
                    .font(.title2.weight(.bold))
                    .foregroundColor(.white)
                
                Text("Which word is it?")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            WordAnswerOptions(
                options: wordsVM.wordOptions,
                correctWord: wordsVM.currentWord,
                selectedAnswer: selectedWordAnswer,
                isCorrect: wordGuessCorrect,
                scale: scale,
                onSelect: handleWordAnswer
            )
            .frame(maxWidth: 400 * scale)
            .padding(.horizontal, 30)
            
            Spacer()
            Spacer().frame(height: 20 * scale)
        }
    }
    
    // MARK: - Braille Touch Cell
    
    private func brailleCell(screenWidth: CGFloat, scale: CGFloat) -> some View {
        let cellWidth = min(screenWidth * 0.5, 350 * scale)
        let currentPattern = wordsVM.lockedBrailleDotStates(wordsVM.currentLetterIndex)
        
        return DarkBrailleTouchCell(dotPattern: currentPattern, cellWidth: cellWidth)
    }
    
    // MARK: - Actions
    
    private func handleLetterAnswer(_ optionIndex: Int) {
        selectedOptionIndex = optionIndex
        let selectedPattern = wordsVM.letterBrailleOptions[optionIndex]
        let correct = wordsVM.checkLetterAnswer(selectedPattern)
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            letterAnswerCorrect = correct
        }
        
        if !correct {
            Task { await GameFlowManager.playShakeAnimation($shakeOffset) }
        } else {
            SoundManager.shared.playSuccess()
        }
        
        // Reset after delay, then proceed
        Task {
            try? await Task.sleep(for: .seconds(1))

            withAnimation {
                selectedOptionIndex = nil
                letterAnswerCorrect = nil
            }

            if correct {
                let allLettersDone = wordsVM.currentLetterIndex >= wordsVM.currentWord.count
                if allLettersDone {
                    wordsVM.generateWordOptions()
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        showWordGuess = true
                    }
                } else {
                    // 0.25 sn bekle → yeni seçenekler ve haptic birlikte gelsin
                    try? await Task.sleep(for: .milliseconds(250))
                    wordsVM.generateLetterOptions()
                }
            }
        }
    }
    
    private func handleWordAnswer(_ word: String) {
        selectedWordAnswer = word
        let correct = wordsVM.checkWordAnswer(word)
        
        if correct {
            SoundManager.shared.playSuccess()
        }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            wordGuessCorrect = correct
        }
        
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showGameEnd = true
            }
        }
    }
    
    private func restartGame() {
        withAnimation {
            showGameEnd = false
            showWordGuess = false
            selectedOptionIndex = nil
            letterAnswerCorrect = nil
            selectedWordAnswer = nil
            wordGuessCorrect = nil
            wordsVM.gameScore = 0
            wordsVM.generateWordQuestion()
        }
    }
}

#Preview {
    WordsGameView()
        .environmentObject(NavigationManager())
}
