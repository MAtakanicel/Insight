//
//  NavigationManager.swift
//  Insight
//
//  Created by Atakan on 5.02.2026.
//

import Foundation
import SwiftUI
import Combine

enum AppRoute {
    case intro              // Onboarding
    case insightChallenge   // Dark challenge (enter letter "I")
    case home               // Main Menu
    case learn              // Learn Mode (Braille alphabet)
    case game               // Game Mode
    case quizGame           // Challenge Mode (Quiz)
    case darkGame           // Dark mode
    case wordGame           // Word game
    case mastery            // All games completed celebration
}

@MainActor
class NavigationManager: ObservableObject {
    @Published var currentRoute: AppRoute = .intro
    @AppStorage("hasSeenIntro") var hasSeenIntro: Bool = false
    
    // Game completion tracking
    @AppStorage("completedPractice")  var completedPractice: Bool = false
    @AppStorage("completedBlindfold") var completedBlindfold: Bool = false
    @AppStorage("completedDecipher")  var completedDecipher: Bool = false
    
    var allGamesCompleted: Bool {
        completedPractice && completedBlindfold && completedDecipher
    }
    
    init() {
        if hasSeenIntro {
            currentRoute = .home
        } else {
            currentRoute = .intro
        }
    }

    func navigate(to route: AppRoute) {
        withAnimation(.easeInOut) {
            currentRoute = route
        }

        if route == .home {
            hasSeenIntro = true
        }
        
        // VoiceOver announcement for screen changes
        let announcement = getAnnouncement(for: route)
        UIAccessibility.post(notification: .screenChanged, argument: announcement)
    }
    
    private func getAnnouncement(for route: AppRoute) -> String {
        switch route {
        case .intro:             return "Welcome to Insight"
        case .insightChallenge:  return "A challenge for you. The screen is dark."
        case .home:              return "You are on the main menu"
        case .learn:             return "Braille alphabet learning mode"
        case .game:              return "Game mode Select"
        case .quizGame:          return "Challenge mode started"
        case .darkGame:          return "Dark mode started"
        case .wordGame:          return "Word association game started"
        case .mastery:           return "You have completed all challenges!"
        }
    }
}
