//
//  DarkDot.swift
//  Insight
//
//  Created by Atakan on 22.02.2026.
//

import SwiftUI

struct DarkDot: View {
    let index : Int
    let isActive : Bool
    let isHighlighted : Bool = false // activeDotIndex
    let coordinateSpaceName: String
    var size: CGFloat = 50
    
    var onFrameCapture: (Int, CGRect) -> Void
    
    var body: some View {
        Circle()
            .stroke(Color.white.opacity(0.045), lineWidth: 0.5) //Always invisible (0.03)
            .frame(width: size, height: size)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            onFrameCapture(index, geo.frame(in: .named(coordinateSpaceName)))
                        }
                        .onChange(of: geo.size) {
                            onFrameCapture(index, geo.frame(in: .named(coordinateSpaceName)))
                        }
                }
            )
            .overlay(
                Circle()
                    .fill(
                        isHighlighted ? (isActive ? Color.cyan.opacity(0.05) : Color.white.opacity(0.03)) : Color.clear
                    )
                    .animation(.easeOut, value: isHighlighted)
            )
        
        
    }
}


