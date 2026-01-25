//
//  TutorialView.swift
//  DF764
//

import SwiftUI

struct TutorialView: View {
    @Environment(\.dismiss) var dismiss
    let gameType: GameType
    @State private var currentStep = 0
    
    var steps: [String] {
        gameType.tutorialSteps
    }
    
    var body: some View {
        ZStack {
            Color("PrimaryBackground")
                .ignoresSafeArea()
            
            // Background
            GeometryReader { geometry in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                gameType.themeColor.opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: geometry.size.width * 0.5
                        )
                    )
                    .frame(width: geometry.size.width, height: geometry.size.width)
                    .offset(y: -geometry.size.height * 0.2)
            }
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Color("HighlightTone").opacity(0.6))
                    }
                    
                    Spacer()
                    
                    Text("How to Play")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .opacity(0)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                Spacer()
                
                // Game icon
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    gameType.themeColor.opacity(0.3),
                                    gameType.themeColor.opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: gameType.icon)
                        .font(.system(size: 50))
                        .foregroundColor(gameType.themeColor)
                }
                
                // Game name
                Text(gameType.rawValue)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 16)
                
                Spacer()
                    .frame(height: 40)
                
                // Tutorial step
                VStack(spacing: 20) {
                    // Step indicator
                    HStack(spacing: 8) {
                        ForEach(0..<steps.count, id: \.self) { index in
                            Circle()
                                .fill(currentStep == index ? gameType.themeColor : Color.white.opacity(0.2))
                                .frame(width: 8, height: 8)
                        }
                    }
                    
                    // Step number
                    Text("Step \(currentStep + 1) of \(steps.count)")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(gameType.themeColor)
                    
                    // Step content
                    TutorialStepCard(
                        stepNumber: currentStep + 1,
                        content: steps[currentStep],
                        color: gameType.themeColor
                    )
                    .padding(.horizontal, 24)
                }
                
                Spacer()
                
                // Navigation buttons
                HStack(spacing: 16) {
                    if currentStep > 0 {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentStep -= 1
                            }
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(gameType.themeColor)
                            .frame(height: 52)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(gameType.themeColor, lineWidth: 2)
                            )
                        }
                    }
                    
                    Button(action: {
                        if currentStep < steps.count - 1 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentStep += 1
                            }
                        } else {
                            dismiss()
                        }
                    }) {
                        HStack {
                            Text(currentStep == steps.count - 1 ? "Got it!" : "Next")
                            if currentStep < steps.count - 1 {
                                Image(systemName: "chevron.right")
                            }
                        }
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(height: 52)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(gameType.themeColor)
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

struct TutorialStepCard: View {
    let stepNumber: Int
    let content: String
    let color: Color
    
    private var stepIcon: String {
        switch stepNumber {
        case 1: return "1.circle.fill"
        case 2: return "2.circle.fill"
        case 3: return "3.circle.fill"
        case 4: return "4.circle.fill"
        case 5: return "5.circle.fill"
        default: return "\(stepNumber).circle.fill"
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: stepIcon)
                .font(.system(size: 40))
                .foregroundColor(color)
            
            Text(content)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct TutorialListView: View {
    @EnvironmentObject var appState2: AppState2
    @Environment(\.dismiss) var dismiss
    @State private var selectedGame: GameType?
    
    var body: some View {
        ZStack {
            Color("PrimaryBackground")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Color("HighlightTone").opacity(0.6))
                    }
                    
                    Spacer()
                    
                    Text("Game Tutorials")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .opacity(0)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(GameType.allCases, id: \.self) { gameType in
                            TutorialGameRow(gameType: gameType) {
                                selectedGame = gameType
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            
            if let game = selectedGame {
                TutorialView(gameType: game)
                    .transition(.move(edge: .trailing))
                    .onDisappear {
                        selectedGame = nil
                    }
            }
        }
    }
}

struct TutorialGameRow: View {
    let gameType: GameType
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(gameType.themeColor.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: gameType.icon)
                        .font(.system(size: 22))
                        .foregroundColor(gameType.themeColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(gameType.rawValue)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(gameType.description)
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.5))
                        .lineLimit(1)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 14))
                    Text("Learn")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                }
                .foregroundColor(gameType.themeColor)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(gameType.themeColor.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    TutorialView(gameType: .pulsePathGrid)
}
