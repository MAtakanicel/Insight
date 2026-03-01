//
//  WordsGameViewModel.swift
//  Insight
//
//  Created by Atakan on 26.02.2026.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class WordsGameViewModel: ObservableObject {
    // Words Game State
    @Published var currentWord: String = "SUN"
    @Published var currentLetterIndex: Int = 0
    @Published var revealLetters: [Bool] = []
    @Published var wordOptions: [String] = []
    @Published var letterBrailleOptions: [[Int]] = []
    @Published var gameScore: Int = 0
    
    // MARK: - Word Question Generation
    
    func generateWordQuestion() {
        currentWord = WordData.shared.randomWords(1).first ?? "SUN"
        currentLetterIndex = 0
        revealLetters = Array(repeating: false, count: currentWord.count)
        generateLetterOptions()
    }
    
    func generateLetterOptions() {
        let currentChar = String(Array(currentWord)[currentLetterIndex])
        let correctPattern = BrailleData.shared.data[currentChar] ?? []

        let wrongPatterns = BrailleData.shared.allLetters.filter { $0 != currentChar }
            .shuffled()
            .prefix(3)
            .compactMap { BrailleData.shared.data[$0] }
        
        letterBrailleOptions = ([correctPattern] + wrongPatterns).shuffled()
    }
    
    // MARK: - Braille Dot Helpers
    
    func lockedBrailleDotStates(_ cell: Int) -> [Bool] {
        let wordArray = Array(currentWord)
        guard cell >= 0 && cell < wordArray.count else {
            return Array(repeating: false, count: 6)
        }
        
        let currentChar = String(wordArray[cell])
        
        guard let indices = BrailleData.shared.data[currentChar] else {
            return Array(repeating: false, count: 6)
        }
        
        var result = Array(repeating: false, count: 6)
        for i in indices {
            if i - 1 < 6 && i - 1 >= 0 {
                result[i - 1] = true
            }
        }
        
        return result
    }
    
    // MARK: - Answer Checking
    
    func checkLetterAnswer(_ selected: [Int]) -> Bool {
        let wordArray = Array(currentWord)
        guard currentLetterIndex < wordArray.count else { return false }
        
        // 60 points distributed among letters, 40 for the final word
        let pointsPerLetter = GameConstants.baseWordScore / Double(wordArray.count)
        let penalty = max(5, Int(pointsPerLetter / 3.0))
        
        let currentChar = String(wordArray[currentLetterIndex])
        let correctPattern = BrailleData.shared.data[currentChar] ?? []
        
        if selected == correctPattern {
            revealLetters[currentLetterIndex] = true
            gameScore += Int(pointsPerLetter)
            HapticManager.shared.playSuccess()
            
            currentLetterIndex += 1
            return true
        } else {
            gameScore = max(0, gameScore - penalty)
            HapticManager.shared.playError()
            return false
        }
    }
    
    /// Word phase: generate 1 correct + 2 wrong word options
    func generateWordOptions() {
        let wrongWords = WordData.shared.allWords
            .filter { $0 != currentWord && $0.count == currentWord.count }
            .shuffled()
            .prefix(2)
        
        wordOptions = (Array(wrongWords) + [currentWord]).shuffled()
    }
    
    /// Check the word answer
    func checkWordAnswer(_ selected: String) -> Bool {
        if selected == currentWord {
            // Give 40 points for getting the final word right
            gameScore += GameConstants.pointsPerWord
            HapticManager.shared.playSuccess()
            return true
        } else {
            // 20 point penalty for wrong word
            gameScore = max(0, gameScore - GameConstants.penaltyPerWrongWord)
            HapticManager.shared.playError()
            return false
        }
    }
    
    // MARK: - Reset
    
    func resetGameState() {
        gameScore = 0
        currentWord = "SUN"
        currentLetterIndex = 0
        revealLetters = []
        wordOptions = []
        letterBrailleOptions = []
    }
}
