//
//  LevelMapView.swift
//  DF764
//

import SwiftUI

struct LevelMapView: View {
    @EnvironmentObject var appState2: AppState2
    @Environment(\.dismiss) var dismiss
    let gameType: GameType
    
    @State private var selectedLevel: Int?
    
    var progress: GameProgressData {
        appState2.progress(for: gameType)
    }
    
    var body: some View {
        ZStack {
            Color("PrimaryBackground")
                .ignoresSafeArea()
            
            // Background gradient based on game theme
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
                            endRadius: geometry.size.width * 0.6
                        )
                    )
                    .frame(width: geometry.size.width, height: geometry.size.width)
                    .offset(x: geometry.size.width * 0.2, y: -geometry.size.height * 0.1)
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
                    
                    VStack(spacing: 4) {
                        Text(gameType.rawValue)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Color("HighlightTone"))
                            Text("\(progress.totalStars)/\(gameType.totalLevels * 3)")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(Color("HighlightTone"))
                        }
                    }
                    
                    Spacer()
                    
                    // Shard counter
                    HStack(spacing: 4) {
                        Image(systemName: "diamond.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color("HighlightTone"))
                        Text("\(appState2.shards)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                    )
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                // Level Grid
                ScrollView(showsIndicators: false) {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ],
                        spacing: 20
                    ) {
                        ForEach(progress.levels) { level in
                            LevelNode(
                                level: level,
                                isUnlocked: progress.isLevelUnlocked(level.id),
                                themeColor: gameType.themeColor,
                                onTap: {
                                    if progress.isLevelUnlocked(level.id) {
                                        selectedLevel = level.id
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                }
            }
        }
        .fullScreenCover(isPresented: Binding(
            get: { selectedLevel != nil },
            set: { if !$0 { selectedLevel = nil } }
        )) {
            if let level = selectedLevel {
                GamePlayView(gameType: gameType, level: level)
                    .environmentObject(appState2)
            }
        }
    }
}

struct LevelNode: View {
    let level: LevelData
    let isUnlocked: Bool
    let themeColor: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    // Background circle
                    Circle()
                        .fill(
                            isUnlocked ?
                            (level.isCompleted ? themeColor.opacity(0.3) : Color.white.opacity(0.1)) :
                            Color.gray.opacity(0.2)
                        )
                        .frame(width: 70, height: 70)
                    
                    // Border
                    Circle()
                        .stroke(
                            isUnlocked ?
                            (level.isCompleted ? themeColor : Color.white.opacity(0.3)) :
                            Color.gray.opacity(0.3),
                            lineWidth: 2
                        )
                        .frame(width: 70, height: 70)
                    
                    if isUnlocked {
                        if level.isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(themeColor)
                        } else {
                            Text("\(level.id)")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color.gray.opacity(0.5))
                    }
                }
                
                // Stars
                if level.isCompleted {
                    HStack(spacing: 2) {
                        ForEach(1...3, id: \.self) { starIndex in
                            Image(systemName: starIndex <= level.stars ? "star.fill" : "star")
                                .font(.system(size: 10))
                                .foregroundColor(starIndex <= level.stars ? Color("HighlightTone") : Color.white.opacity(0.3))
                        }
                    }
                } else if isUnlocked {
                    HStack(spacing: 2) {
                        ForEach(1...3, id: \.self) { _ in
                            Image(systemName: "star")
                                .font(.system(size: 10))
                                .foregroundColor(Color.white.opacity(0.2))
                        }
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isUnlocked)
    }
}

struct GamePlayView: View {
    @EnvironmentObject var appState2: AppState2
    @Environment(\.dismiss) var dismiss
    
    let gameType: GameType
    let level: Int
    
    @State private var showResult = false
    @State private var resultScore = 0
    @State private var resultStars = 0
    
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
                    
                    VStack(spacing: 2) {
                        Text("Level \(level)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(gameType.rawValue)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(gameType.themeColor)
                    }
                    
                    Spacer()
                    
                    // Empty space for symmetry
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .opacity(0)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                // Game content
                switch gameType {
                case .pulsePathGrid:
                    PulsePathGridGame(level: level, onComplete: handleComplete)
                case .momentumShiftArena:
                    MomentumShiftArenaGame(level: level, onComplete: handleComplete)
                case .echoSequenceLabyrinth:
                    EchoSequenceLabyrinthGame(level: level, onComplete: handleComplete)
                case .gravityFlux:
                    GravityFluxGame(level: level, onComplete: handleComplete)
                case .chronoCascade:
                    ChronoCascadeGame(level: level, onComplete: handleComplete)
                }
            }
            
            // Result overlay
            if showResult {
                LevelCompleteView(
                    level: level,
                    score: resultScore,
                    stars: resultStars,
                    themeColor: gameType.themeColor,
                    hasNextLevel: level < gameType.totalLevels,
                    onNextLevel: {
                        showResult = false
                        // Navigate to next level would require different architecture
                        dismiss()
                    },
                    onExit: {
                        dismiss()
                    }
                )
            }
        }
    }
    
    private func handleComplete(score: Int, stars: Int) {
        appState2.completeLevel(gameType: gameType, level: level, score: score, stars: stars)
        resultScore = score
        resultStars = stars
        showResult = true
    }
}

struct LevelCompleteView: View {
    let level: Int
    let score: Int
    let stars: Int
    let themeColor: Color
    let hasNextLevel: Bool
    let onNextLevel: () -> Void
    let onExit: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Stars display
                HStack(spacing: 12) {
                    ForEach(1...3, id: \.self) { starIndex in
                        Image(systemName: starIndex <= stars ? "star.fill" : "star")
                            .font(.system(size: 40))
                            .foregroundColor(starIndex <= stars ? Color("HighlightTone") : Color.white.opacity(0.3))
                    }
                }
                
                VStack(spacing: 8) {
                    Text("Level \(level) Complete!")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Score: \(score)")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(themeColor)
                }
                
                // Shards earned
                HStack(spacing: 8) {
                    Image(systemName: "diamond.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color("HighlightTone"))
                    
                    Text("+\(stars + 1) Shards")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(Color("HighlightTone"))
                }
                .padding(.top, 8)
                
                VStack(spacing: 12) {
                    if hasNextLevel {
                        GlowingButton(title: "Next Level", action: onNextLevel)
                    }
                    
                    GlowingButton(title: "Back to Levels", action: onExit, isSecondary: hasNextLevel)
                }
                .padding(.horizontal, 40)
                .padding(.top, 16)
            }
            .padding(32)
        }
    }
}

#Preview {
    LevelMapView(gameType: .pulsePathGrid)
        .environmentObject(AppState2())
}

