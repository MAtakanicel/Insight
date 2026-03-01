//
//  AppColors.swift
//  Insight
//
//  Created by Atakan.
//

import SwiftUI

/// Centralized color definitions used throughout the app.
/// Prevents scattered hardcoded Color(red:green:blue:) values.
enum AppColors {
    
    // MARK: - Backgrounds
    
    /// Main dark background used across most screens
    static let background = Color(red: 0.05, green: 0.05, blue: 0.1)
    
    /// Game end / quiz gradient top color
    static let gameGradientTop = Color(red: 0.07, green: 0.07, blue: 0.12)
    
    /// Game end / quiz gradient bottom color
    static let gameGradientBottom = Color(red: 0.12, green: 0.08, blue: 0.2)
    
    /// Card / section fill color
    static let cardFill = Color(red: 0.1, green: 0.1, blue: 0.15)
    
    /// Mastery screen gradient top color
    static let masteryGradientTop = Color(red: 0.05, green: 0.05, blue: 0.12)
    
    /// Mastery screen gradient bottom color
    static let masteryGradientBottom = Color(red: 0.0, green: 0.08, blue: 0.15)
    
    // MARK: - Button Gradients
    
    /// Blue button gradient start
    static let blueGradientStart = Color(red: 0.1, green: 0.3, blue: 0.8)
    
    /// Blue button gradient end
    static let blueGradientEnd = Color(red: 0.15, green: 0.4, blue: 0.95)
    
    /// Orange button gradient start
    static let orangeGradientStart = Color(red: 0.85, green: 0.4, blue: 0.1)
    
    /// Orange button gradient end
    static let orangeGradientEnd = Color(red: 0.95, green: 0.55, blue: 0.15)
    
    // MARK: - Shadows & Accents
    
    /// Purple shadow for cards
    static let purpleShadow = Color(red: 0.4, green: 0.3, blue: 0.5)
    
    // MARK: - Intro View Gradients
    
    /// Intro page 1 gradient start
    static let introPage1Start = Color(red: 0.05, green: 0.05, blue: 0.15)
    
    /// Intro page 1 gradient end
    static let introPage1End = Color(red: 0.1, green: 0.1, blue: 0.3)
    
    /// Intro page 2 gradient start
    static let introPage2Start = Color(red: 0.08, green: 0.12, blue: 0.25)
    
    /// Intro page 2 gradient end
    static let introPage2End = Color(red: 0.15, green: 0.2, blue: 0.4)
    
    /// Intro page 3 gradient start
    static let introPage3Start = Color(red: 0.1, green: 0.15, blue: 0.35)
    
    /// Intro page 3 gradient end
    static let introPage3End = Color(red: 0.2, green: 0.25, blue: 0.5)
    
    // MARK: - Convenience Gradients
    
    /// Standard game background gradient
    static let gameGradient = LinearGradient(
        colors: [gameGradientTop, gameGradientBottom],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Blue button gradient
    static let blueGradient = LinearGradient(
        colors: [blueGradientStart, blueGradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Orange button gradient
    static let orangeGradient = LinearGradient(
        colors: [orangeGradientStart, orangeGradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
