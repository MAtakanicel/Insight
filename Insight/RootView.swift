//
//  RootView.swift
//  Insight
//
//  Created by Atakan on 5.02.2026.
//

import SwiftUI

struct RootView: View {
    @StateObject private var navManager = NavigationManager()
    @StateObject private var brailleViewModel = BrailleViewModel()
    var body: some View {
        
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            switch navManager.currentRoute {
            case .intro: IntroView()
            case .insightChallenge: InsightChallengeView()
            case .home: HomeView()
            case .learn: LearnView(vm: brailleViewModel)
            case .game: GameModeView()
            case .quizGame: QuizGameView(vm: brailleViewModel)
            case .darkGame: BlindfoldGameView(vm: brailleViewModel)
            case .wordGame: WordsGameView()
            case .mastery: MasteryView()
            }
        }
        .environmentObject(navManager)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    RootView()
}
