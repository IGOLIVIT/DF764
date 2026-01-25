//
//  PulsePathGridGame.swift
//  DF764
//

import SwiftUI

struct PulsePathGridGame: View {
    let level: Int
    let onComplete: (Int, Int) -> Void
    
    @State private var gridSize: Int = 3
    @State private var sequence: [Int] = []
    @State private var playerSequence: [Int] = []
    @State private var isShowingSequence = true
    @State private var currentShowIndex = 0
    @State private var highlightedTile: Int? = nil
    @State private var wrongTile: Int? = nil
    @State private var gameState: GamePlayState = .ready
    @State private var score: Int = 0
    @State private var round: Int = 1
    @State private var totalRounds: Int = 3
    @State private var timeBonus: Int = 100
    @State private var obstacles: Set<Int> = []
    @State private var bonusTiles: Set<Int> = []
    
    // Level configuration
    private var config: LevelConfig {
        LevelConfig.forLevel(level)
    }
    
    struct LevelConfig {
        let gridSize: Int
        let sequenceLength: Int
        let displaySpeed: Double
        let hasObstacles: Bool
        let hasBonusTiles: Bool
        let rounds: Int
        
        static func forLevel(_ level: Int) -> LevelConfig {
            switch level {
            case 1: return LevelConfig(gridSize: 3, sequenceLength: 3, displaySpeed: 1.0, hasObstacles: false, hasBonusTiles: false, rounds: 2)
            case 2: return LevelConfig(gridSize: 3, sequenceLength: 4, displaySpeed: 0.9, hasObstacles: false, hasBonusTiles: false, rounds: 2)
            case 3: return LevelConfig(gridSize: 3, sequenceLength: 4, displaySpeed: 0.8, hasObstacles: false, hasBonusTiles: true, rounds: 3)
            case 4: return LevelConfig(gridSize: 4, sequenceLength: 4, displaySpeed: 0.8, hasObstacles: false, hasBonusTiles: true, rounds: 3)
            case 5: return LevelConfig(gridSize: 4, sequenceLength: 5, displaySpeed: 0.75, hasObstacles: true, hasBonusTiles: true, rounds: 3)
            case 6: return LevelConfig(gridSize: 4, sequenceLength: 5, displaySpeed: 0.7, hasObstacles: true, hasBonusTiles: true, rounds: 3)
            case 7: return LevelConfig(gridSize: 4, sequenceLength: 6, displaySpeed: 0.65, hasObstacles: true, hasBonusTiles: true, rounds: 4)
            case 8: return LevelConfig(gridSize: 5, sequenceLength: 5, displaySpeed: 0.65, hasObstacles: true, hasBonusTiles: true, rounds: 4)
            case 9: return LevelConfig(gridSize: 5, sequenceLength: 6, displaySpeed: 0.6, hasObstacles: true, hasBonusTiles: true, rounds: 4)
            case 10: return LevelConfig(gridSize: 5, sequenceLength: 7, displaySpeed: 0.55, hasObstacles: true, hasBonusTiles: true, rounds: 5)
            case 11: return LevelConfig(gridSize: 5, sequenceLength: 8, displaySpeed: 0.5, hasObstacles: true, hasBonusTiles: true, rounds: 5)
            case 12: return LevelConfig(gridSize: 6, sequenceLength: 8, displaySpeed: 0.45, hasObstacles: true, hasBonusTiles: true, rounds: 5)
            default: return LevelConfig(gridSize: 3, sequenceLength: 3, displaySpeed: 1.0, hasObstacles: false, hasBonusTiles: false, rounds: 2)
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                // Status bar
                HStack {
                    // Round indicator
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Round")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(Color("HighlightTone").opacity(0.7))
                        Text("\(round)/\(totalRounds)")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // Score
                    VStack(spacing: 4) {
                        Text("Score")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(Color("HighlightTone").opacity(0.7))
                        Text("\(score)")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(Color("AccentGlow"))
                    }
                    
                    Spacer()
                    
                    // Sequence progress
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Progress")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(Color("HighlightTone").opacity(0.7))
                        Text("\(playerSequence.count)/\(sequence.count)")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 24)
                
                // Status text
                Text(statusText)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(height: 30)
                
                Spacer()
                
                // Grid
                let tileSize = min((geometry.size.width - 60) / CGFloat(gridSize), 80.0)
                
                LazyVGrid(
                    columns: Array(repeating: GridItem(.fixed(tileSize), spacing: 8), count: gridSize),
                    spacing: 8
                ) {
                    ForEach(0..<(gridSize * gridSize), id: \.self) { index in
                        PulseTileView(
                            index: index,
                            isHighlighted: highlightedTile == index,
                            isWrong: wrongTile == index,
                            isInPlayerSequence: playerSequence.contains(index),
                            isObstacle: obstacles.contains(index),
                            isBonus: bonusTiles.contains(index),
                            size: tileSize,
                            onTap: {
                                handleTileTap(index)
                            }
                        )
                        .disabled(gameState != .playing || obstacles.contains(index))
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Action button
                if gameState == .ready || gameState == .failed {
                    GlowingButton(title: gameState == .ready ? "Start" : "Try Again") {
                        startRound()
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 30)
                }
            }
        }
        .onAppear {
            setupLevel()
        }
    }
    
    private var statusText: String {
        switch gameState {
        case .ready:
            return "Ready for Round \(round)?"
        case .showing:
            return "Watch the pattern..."
        case .playing:
            return "Repeat the pattern"
        case .success:
            return "Perfect!"
        case .failed:
            return "Wrong tile!"
        }
    }
    
    private func setupLevel() {
        gridSize = config.gridSize
        totalRounds = config.rounds
        round = 1
        score = 0
        gameState = .ready
        sequence = []
        playerSequence = []
        highlightedTile = nil
        wrongTile = nil
        setupObstaclesAndBonuses()
    }
    
    private func setupObstaclesAndBonuses() {
        obstacles.removeAll()
        bonusTiles.removeAll()
        
        let totalTiles = gridSize * gridSize
        
        if config.hasObstacles {
            // Add 1-2 obstacles
            let obstacleCount = level > 8 ? 2 : 1
            while obstacles.count < obstacleCount {
                let randomTile = Int.random(in: 0..<totalTiles)
                obstacles.insert(randomTile)
            }
        }
        
        if config.hasBonusTiles {
            // Add 1-2 bonus tiles
            let bonusCount = level > 6 ? 2 : 1
            while bonusTiles.count < bonusCount {
                let randomTile = Int.random(in: 0..<totalTiles)
                if !obstacles.contains(randomTile) {
                    bonusTiles.insert(randomTile)
                }
            }
        }
    }
    
    private func startRound() {
        gameState = .showing
        playerSequence = []
        wrongTile = nil
        timeBonus = 100
        generateSequence()
        showSequence()
    }
    
    private func generateSequence() {
        sequence = []
        var availableTiles = Array(0..<(gridSize * gridSize)).filter { !obstacles.contains($0) }
        
        let length = config.sequenceLength + (round - 1) // Increase sequence each round
        
        for _ in 0..<length {
            if let randomIndex = availableTiles.randomElement() {
                sequence.append(randomIndex)
                availableTiles.removeAll { $0 == randomIndex }
            }
        }
    }
    
    private func showSequence() {
        currentShowIndex = 0
        showNextInSequence()
    }
    
    private func showNextInSequence() {
        guard currentShowIndex < sequence.count else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                gameState = .playing
            }
            return
        }
        
        let tile = sequence[currentShowIndex]
        highlightedTile = tile
        
        DispatchQueue.main.asyncAfter(deadline: .now() + config.displaySpeed * 0.6) {
            highlightedTile = nil
            
            DispatchQueue.main.asyncAfter(deadline: .now() + config.displaySpeed * 0.3) {
                currentShowIndex += 1
                showNextInSequence()
            }
        }
    }
    
    private func handleTileTap(_ index: Int) {
        guard gameState == .playing else { return }
        
        let expectedTile = sequence[playerSequence.count]
        
        if index == expectedTile {
            playerSequence.append(index)
            highlightedTile = index
            
            // Haptic and sound feedback for correct tap
            HapticsManager.shared.tileTap()
            AudioManager.shared.playTileTap()
            
            // Bonus points for bonus tiles
            if bonusTiles.contains(index) {
                score += 25
                HapticsManager.shared.collectiblePickup()
                AudioManager.shared.playCollectible()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                highlightedTile = nil
            }
            
            if playerSequence.count == sequence.count {
                // Round complete
                score += 50 + timeBonus
                gameState = .success
                HapticsManager.shared.correctSequence()
                AudioManager.shared.playCorrect()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if round < totalRounds {
                        round += 1
                        setupObstaclesAndBonuses()
                        gameState = .ready
                    } else {
                        // Level complete
                        let stars = calculateStars()
                        HapticsManager.shared.levelComplete()
                        AudioManager.shared.playLevelComplete()
                        onComplete(score, stars)
                    }
                }
            }
        } else {
            gameState = .failed
            wrongTile = index
            score = max(0, score - 20)
            
            // Haptic and sound feedback for wrong tap
            HapticsManager.shared.wrongSequence()
            AudioManager.shared.playError()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                wrongTile = nil
            }
        }
    }
    
    private func calculateStars() -> Int {
        let maxPossibleScore = totalRounds * (50 + 100) + (totalRounds * 25 * 2) // Base + time bonus + potential bonus tiles
        let percentage = Double(score) / Double(maxPossibleScore)
        
        if percentage >= 0.8 { return 3 }
        if percentage >= 0.5 { return 2 }
        return 1
    }
}

struct PulseTileView: View {
    let index: Int
    let isHighlighted: Bool
    let isWrong: Bool
    let isInPlayerSequence: Bool
    let isObstacle: Bool
    let isBonus: Bool
    let size: CGFloat
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Base tile
                RoundedRectangle(cornerRadius: 10)
                    .fill(tileColor)
                    .frame(width: size, height: size)
                
                // Glow effect when highlighted
                if isHighlighted {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("AccentGlow"))
                        .frame(width: size, height: size)
                        .blur(radius: 6)
                        .opacity(0.5)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("AccentGlow"))
                        .frame(width: size, height: size)
                }
                
                // Wrong indicator
                if isWrong {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.red)
                        .frame(width: size, height: size)
                    
                    Image(systemName: "xmark")
                        .font(.system(size: size * 0.35, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Obstacle indicator
                if isObstacle {
                    Image(systemName: "xmark")
                        .font(.system(size: size * 0.3, weight: .medium))
                        .foregroundColor(Color.gray.opacity(0.5))
                }
                
                // Bonus indicator
                if isBonus && !isHighlighted && !isInPlayerSequence {
                    Image(systemName: "star.fill")
                        .font(.system(size: size * 0.25))
                        .foregroundColor(Color("HighlightTone").opacity(0.6))
                }
                
                // Border
                RoundedRectangle(cornerRadius: 10)
                    .stroke(borderColor, lineWidth: isHighlighted ? 2 : 1)
                    .frame(width: size, height: size)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var tileColor: Color {
        if isObstacle {
            return Color.gray.opacity(0.15)
        } else if isHighlighted {
            return Color("AccentGlow")
        } else if isWrong {
            return Color.red
        } else if isInPlayerSequence {
            return Color("HighlightTone").opacity(0.3)
        } else if isBonus {
            return Color("HighlightTone").opacity(0.1)
        } else {
            return Color.white.opacity(0.08)
        }
    }
    
    private var borderColor: Color {
        if isObstacle {
            return Color.gray.opacity(0.3)
        } else if isHighlighted {
            return Color("AccentGlow")
        } else if isBonus {
            return Color("HighlightTone").opacity(0.4)
        } else {
            return Color.white.opacity(0.2)
        }
    }
}

enum GamePlayState {
    case ready
    case showing
    case playing
    case success
    case failed
}

#Preview {
    ZStack {
        Color("PrimaryBackground")
            .ignoresSafeArea()
        
        PulsePathGridGame(level: 5, onComplete: { _, _ in })
    }
}
