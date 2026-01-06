////
////  GameContainerView.swift
////  DF764
////
//
//import SwiftUI
//
//struct GameContainerView: View {
//    @EnvironmentObject var appState2: AppState2
//    @Environment(\.dismiss) var dismiss
//    
//    let gameType: GameType
//    let difficulty: Difficulty
//    
//    @State private var currentLevel = 1
//    @State private var showLevelComplete = false
//    @State private var showGameComplete = false
//    @State private var earnedShards = 0
//    
//    var body: some View {
//        ZStack {
//            Color("PrimaryBackground")
//                .ignoresSafeArea()
//            
//            VStack(spacing: 0) {
//                // Header
//                GameHeader(
//                    gameType: gameType,
//                    difficulty: difficulty,
//                    currentLevel: currentLevel,
//                    onClose: { dismiss() }
//                )
//                
//                // Game content
//                switch gameType {
//                case .pulsePathGrid:
//                    PulsePathGridGame(
//                        difficulty: difficulty,
//                        currentLevel: currentLevel,
//                        onLevelComplete: handleLevelComplete
//                    )
//                case .momentumShiftArena:
//                    MomentumShiftArenaGame(
//                        difficulty: difficulty,
//                        currentLevel: currentLevel,
//                        onLevelComplete: handleLevelComplete
//                    )
//                case .echoSequenceLabyrinth:
//                    EchoSequenceLabyrinthGame(
//                        difficulty: difficulty,
//                        currentLevel: currentLevel,
//                        onLevelComplete: handleLevelComplete
//                    )
//                }
//            }
//            
//            // Level complete overlay
//            if showLevelComplete {
//                LevelCompleteOverlay(
//                    level: currentLevel - 1,
//                    shards: earnedShards,
//                    hasNextLevel: currentLevel <= 3,
//                    onContinue: {
//                        showLevelComplete = false
//                        if currentLevel > 3 {
//                            showGameComplete = true
//                        }
//                    },
//                    onExit: { dismiss() }
//                )
//            }
//            
//            // Game complete overlay
//            if showGameComplete {
//                GameCompleteOverlay(
//                    gameType: gameType,
//                    difficulty: difficulty,
//                    onExit: { dismiss() }
//                )
//            }
//        }
//    }
//    
//    private func handleLevelComplete() {
//        let progress = appState2.progress(for: gameType).progress(for: difficulty)
//        var isNewCompletion = false
//        
//        switch currentLevel {
//        case 1: isNewCompletion = !progress.level1Completed
//        case 2: isNewCompletion = !progress.level2Completed
//        case 3: isNewCompletion = !progress.level3Completed
//        default: break
//        }
//        
//        appState2.completeLevel(gameType: gameType, difficulty: difficulty, level: currentLevel)
//        earnedShards = isNewCompletion ? difficulty.shardReward : 0
//        currentLevel += 1
//        
//        withAnimation(.spring(response: 0.4)) {
//            showLevelComplete = true
//        }
//    }
//}
//
//struct GameHeader: View {
//    let gameType: GameType
//    let difficulty: Difficulty
//    let currentLevel: Int
//    let onClose: () -> Void
//    
//    var body: some View {
//        HStack {
//            Button(action: onClose) {
//                Image(systemName: "xmark.circle.fill")
//                    .font(.system(size: 28))
//                    .foregroundColor(Color("HighlightTone").opacity(0.6))
//            }
//            
//            Spacer()
//            
//            VStack(spacing: 2) {
//                Text("Level \(currentLevel)")
//                    .font(.system(size: 18, weight: .bold, design: .rounded))
//                    .foregroundColor(.white)
//                
//                Text(difficulty.rawValue)
//                    .font(.system(size: 12, weight: .medium, design: .rounded))
//                    .foregroundColor(difficulty.color)
//            }
//            
//            Spacer()
//            
//            // Level indicators
//            HStack(spacing: 6) {
//                ForEach(1...3, id: \.self) { level in
//                    Circle()
//                        .fill(level <= currentLevel ? Color("AccentGlow") : Color.white.opacity(0.2))
//                        .frame(width: 10, height: 10)
//                }
//            }
//        }
//        .padding(.horizontal, 20)
//        .padding(.vertical, 16)
//        .background(Color("PrimaryBackground").opacity(0.95))
//    }
//}
//
//struct LevelCompleteOverlay: View {
//    let level: Int
//    let shards: Int
//    let hasNextLevel: Bool
//    let onContinue: () -> Void
//    let onExit: () -> Void
//    
//    @State private var animate = false
//    
//    var body: some View {
//        ZStack {
//            Color.black.opacity(0.7)
//                .ignoresSafeArea()
//            
//            VStack(spacing: 24) {
//                // Success icon
//                ZStack {
//                    Circle()
//                        .fill(
//                            RadialGradient(
//                                colors: [
//                                    Color("AccentGlow").opacity(0.4),
//                                    Color.clear
//                                ],
//                                center: .center,
//                                startRadius: 0,
//                                endRadius: 60
//                            )
//                        )
//                        .frame(width: 120, height: 120)
//                        .scaleEffect(animate ? 1.2 : 1.0)
//                    
//                    Image(systemName: "checkmark.circle.fill")
//                        .font(.system(size: 70))
//                        .foregroundColor(Color("AccentGlow"))
//                }
//                .scaleEffect(animate ? 1 : 0)
//                
//                Text("Level \(level) Complete!")
//                    .font(.system(size: 28, weight: .bold, design: .rounded))
//                    .foregroundColor(.white)
//                    .opacity(animate ? 1 : 0)
//                    .offset(y: animate ? 0 : 20)
//                
//                if shards > 0 {
//                    HStack(spacing: 8) {
//                        Image(systemName: "diamond.fill")
//                            .font(.system(size: 24))
//                            .foregroundColor(Color("HighlightTone"))
//                        
//                        Text("+\(shards) Shards")
//                            .font(.system(size: 22, weight: .semibold, design: .rounded))
//                            .foregroundColor(Color("HighlightTone"))
//                    }
//                    .opacity(animate ? 1 : 0)
//                    .scaleEffect(animate ? 1 : 0.5)
//                }
//                
//                VStack(spacing: 12) {
//                    if hasNextLevel {
//                        GlowingButton(title: "Next Level", action: {
//                            onContinue()
//                        })
//                    }
//                    
//                    GlowingButton(title: hasNextLevel ? "Exit" : "Complete", action: {
//                        if hasNextLevel {
//                            onExit()
//                        } else {
//                            onContinue()
//                        }
//                    }, isSecondary: hasNextLevel)
//                }
//                .padding(.horizontal, 40)
//                .padding(.top, 16)
//                .opacity(animate ? 1 : 0)
//            }
//            .padding(32)
//        }
//        .onAppear {
//            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
//                animate = true
//            }
//        }
//    }
//}
//
//struct GameCompleteOverlay: View {
//    let gameType: GameType
//    let difficulty: Difficulty
//    let onExit: () -> Void
//    
//    @State private var animate = false
//    
//    var body: some View {
//        ZStack {
//            Color.black.opacity(0.8)
//                .ignoresSafeArea()
//            
//            VStack(spacing: 28) {
//                // Trophy icon
//                ZStack {
//                    ForEach(0..<8, id: \.self) { index in
//                        Image(systemName: "diamond.fill")
//                            .font(.system(size: 16))
//                            .foregroundColor(Color("HighlightTone"))
//                            .offset(
//                                x: cos(Double(index) * .pi / 4) * 70,
//                                y: sin(Double(index) * .pi / 4) * 70
//                            )
//                            .opacity(animate ? 1 : 0)
//                            .scaleEffect(animate ? 1 : 0)
//                            .animation(
//                                .spring(response: 0.5).delay(Double(index) * 0.05 + 0.3),
//                                value: animate
//                            )
//                    }
//                    
//                    Image(systemName: "trophy.fill")
//                        .font(.system(size: 80))
//                        .foregroundColor(Color("AccentGlow"))
//                        .scaleEffect(animate ? 1 : 0)
//                }
//                
//                VStack(spacing: 8) {
//                    Text("Challenge Complete!")
//                        .font(.system(size: 30, weight: .bold, design: .rounded))
//                        .foregroundColor(.white)
//                    
//                    Text("\(difficulty.rawValue) difficulty mastered")
//                        .font(.system(size: 16, weight: .medium, design: .rounded))
//                        .foregroundColor(difficulty.color)
//                }
//                .opacity(animate ? 1 : 0)
//                .offset(y: animate ? 0 : 20)
//                
//                GlowingButton(title: "Continue") {
//                    onExit()
//                }
//                .padding(.horizontal, 40)
//                .padding(.top, 16)
//                .opacity(animate ? 1 : 0)
//            }
//        }
//        .onAppear {
//            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
//                animate = true
//            }
//        }
//    }
//}
//
//#Preview {
//    GameContainerView(gameType: .pulsePathGrid, difficulty: .easy)
//        .environmentObject(AppState2())
//}
//
