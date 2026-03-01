//
//  GameConstants.swift
//  Insight
//
//  Created by Atakan on 28.02.2026.
//

import Foundation

/// Shared game-wide constants. Change here → affects all game modes.
enum GameConstants {
    /// Number of questions per game session (Quiz & Dark modes).
    static let questionsPerGame: Int = 5
    
    /// Points awarded for a correct letter answer in Quiz & Dark modes.
    static let pointsPerCorrectAnswer: Int = 20
    
    /// Points deducted for a wrong answer in Quiz & Dark modes.
    static let penaltyPerWrongAnswer: Int = 10
    
    /// Points awarded for guessing the correct word in Words mode.
    static let pointsPerWord: Int = 40
    
    /// Points deducted for guessing the wrong word in Words mode.
    static let penaltyPerWrongWord: Int = 20
    
    /// Base score pool distributed per letter in Words mode.
    /// pointsPerLetter = baseWordScore / wordLength
    static let baseWordScore: Double = 60.0
}
