//
//  HomeView.swift
//  DF764
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedGame: GameType?
    @State private var showSettings = false
    @State private var showStats = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("PrimaryBackground")
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header with shard counter
                        HStack {
                            Spacer()
                            ShardCounter(count: appState.shards)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        
                        // Hero section
                        VStack(spacing: 12) {
                            Text("Shifting Horizons")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Choose your challenge")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(Color("HighlightTone").opacity(0.8))
                        }
                        .padding(.top, 20)
                        
                        // Game cards
                        VStack(spacing: 16) {
                            ForEach(GameType.allCases, id: \.self) { gameType in
                                GameCard(gameType: gameType) {
                                    selectedGame = gameType
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        
                        // Bottom buttons
                        VStack(spacing: 12) {
                            GlowingButton(title: "Progress Stats", action: {
                                showStats = true
                            }, isSecondary: true)
                            
                            GlowingButton(title: "Settings", action: {
                                showSettings = true
                            }, isSecondary: true)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(item: $selectedGame) { gameType in
                DifficultySelectionView(gameType: gameType)
                    .environmentObject(appState)
            }
            .fullScreenCover(isPresented: $showStats) {
                ProgressStatsView()
                    .environmentObject(appState)
            }
            .fullScreenCover(isPresented: $showSettings) {
                SettingsView()
                    .environmentObject(appState)
            }
        }
    }
}

extension GameType: Identifiable {
    var id: String { rawValue }
}

struct DifficultySelectionView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    let gameType: GameType
    
    @State private var selectedDifficulty: Difficulty?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("PrimaryBackground")
                    .ignoresSafeArea()
                
                // Subtle background glow
                GeometryReader { geometry in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color("AccentGlow").opacity(0.2),
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
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [
                                                Color("AccentGlow").opacity(0.3),
                                                Color.clear
                                            ],
                                            center: .center,
                                            startRadius: 0,
                                            endRadius: 50
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: gameType.icon)
                                    .font(.system(size: 44, weight: .medium))
                                    .foregroundColor(Color("AccentGlow"))
                            }
                            
                            Text(gameType.rawValue)
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text(gameType.description)
                                .font(.system(size: 15, weight: .regular, design: .rounded))
                                .foregroundColor(Color("HighlightTone").opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        .padding(.top, 40)
                        
                        // Difficulty selection
                        VStack(spacing: 16) {
                            Text("Select Difficulty")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                            
                            ForEach(Difficulty.allCases, id: \.self) { difficulty in
                                DifficultyCard(
                                    difficulty: difficulty,
                                    progress: appState.progress(for: gameType).progress(for: difficulty)
                                ) {
                                    selectedDifficulty = difficulty
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Color("HighlightTone").opacity(0.6))
                    }
                }
            }
            .fullScreenCover(item: $selectedDifficulty) { difficulty in
                GameContainerView(gameType: gameType, difficulty: difficulty)
                    .environmentObject(appState)
            }
        }
    }
}

extension Difficulty: Identifiable {
    var id: String { rawValue }
}

struct DifficultyCard: View {
    let difficulty: Difficulty
    let progress: LevelProgress
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Difficulty indicator
                ZStack {
                    Circle()
                        .fill(difficulty.color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Circle()
                        .stroke(difficulty.color, lineWidth: 2)
                        .frame(width: 50, height: 50)
                    
                    Text(String(difficulty.shardReward))
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(difficulty.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(difficulty.rawValue)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("\(progress.completedCount)/3 levels completed")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(Color("HighlightTone").opacity(0.7))
                }
                
                Spacer()
                
                // Progress indicators
                HStack(spacing: 6) {
                    Circle()
                        .fill(progress.level1Completed ? difficulty.color : Color.white.opacity(0.2))
                        .frame(width: 10, height: 10)
                    Circle()
                        .fill(progress.level2Completed ? difficulty.color : Color.white.opacity(0.2))
                        .frame(width: 10, height: 10)
                    Circle()
                        .fill(progress.level3Completed ? difficulty.color : Color.white.opacity(0.2))
                        .frame(width: 10, height: 10)
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("HighlightTone").opacity(0.5))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(difficulty.color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState())
}
