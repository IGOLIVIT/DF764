//
//  PulsePathGridGame.swift
//  DF764
//

import SwiftUI

struct PulsePathGridGame: View {
    let difficulty: Difficulty
    let currentLevel: Int
    let onLevelComplete: () -> Void
    
    @State private var gridSize = 3
    @State private var sequence: [Int] = []
    @State private var playerSequence: [Int] = []
    @State private var isShowingSequence = true
    @State private var currentShowIndex = 0
    @State private var highlightedTile: Int? = nil
    @State private var wrongTile: Int? = nil
    @State private var gameState: GamePlayState = .ready
    @State private var showInstructions = true
    
    private var sequenceLength: Int {
        switch currentLevel {
        case 1: return 3
        case 2: return 4
        case 3: return 5
        default: return 3
        }
    }
    
    private var displaySpeed: Double {
        switch difficulty {
        case .easy: return 1.0
        case .normal: return 0.75
        case .hard: return 0.5
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 24) {
                Spacer()
                
                // Status text
                VStack(spacing: 8) {
                    Text(statusText)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    if gameState == .playing {
                        Text("\(playerSequence.count)/\(sequenceLength)")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(Color("HighlightTone"))
                    }
                }
                .frame(height: 60)
                
                // Grid
                let tileSize = min((geometry.size.width - 80) / CGFloat(gridSize), 100.0)
                
                LazyVGrid(
                    columns: Array(repeating: GridItem(.fixed(tileSize), spacing: 12), count: gridSize),
                    spacing: 12
                ) {
                    ForEach(0..<(gridSize * gridSize), id: \.self) { index in
                        TileView(
                            index: index,
                            isHighlighted: highlightedTile == index,
                            isWrong: wrongTile == index,
                            isInPlayerSequence: playerSequence.contains(index),
                            size: tileSize,
                            onTap: {
                                handleTileTap(index)
                            }
                        )
                        .disabled(gameState != .playing)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Action button
                if gameState == .ready || gameState == .failed {
                    GlowingButton(title: gameState == .ready ? "Start" : "Try Again") {
                        startGame()
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
                
                if showInstructions && gameState == .ready {
                    Text("Watch the glowing tiles, then repeat the pattern")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(Color("HighlightTone").opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            setupGame()
        }
    }
    
    private var statusText: String {
        switch gameState {
        case .ready:
            return "Ready?"
        case .showing:
            return "Watch carefully..."
        case .playing:
            return "Repeat the pattern"
        case .success:
            return "Perfect!"
        case .failed:
            return "Wrong sequence"
        }
    }
    
    private func setupGame() {
        gridSize = 3
        gameState = .ready
        sequence = []
        playerSequence = []
        highlightedTile = nil
        wrongTile = nil
    }
    
    private func startGame() {
        showInstructions = false
        gameState = .showing
        playerSequence = []
        wrongTile = nil
        generateSequence()
        showSequence()
    }
    
    private func generateSequence() {
        sequence = []
        var availableTiles = Array(0..<(gridSize * gridSize))
        
        for _ in 0..<sequenceLength {
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
            // Finished showing sequence
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                gameState = .playing
            }
            return
        }
        
        let tile = sequence[currentShowIndex]
        
        withAnimation(.easeInOut(duration: 0.2)) {
            highlightedTile = tile
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + displaySpeed * 0.6) {
            withAnimation(.easeInOut(duration: 0.2)) {
                highlightedTile = nil
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + displaySpeed * 0.4) {
                currentShowIndex += 1
                showNextInSequence()
            }
        }
    }
    
    private func handleTileTap(_ index: Int) {
        guard gameState == .playing else { return }
        
        let expectedTile = sequence[playerSequence.count]
        
        if index == expectedTile {
            // Correct tap
            withAnimation(.spring(response: 0.2)) {
                playerSequence.append(index)
                highlightedTile = index
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation {
                    highlightedTile = nil
                }
            }
            
            if playerSequence.count == sequence.count {
                // Level complete
                gameState = .success
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    onLevelComplete()
                }
            }
        } else {
            // Wrong tap
            gameState = .failed
            withAnimation(.spring(response: 0.2)) {
                wrongTile = index
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                wrongTile = nil
            }
        }
    }
}

struct TileView: View {
    let index: Int
    let isHighlighted: Bool
    let isWrong: Bool
    let isInPlayerSequence: Bool
    let size: CGFloat
    let onTap: () -> Void
    
    @State private var pulseAnimation = false
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Base tile
                RoundedRectangle(cornerRadius: 12)
                    .fill(tileColor)
                    .frame(width: size, height: size)
                
                // Glow effect when highlighted
                if isHighlighted {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("AccentGlow"))
                        .frame(width: size, height: size)
                        .blur(radius: 8)
                        .opacity(0.6)
                    
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("AccentGlow"))
                        .frame(width: size, height: size)
                }
                
                // Wrong indicator
                if isWrong {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.red)
                        .frame(width: size, height: size)
                    
                    Image(systemName: "xmark")
                        .font(.system(size: size * 0.4, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Border
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isHighlighted ? Color("AccentGlow") :
                        isInPlayerSequence ? Color("HighlightTone").opacity(0.5) :
                        Color.white.opacity(0.2),
                        lineWidth: isHighlighted ? 3 : 1.5
                    )
                    .frame(width: size, height: size)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isHighlighted ? 1.05 : 1.0)
        .animation(.spring(response: 0.2), value: isHighlighted)
    }
    
    private var tileColor: Color {
        if isHighlighted {
            return Color("AccentGlow")
        } else if isWrong {
            return Color.red
        } else if isInPlayerSequence {
            return Color("HighlightTone").opacity(0.3)
        } else {
            return Color.white.opacity(0.08)
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
        
        PulsePathGridGame(
            difficulty: .easy,
            currentLevel: 1,
            onLevelComplete: {}
        )
    }
}


