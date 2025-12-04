//
//  ProgressStatsView.swift
//  DF764
//

import SwiftUI

struct ProgressStatsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color("PrimaryBackground")
                .ignoresSafeArea()
            
            // Background glow
            GeometryReader { geometry in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color("AccentGlow").opacity(0.15),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: geometry.size.width * 0.6
                        )
                    )
                    .frame(width: geometry.size.width, height: geometry.size.width)
                    .offset(x: geometry.size.width * 0.3, y: -geometry.size.height * 0.2)
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
                    
                    Text("Progress Stats")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Invisible spacer for alignment
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .opacity(0)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Total shards card
                        TotalShardsCard(shards: appState.shards)
                        
                        // Overall stats
                        OverallStatsCard(
                            totalLevels: appState.totalLevelsCompleted,
                            maxLevels: 27 // 3 games × 3 difficulties × 3 levels
                        )
                        
                        // Per-game stats
                        VStack(spacing: 16) {
                            Text("Game Progress")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            ForEach(GameType.allCases, id: \.self) { gameType in
                                GameProgressCard(
                                    gameType: gameType,
                                    progress: appState.progress(for: gameType)
                                )
                            }
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
            }
        }
    }
}

struct TotalShardsCard: View {
    let shards: Int
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // Glow rings
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .stroke(Color("HighlightTone").opacity(0.2 - Double(index) * 0.05), lineWidth: 2)
                        .frame(width: CGFloat(80 + index * 20), height: CGFloat(80 + index * 20))
                }
                
                // Center diamond
                ZStack {
                    Image(systemName: "diamond.fill")
                        .font(.system(size: 50))
                        .foregroundColor(Color("HighlightTone"))
                        .blur(radius: 8)
                        .opacity(0.5)
                    
                    Image(systemName: "diamond.fill")
                        .font(.system(size: 50))
                        .foregroundColor(Color("HighlightTone"))
                }
            }
            
            VStack(spacing: 4) {
                Text("\(shards)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Total Shards")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Color("HighlightTone").opacity(0.8))
            }
        }
        .padding(.vertical, 32)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color("HighlightTone").opacity(0.4),
                                    Color("AccentGlow").opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
        )
    }
}

struct OverallStatsCard: View {
    let totalLevels: Int
    let maxLevels: Int
    
    var progress: Double {
        Double(totalLevels) / Double(maxLevels)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Overall Completion")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(totalLevels)/\(maxLevels)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Color("AccentGlow"))
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.1))
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [Color("AccentGlow"), Color("HighlightTone")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress)
                    
                    // Glow effect
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color("AccentGlow"))
                        .frame(width: geometry.size.width * progress)
                        .blur(radius: 8)
                        .opacity(0.4)
                }
            }
            .frame(height: 12)
            
            Text("\(Int(progress * 100))% Complete")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(Color("HighlightTone").opacity(0.7))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct GameProgressCard: View {
    let gameType: GameType
    let progress: GameProgress
    
    @State private var expanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Button(action: { expanded.toggle() }) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color("AccentGlow").opacity(0.2))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: gameType.icon)
                            .font(.system(size: 20))
                            .foregroundColor(Color("AccentGlow"))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(gameType.rawValue)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("\(progress.totalLevelsCompleted)/9 levels")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(Color("HighlightTone").opacity(0.7))
                    }
                    
                    Spacer()
                    
                    // Mini progress dots
                    HStack(spacing: 4) {
                        ForEach(0..<9, id: \.self) { index in
                            Circle()
                                .fill(isLevelCompleted(index: index) ? Color("AccentGlow") : Color.white.opacity(0.2))
                                .frame(width: 6, height: 6)
                        }
                    }
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color("HighlightTone").opacity(0.5))
                        .rotationEffect(.degrees(expanded ? 180 : 0))
                }
                .padding(16)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Expanded details
            if expanded {
                VStack(spacing: 12) {
                    Divider()
                        .background(Color.white.opacity(0.1))
                    
                    ForEach(Difficulty.allCases, id: \.self) { difficulty in
                        DifficultyProgressRow(
                            difficulty: difficulty,
                            levelProgress: progress.progress(for: difficulty)
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private func isLevelCompleted(index: Int) -> Bool {
        let difficulty = index / 3
        let level = index % 3
        
        let levelProgress: LevelProgress
        switch difficulty {
        case 0: levelProgress = progress.easy
        case 1: levelProgress = progress.normal
        case 2: levelProgress = progress.hard
        default: return false
        }
        
        switch level {
        case 0: return levelProgress.level1Completed
        case 1: return levelProgress.level2Completed
        case 2: return levelProgress.level3Completed
        default: return false
        }
    }
}

struct DifficultyProgressRow: View {
    let difficulty: Difficulty
    let levelProgress: LevelProgress
    
    var body: some View {
        HStack {
            Text(difficulty.rawValue)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(difficulty.color)
                .frame(width: 60, alignment: .leading)
            
            HStack(spacing: 8) {
                ForEach(1...3, id: \.self) { level in
                    HStack(spacing: 4) {
                        Image(systemName: isCompleted(level: level) ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 14))
                            .foregroundColor(isCompleted(level: level) ? difficulty.color : Color.white.opacity(0.3))
                        
                        Text("L\(level)")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(isCompleted(level: level) ? .white : Color.white.opacity(0.4))
                    }
                }
            }
            
            Spacer()
            
            Text("\(levelProgress.completedCount)/3")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(Color("HighlightTone"))
        }
    }
    
    private func isCompleted(level: Int) -> Bool {
        switch level {
        case 1: return levelProgress.level1Completed
        case 2: return levelProgress.level2Completed
        case 3: return levelProgress.level3Completed
        default: return false
        }
    }
}

#Preview {
    ProgressStatsView()
        .environmentObject(AppState())
}
