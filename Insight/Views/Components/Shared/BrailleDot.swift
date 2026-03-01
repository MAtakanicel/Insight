//
//  BrailleDot.swift
//  Insight
//
//  Created by Atakan on 4.02.2026.
//

import SwiftUI

struct BrailleDot: View {
    let id: Int
    var isOn: Bool
    var isHiddenLine: Bool = false
    var size : CGFloat = 50
    var showDotId: Bool = false
    var onTap: (() -> Void?) = { nil }
    
    var body: some View {
        ZStack {
            // Outer ring (visible when empty)
            Circle()
                .stroke(isOn ? Color.cyan : Color.gray.opacity(0.3), lineWidth: isHiddenLine ? 0 : 3)
                .frame(width: size, height: size)
            
            // Filled circle (visible when active)
            if isOn {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.cyan, Color.blue],
                            center: .center,
                            startRadius: 0,
                            endRadius: 25
                        )
                    )
                    .frame(width: size, height: size)
                    .shadow(color: .cyan.opacity(0.4), radius: 8)
                    .transition(.scale.combined(with: .opacity))
            }
          if showDotId{
                // Dot number (subtle)
                Text("\(id)")
                  .font(.system(size: size * 0.24).weight(.medium))
                    .foregroundColor(isOn ? .white.opacity(0.8) : .gray.opacity(0.4))
            }
               
        }
        .contentShape(Circle())
        .onTapGesture {
            onTap()
        }
        .accessibilityLabel("Dot \(id)")
        .accessibilityValue(isOn ? "Raised" : "Flat")
    }
}

#Preview {
    HStack(spacing: 30) {
        BrailleDot(id: 1, isOn: true, onTap: { })
        BrailleDot(id: 2, isOn: false, onTap: { })
    }
    .padding()
    .background(Color.black)
}
