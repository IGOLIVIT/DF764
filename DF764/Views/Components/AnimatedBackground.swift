//
//  AnimatedBackground.swift
//  DF764
//

import SwiftUI

struct GlowingButton: View {
    let title: String
    let action: () -> Void
    var isSecondary: Bool = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(isSecondary ? Color("AccentGlow") : .white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    ZStack {
                        if isSecondary {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color("AccentGlow"), lineWidth: 2)
                        } else {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color("AccentGlow"),
                                            Color("AccentGlow").opacity(0.8)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            // Glow effect
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color("AccentGlow"))
                                .blur(radius: 12)
                                .opacity(0.4)
                        }
                    }
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct GameCard: View {
    let gameType: GameType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color("AccentGlow").opacity(0.3),
                                    Color("AccentGlow").opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 40
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: gameType.icon)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(Color("AccentGlow"))
                }
                
                Text(gameType.rawValue)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                Text(gameType.description)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(Color("HighlightTone").opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color("PrimaryBackground").opacity(0.8))
                    
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color("AccentGlow").opacity(0.5),
                                    Color("HighlightTone").opacity(0.3),
                                    Color("AccentGlow").opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ShardCounter: View {
    let count: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                // Glow effect
                Image(systemName: "diamond.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color("HighlightTone"))
                    .blur(radius: 2)
                    .opacity(0.6)
                
                Image(systemName: "diamond.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color("HighlightTone"))
            }
            
            Text("\(count)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.1))
                .overlay(
                    Capsule()
                        .stroke(Color("HighlightTone").opacity(0.4), lineWidth: 1)
                )
        )
    }
}
