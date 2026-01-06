//
//  HomeView.swift
//  DF764
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState2: AppState2
    @State private var selectedGame: GameType?
    @State private var showSettings = false
    @State private var showStats = false
    
    var body: some View {
        NavigationStack {
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
                        .offset(x: geometry.size.width * 0.2, y: -geometry.size.height * 0.1)
                }
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Shifting Horizons")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Text("Choose your challenge")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(Color("HighlightTone").opacity(0.7))
                            }
                            
                            Spacer()
                            
                            // Shard counter
                            HStack(spacing: 6) {
                                Image(systemName: "diamond.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color("HighlightTone"))
                                Text("\(appState2.shards)")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color("HighlightTone").opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        
                        // Progress summary
                        ProgressSummaryCard(
                            totalLevels: appState2.totalCompletedLevels,
                            totalStars: appState2.totalStars,
                            maxLevels: GameType.allCases.count * 12,
                            maxStars: GameType.allCases.count * 12 * 3
                        )
                        .padding(.horizontal, 20)
                        
                        // Games section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Mini-Games")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                            
                            ForEach(GameType.allCases, id: \.self) { gameType in
                                GameCardNew(
                                    gameType: gameType,
                                    progress: appState2.progress(for: gameType),
                                    isUnlocked: appState2.isGameUnlocked(gameType),
                                    unlockRequirement: gameType.unlockRequirement
                                ) {
                                    if appState2.isGameUnlocked(gameType) {
                                        selectedGame = gameType
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.top, 8)
                        
                        // Bottom buttons
                        VStack(spacing: 12) {
                            GlowingButton(title: "Statistics", action: {
                                showStats = true
                            }, isSecondary: true)
                            
                            GlowingButton(title: "Settings", action: {
                                showSettings = true
                            }, isSecondary: true)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(item: $selectedGame) { gameType in
                LevelMapView(gameType: gameType)
                    .environmentObject(appState2)
            }
            .fullScreenCover(isPresented: $showStats) {
                ProgressStatsView()
                    .environmentObject(appState2)
            }
            .fullScreenCover(isPresented: $showSettings) {
                SettingsView()
                    .environmentObject(appState2)
            }
        }
    }
}

extension GameType: Identifiable {
    var id: String { rawValue }
}

struct ProgressSummaryCard: View {
    let totalLevels: Int
    let totalStars: Int
    let maxLevels: Int
    let maxStars: Int
    
    var body: some View {
        HStack(spacing: 24) {
            // Levels
            VStack(spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: "flag.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color("AccentGlow"))
                    Text("\(totalLevels)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                Text("Levels")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(Color("HighlightTone").opacity(0.7))
            }
            
            Divider()
                .frame(height: 40)
                .background(Color.white.opacity(0.2))
            
            // Stars
            VStack(spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color("HighlightTone"))
                    Text("\(totalStars)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                Text("Stars")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(Color("HighlightTone").opacity(0.7))
            }
            
            Divider()
                .frame(height: 40)
                .background(Color.white.opacity(0.2))
            
            // Games unlocked
            VStack(spacing: 6) {
                let unlockedGames = GameType.allCases.filter { totalLevels >= $0.unlockRequirement }.count
                HStack(spacing: 4) {
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color.purple)
                    Text("\(unlockedGames)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                Text("Games")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(Color("HighlightTone").opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct GameCardNew: View {
    let gameType: GameType
    let progress: GameProgressData
    let isUnlocked: Bool
    let unlockRequirement: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            isUnlocked ?
                            gameType.themeColor.opacity(0.2) :
                            Color.gray.opacity(0.2)
                        )
                        .frame(width: 60, height: 60)
                    
                    if isUnlocked {
                        Image(systemName: gameType.icon)
                            .font(.system(size: 26))
                            .foregroundColor(gameType.themeColor)
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color.gray.opacity(0.5))
                    }
                }
                
                // Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(gameType.rawValue)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(isUnlocked ? .white : Color.gray)
                    
                    if isUnlocked {
                        HStack(spacing: 12) {
                            // Levels
                            HStack(spacing: 4) {
                                Image(systemName: "flag.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(gameType.themeColor.opacity(0.7))
                                Text("\(progress.completedLevelsCount)/12")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(Color("HighlightTone").opacity(0.7))
                            }
                            
                            // Stars
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
                        Text("Complete \(unlockRequirement) levels to unlock")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(Color.gray.opacity(0.6))
                    }
                }
                
                Spacer()
                
                // Progress indicator or chevron
                if isUnlocked {
                    // Mini progress bar
                    VStack(spacing: 4) {
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 50, height: 6)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(gameType.themeColor)
                                .frame(width: 50 * CGFloat(progress.completedLevelsCount) / 12, height: 6)
                        }
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color("HighlightTone").opacity(0.5))
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isUnlocked ? gameType.themeColor.opacity(0.3) : Color.gray.opacity(0.2),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isUnlocked)
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState2())
}
