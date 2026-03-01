//
//  BrailleViewModel.swift
//  Insight
//
//  Created by Atakan on 4.02.2026.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class BrailleViewModel: ObservableObject {
    @Published var dots: [Bool] = Array(repeating: false, count: 6)
    @Published var currentLetter: String = "A"
    
    // Game mode
    @Published var gameOptions: [String] = []
    @Published var gameScore: Int = 0
    
    // Expose target letter for game checking
    private(set) var targetLetter: String = ""
    
    private var currentIndex: Int = 0
    
    private var allLetters: [String] {
        return BrailleData.shared.allLetters
    }
    
    init() {
        showLetter("A")
    }
    
    // MARK: - Learn Mode Navigation
    
    func nextLetter() {
        if currentIndex < allLetters.count - 1 {
            currentIndex += 1
            updateSelection()
        }
    }
    
    func previousLetter() {
        if currentIndex > 0 {
            currentIndex -= 1
            updateSelection()
        }
    }
    
    private func updateSelection() {
        let letter = allLetters[currentIndex]
        currentLetter = letter
        showLetter(letter)
        HapticManager.shared.playSelection()
    }
    
    func toggleDot(at: Int) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            dots[at].toggle()
        }
        HapticManager.shared.playHapticsSnap()
    }
    
    func showLetter(_ letter: String) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            for i in 0..<dots.count {
                dots[i] = false
            }
            
            guard let activeIndex = BrailleData.shared.data[letter.uppercased()] else { return }
            
            for id in activeIndex {
                if id - 1 < dots.count {
                    dots[id - 1] = true
                }
            }
        }
        HapticManager.shared.playHapticsSnap()
    }
    
    func resetDots() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            for i in 0..<dots.count {
                dots[i] = false
            }
        }
    }
    
    // MARK: - Game Mode (Classic & Dark)
    
    func generateQuestion() {
        // 1. Immediately clear the options and dots to trigger the "Get Ready..." UI
        gameOptions = []
        resetDots()
        
        // 2. Prepare the new question in the background
        let newTargetLetter = BrailleData.shared.allLetters.randomElement() ?? "A"
        
        // Create wrong options (2 random letters that are not the target)
        let wrongOptions = BrailleData.shared.allLetters
            .filter { $0 != newTargetLetter }
            .shuffled()
            .prefix(2)
        
        // Combine and shuffle
        let options = (Array(wrongOptions) + [newTargetLetter]).shuffled()
        
        // 3. Wait, then display the new options
        Task {
            try? await Task.sleep(for: .milliseconds(750)) // 0.75 seconds
            self.targetLetter = newTargetLetter
            self.gameOptions = options
        }
    }
    
    /// Plays a rhythmic pattern based on the Braille dots of the current letter
    func playCurrentLetterHaptic() {
        guard let indices = BrailleData.shared.data[currentLetter] else { return }
        Task { await SoundManager.shared.playBraillePatternSynced(activeDots: indices) }
    }
    
    func playTargetLetterHaptic() {
        guard let indices = BrailleData.shared.data[targetLetter] else { return }
        Task { await SoundManager.shared.playBraillePatternSynced(activeDots: indices) }
    }
    
    /// Checks the answer and returns whether it was correct.
    @discardableResult
    func checkAnswer(_ selected: String) -> Bool {
        if selected == targetLetter {
            gameScore += GameConstants.pointsPerCorrectAnswer
            HapticManager.shared.playSuccess()
            return true
        } else {
            gameScore = max(0, gameScore - GameConstants.penaltyPerWrongAnswer)
            HapticManager.shared.playError()
            return false
        }
    }
    
    // MARK: - Reset
    
    func resetGameState() {
        gameOptions = []
        gameScore = 0
        targetLetter = ""
        resetDots()
    }
}

