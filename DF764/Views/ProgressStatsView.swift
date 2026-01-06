//
//  ProgressStatsView.swift
//  DF764
//

import SwiftUI

struct ProgressStatsView: View {
    @EnvironmentObject var appState2: AppState2
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
                    
                    Text("Statistics")
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
                    VStack(spacing: 24) {
                        // Total shards card
                        TotalShardsCard(shards: appState2.shards)
                        
                        // Overall stats
                        OverallStatsCard(
                            totalLevels: appState2.totalCompletedLevels,
                            maxLevels: GameType.allCases.count * 12,
                            totalStars: appState2.totalStars,
                            maxStars: GameType.allCases.count * 12 * 3
                        )
                        
                        // Per-game stats
                        VStack(spacing: 16) {
                            Text("Game Progress")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            ForEach(GameType.allCases, id: \.self) { gameType in
                                GameStatsCard(
                                    gameType: gameType,
                                    progress: appState2.progress(for: gameType),
                                    isUnlocked: appState2.isGameUnlocked(gameType)
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
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .stroke(Color("HighlightTone").opacity(0.2 - Double(index) * 0.05), lineWidth: 2)
                        .frame(width: CGFloat(80 + index * 20), height: CGFloat(80 + index * 20))
                }
                
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
    let totalStars: Int
    let maxStars: Int
    
    var levelProgress: Double {
        Double(totalLevels) / Double(maxLevels)
    }
    
    var starProgress: Double {
        Double(totalStars) / Double(maxStars)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Levels progress
            VStack(spacing: 8) {
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "flag.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color("AccentGlow"))
                        Text("Levels Completed")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("\(totalLevels)/\(maxLevels)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(Color("AccentGlow"))
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white.opacity(0.1))
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color("AccentGlow"))
                            .frame(width: geometry.size.width * levelProgress)
                    }
                }
                .frame(height: 10)
            }
            
            // Stars progress
            VStack(spacing: 8) {
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color("HighlightTone"))
                        Text("Stars Earned")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("\(totalStars)/\(maxStars)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(Color("HighlightTone"))
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white.opacity(0.1))
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color("HighlightTone"))
                            .frame(width: geometry.size.width * starProgress)
                    }
                }
                .frame(height: 10)
            }
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

struct GameStatsCard: View {
    let gameType: GameType
    let progress: GameProgressData
    let isUnlocked: Bool
    
    @State private var expanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: { if isUnlocked { expanded.toggle() } }) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(isUnlocked ? gameType.themeColor.opacity(0.2) : Color.gray.opacity(0.2))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: isUnlocked ? gameType.icon : "lock.fill")
                            .font(.system(size: 20))
                            .foregroundColor(isUnlocked ? gameType.themeColor : Color.gray.opacity(0.5))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(gameType.rawValue)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(isUnlocked ? .white : Color.gray)
                        
                        if isUnlocked {
                            HStack(spacing: 12) {
                                HStack(spacing: 4) {
                                    Image(systemName: "flag.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(gameType.themeColor.opacity(0.7))
                                    Text("\(progress.completedLevelsCount)/12")
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundColor(Color("HighlightTone").opacity(0.7))
                                }
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(Color("HighlightTone").opacity(0.7))
                                    Text("\(progress.totalStars)/36")
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundColor(Color("HighlightTone").opacity(0.7))
                                }
                            }
                        } else {
                            Text("Locked")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(Color.gray.opacity(0.6))
                        }
                    }
                    
                    Spacer()
                    
                    if isUnlocked {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color("HighlightTone").opacity(0.5))
                            .rotationEffect(.degrees(expanded ? 180 : 0))
                    }
                }
                .padding(16)
            }
            .buttonStyle(PlainButtonStyle())
            
            if expanded && isUnlocked {
                VStack(spacing: 12) {
                    Divider()
                        .background(Color.white.opacity(0.1))
                    
                    // Level grid
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6),
                        spacing: 8
                    ) {
                        ForEach(progress.levels) { level in
                            LevelMiniCell(level: level, themeColor: gameType.themeColor)
                        }
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
                        .stroke(isUnlocked ? gameType.themeColor.opacity(0.2) : Color.gray.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct LevelMiniCell: View {
    let level: LevelData
    let themeColor: Color
    
    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(level.isCompleted ? themeColor.opacity(0.3) : Color.white.opacity(0.1))
                    .frame(width: 36, height: 36)
                
                if level.isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(themeColor)
                } else {
                    Text("\(level.id)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.5))
                }
            }
            
            if level.isCompleted {
                HStack(spacing: 1) {
                    ForEach(1...3, id: \.self) { star in
                        Image(systemName: star <= level.stars ? "star.fill" : "star")
                            .font(.system(size: 6))
                            .foregroundColor(star <= level.stars ? Color("HighlightTone") : Color.white.opacity(0.3))
                    }
                }
            }
        }
    }
}

#Preview {
    ProgressStatsView()
        .environmentObject(AppState2())
}
