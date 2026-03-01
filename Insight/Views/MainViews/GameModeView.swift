//
//  GameModeView.swift
//  Insight
//
//  Created by Atakan on 18.02.2026.
//

import SwiftUI

struct GameModeView: View {
    @EnvironmentObject var navManager: NavigationManager
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isAnimated = false
    
    var body: some View {
        
        ZStack{
            AppColors.background
                .ignoresSafeArea()
             
            VStack(spacing: 0){
                
                Spacer()
                
                VStack{
                    Text("Challenge")
                        .font(.title.bold())
                        .foregroundColor(.white)
                    
                    Text("Choose a mode")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.white.opacity(0.4))
                }
                .padding(.top,  40)
                .opacity(isAnimated ? 1 : 0)
                .offset(y:isAnimated ? 0 : -20)
                
                Spacer(minLength: 20)
                
                
                VStack(spacing: 0){
                    modeCard(
                        title: "Practice",
                        subtitle: "Feel & Guess",
                        icon: "gamecontroller.fill",
                        backgroundColors: [
                            AppColors.blueGradientStart,
                            AppColors.blueGradientEnd
                        ],
                        shadow: .blue.opacity(0.3),
                        isCompleted: navManager.completedPractice
                    ) {
                        HapticManager.shared.navigationHapticNext()
                        navManager.navigate(to: .quizGame)
                    }
                   
                    Spacer().frame(minHeight: 15, maxHeight: 40)
                    
                    modeCard(
                        title: "Blindfold",
                        subtitle: "Touch & Feel",
                        icon: "eye.slash.fill",
                        backgroundColors: [
                            .black,
                            .cyan.opacity(0.12)
                        ],
                        shadow: .cyan.opacity(0.2),
                        isCompleted: navManager.completedBlindfold
                    ) {
                        HapticManager.shared.navigationHapticNext()
                        navManager.navigate(to: .darkGame)
                    }
 
                    Spacer().frame(minHeight: 15, maxHeight: 40)
                    
                    modeCard(
                        title: "Decipher",
                        subtitle: "Spell & Discover",
                        icon: "textformat.abc",
                        backgroundColors: [
                            .cyan.opacity(0.12),
                            .black
                        ],
                        shadow: AppColors.purpleShadow.opacity(0.35),
                        isCompleted: navManager.completedDecipher
                        ){
                        HapticManager.shared.navigationHapticNext()
                        navManager.navigate(to: .wordGame)
                        }

                }
                
                
                Spacer(minLength: 30)
            }
        }
        // Back Button
        .overlay(
            Button(action: {
                HapticManager.shared.navigationHapticBack()
                navManager.navigate(to: .home)
            }) {
                HStack(spacing: 8){
                    Image(systemName: "chevron.left")
                        .bold()
                    
                    Text("Menu")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundColor(.white.opacity(0.8))
                .padding(.vertical,10)
                .padding(.horizontal,15)
                .background(.white.opacity(0.1))
                .clipShape(Capsule())
                .padding(15)
            }
                .scaleEffect(isAnimated ? 1 : 0.9)
                .opacity(isAnimated ? 1 : 0)
            .accessibilityLabel("Back to Menu"),
            alignment: .topLeading
            
        )
        .onAppear{
            if reduceMotion{
                isAnimated = true
            } else {
                withAnimation(.spring(response: 0.7,dampingFraction: 0.8)){
                    isAnimated = true
                }
            }
        }
        }
    
    private func modeCard(
        title: String,
        subtitle: String,
        icon: String,
        backgroundColors: [Color],
        shadow: Color,
        isCompleted: Bool = false,
        action: @escaping () -> Void
    ) -> some View{
        Button (action: action){
            ZStack{
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: backgroundColors,
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: shadow, radius: 10, x: 5, y: 5)
                
                VStack(spacing: 4){
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .background(
                            Circle()
                                .fill(.white.opacity(0.2))
                                .frame(width: 40, height: 40)
                        )
                        .padding(.bottom,10)
                    
                    Text(title)
                        .font(.title2.bold())
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                    
                }
                
                // Completion badge
                if isCompleted {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                                .foregroundColor(.green)
                                .padding(12)
                        }
                        Spacer()
                    }
                }
            }
            .frame(minHeight: 80, idealHeight: 150, maxHeight: 200)
            .frame(maxWidth: 400)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(
                        isCompleted ? Color.green.opacity(0.4) : Color.white.opacity(0.08),
                        lineWidth: isCompleted ? 1.5 : 1
                    )
            )
            .padding(.horizontal,40)
            
        }
        .accessibilityLabel(title + (isCompleted ? " mode, completed" : " mode"))
        .accessibilityHint(subtitle)
        .accessibilityAddTraits(.isButton)
        .scaleEffect(isAnimated ? 1 : 0.9)
        .opacity(isAnimated ?  1 : 0)
    }
        
        
}


#Preview {
    GameModeView()
        .environmentObject(NavigationManager())
}
