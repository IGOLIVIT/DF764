//
//  ChronoCascadeGame.swift
//  DF764
//

import SwiftUI
import Combine

struct ChronoCascadeGame: View {
    let level: Int
    let onComplete: (Int, Int) -> Void
    
    @State private var gameState: GamePlayState = .ready
    @State private var nodes: [TimingNode] = []
    @State private var currentNodeIndex: Int = 0
    @State private var score: Int = 0
    @State private var combo: Int = 0
    @State private var maxCombo: Int = 0
    @State private var perfectCount: Int = 0
    @State private var missCount: Int = 0
    @State private var nodeProgress: CGFloat = 0
    @State private var roundsCompleted: Int = 0
    
    private let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    
    private var config: LevelConfig {
        LevelConfig.forLevel(level)
    }
    
    struct LevelConfig {
        let nodeCount: Int
        let speed: Double
        let rounds: Int
        let perfectWindow: Double
        let goodWindow: Double
        let hasReverseNodes: Bool
        let hasSplitNodes: Bool
        
        static func forLevel(_ level: Int) -> LevelConfig {
            switch level {
            case 1: return LevelConfig(nodeCount: 4, speed: 1.0, rounds: 2, perfectWindow: 0.2, goodWindow: 0.35, hasReverseNodes: false, hasSplitNodes: false)
            case 2: return LevelConfig(nodeCount: 5, speed: 1.1, rounds: 2, perfectWindow: 0.18, goodWindow: 0.32, hasReverseNodes: false, hasSplitNodes: false)
            case 3: return LevelConfig(nodeCount: 5, speed: 1.2, rounds: 3, perfectWindow: 0.16, goodWindow: 0.30, hasReverseNodes: false, hasSplitNodes: false)
            case 4: return LevelConfig(nodeCount: 6, speed: 1.3, rounds: 3, perfectWindow: 0.15, goodWindow: 0.28, hasReverseNodes: true, hasSplitNodes: false)
            case 5: return LevelConfig(nodeCount: 6, speed: 1.4, rounds: 3, perfectWindow: 0.14, goodWindow: 0.26, hasReverseNodes: true, hasSplitNodes: false)
            case 6: return LevelConfig(nodeCount: 7, speed: 1.5, rounds: 4, perfectWindow: 0.13, goodWindow: 0.24, hasReverseNodes: true, hasSplitNodes: true)
            case 7: return LevelConfig(nodeCount: 7, speed: 1.6, rounds: 4, perfectWindow: 0.12, goodWindow: 0.22, hasReverseNodes: true, hasSplitNodes: true)
            case 8: return LevelConfig(nodeCount: 8, speed: 1.7, rounds: 4, perfectWindow: 0.11, goodWindow: 0.20, hasReverseNodes: true, hasSplitNodes: true)
            case 9: return LevelConfig(nodeCount: 8, speed: 1.8, rounds: 5, perfectWindow: 0.10, goodWindow: 0.18, hasReverseNodes: true, hasSplitNodes: true)
            case 10: return LevelConfig(nodeCount: 9, speed: 1.9, rounds: 5, perfectWindow: 0.09, goodWindow: 0.16, hasReverseNodes: true, hasSplitNodes: true)
            case 11: return LevelConfig(nodeCount: 9, speed: 2.0, rounds: 5, perfectWindow: 0.08, goodWindow: 0.14, hasReverseNodes: true, hasSplitNodes: true)
            case 12: return LevelConfig(nodeCount: 10, speed: 2.2, rounds: 6, perfectWindow: 0.07, goodWindow: 0.12, hasReverseNodes: true, hasSplitNodes: true)
            default: return LevelConfig(nodeCount: 4, speed: 1.0, rounds: 2, perfectWindow: 0.2, goodWindow: 0.35, hasReverseNodes: false, hasSplitNodes: false)
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 16) {
                // Stats bar
                HStack {
                    // Round
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Round")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(Color("HighlightTone").opacity(0.7))
                        Text("\(roundsCompleted + 1)/\(config.rounds)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // Combo
                    if combo > 1 {
                        HStack(spacing: 4) {
                            Text("x\(combo)")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(Color.mint)
                            Text("CHAIN")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundColor(Color.mint.opacity(0.7))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.mint.opacity(0.2))
                        )
                    }
                    
                    Spacer()
                    
                    // Score
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Score")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(Color("HighlightTone").opacity(0.7))
                        Text("\(score)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(Color.mint)
                    }
                }
                .padding(.horizontal, 24)
                
                // Accuracy indicator
                HStack(spacing: 20) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.mint)
                            .frame(width: 8, height: 8)
                        Text("Perfect: \(perfectCount)")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                        Text("Miss: \(missCount)")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                // Timing ring area
                ZStack {
                    // Outer ring
                    Circle()
                        .stroke(Color.mint.opacity(0.3), lineWidth: 4)
                        .frame(width: 250, height: 250)
                    
                    // Progress ring
                    Circle()
                        .trim(from: 0, to: nodeProgress)
                        .stroke(
                            LinearGradient(
                                colors: [Color.mint, Color.cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 250, height: 250)
                        .rotationEffect(.degrees(-90))
                    
                    // Nodes around the ring
                    ForEach(Array(nodes.enumerated()), id: \.element.id) { index, node in
                        NodeView(
                            node: node,
                            isActive: index == currentNodeIndex,
                            isPassed: index < currentNodeIndex
                        )
                        .position(nodePosition(for: index, total: nodes.count, in: 250))
                        .offset(x: 125, y: 125) // Center adjustment
                    }
                    
                    // Center info
                    VStack(spacing: 8) {
                        if gameState == .playing {
                            Text(currentNodeIndex < nodes.count ? "TAP!" : "")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(Color.mint)
                        } else if gameState == .ready {
                            Text("Ready")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                }
                .frame(width: 250, height: 250)
                .contentShape(Circle())
                .onTapGesture {
                    handleTap()
                }
                
                Spacer()
                
                // Feedback text
                if gameState == .playing {
                    Text(feedbackText)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(feedbackColor)
                        .frame(height: 30)
                }
                
                // Start button
                if gameState == .ready || gameState == .failed {
                    VStack(spacing: 8) {
                        GlowingButton(title: gameState == .ready ? "Start" : "Retry") {
                            startGame()
                        }
                        .padding(.horizontal, 40)
                        
                        Text("Tap when the ring reaches each node")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(Color.mint.opacity(0.7))
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .onReceive(timer) { _ in
            updateGame()
        }
        .onAppear {
            setupLevel()
        }
    }
    
    @State private var lastFeedback: TapResult = .none
    
    private var feedbackText: String {
        switch lastFeedback {
        case .perfect: return "PERFECT!"
        case .good: return "GOOD"
        case .miss: return "MISS"
        case .none: return ""
        }
    }
    
    private var feedbackColor: Color {
        switch lastFeedback {
        case .perfect: return Color.mint
        case .good: return Color("HighlightTone")
        case .miss: return Color.red
        case .none: return .clear
        }
    }
    
    private func nodePosition(for index: Int, total: Int, in diameter: CGFloat) -> CGPoint {
        let angle = (CGFloat(index) / CGFloat(total)) * 2 * .pi - .pi / 2
        let radius = diameter / 2
        return CGPoint(
            x: radius * cos(angle),
            y: radius * sin(angle)
        )
    }
    
    private func setupLevel() {
        gameState = .ready
        score = 0
        combo = 0
        maxCombo = 0
        perfectCount = 0
        missCount = 0
        roundsCompleted = 0
    }
    
    private func startGame() {
        generateNodes()
        currentNodeIndex = 0
        nodeProgress = 0
        combo = 0
        lastFeedback = .none
        gameState = .playing
    }
    
    private func generateNodes() {
        nodes = []
        for i in 0..<config.nodeCount {
            var type: NodeType = .normal
            
            if config.hasReverseNodes && i > 0 && Bool.random() && Double.random(in: 0...1) < 0.2 {
                type = .reverse
            } else if config.hasSplitNodes && i > 0 && Bool.random() && Double.random(in: 0...1) < 0.15 {
                type = .double
            }
            
            nodes.append(TimingNode(id: UUID(), type: type, wasHit: false))
        }
    }
    
    private func updateGame() {
        guard gameState == .playing else { return }
        
        // Progress the ring
        let progressSpeed = 0.002 * config.speed
        nodeProgress += progressSpeed
        
        // Check if we've passed the current node without tapping
        let nodeThreshold = CGFloat(currentNodeIndex + 1) / CGFloat(nodes.count)
        
        if nodeProgress > nodeThreshold + CGFloat(config.goodWindow) {
            // Missed!
            if currentNodeIndex < nodes.count && !nodes[currentNodeIndex].wasHit {
                handleMiss()
            }
        }
        
        // Check if round is complete
        if nodeProgress >= 1.0 {
            completeRound()
        }
    }
    
    private func handleTap() {
        guard gameState == .playing && currentNodeIndex < nodes.count else { return }
        
        let targetProgress = CGFloat(currentNodeIndex + 1) / CGFloat(nodes.count)
        let difference = abs(nodeProgress - targetProgress)
        
        if difference < CGFloat(config.perfectWindow) {
            // Perfect!
            handlePerfect()
        } else if difference < CGFloat(config.goodWindow) {
            // Good
            handleGood()
        } else {
            // Too early or too late
            handleMiss()
        }
    }
    
    private func handlePerfect() {
        nodes[currentNodeIndex].wasHit = true
        perfectCount += 1
        combo += 1
        maxCombo = max(maxCombo, combo)
        
        let points = 100 + (combo * 10)
        score += points
        
        lastFeedback = .perfect
        currentNodeIndex += 1
        
        clearFeedback()
    }
    
    private func handleGood() {
        nodes[currentNodeIndex].wasHit = true
        combo += 1
        maxCombo = max(maxCombo, combo)
        
        let points = 50 + (combo * 5)
        score += points
        
        lastFeedback = .good
        currentNodeIndex += 1
        
        clearFeedback()
    }
    
    private func handleMiss() {
        missCount += 1
        combo = 0
        
        lastFeedback = .miss
        currentNodeIndex += 1
        
        // Check for too many misses
        if missCount >= config.nodeCount / 2 + 1 {
            gameState = .failed
            return
        }
        
        clearFeedback()
    }
    
    private func clearFeedback() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if lastFeedback != .none {
                lastFeedback = .none
            }
        }
    }
    
    private func completeRound() {
        roundsCompleted += 1
        
        if roundsCompleted >= config.rounds {
            // Level complete
            gameState = .success
            let stars = calculateStars()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                onComplete(score, stars)
            }
        } else {
            // Start next round
            nodeProgress = 0
            currentNodeIndex = 0
            generateNodes()
        }
    }
    
    private func calculateStars() -> Int {
        let accuracy = Double(perfectCount) / Double(perfectCount + missCount + 1)
        let comboBonus = Double(maxCombo) / Double(config.nodeCount * config.rounds)
        
        if accuracy > 0.8 && comboBonus > 0.5 { return 3 }
        if accuracy > 0.5 { return 2 }
        return 1
    }
}

// MARK: - Supporting Types

struct TimingNode: Identifiable {
    let id: UUID
    let type: NodeType
    var wasHit: Bool
}

enum NodeType {
    case normal
    case reverse  // Requires holding
    case double   // Requires double tap
}

enum TapResult {
    case perfect
    case good
    case miss
    case none
}

struct NodeView: View {
    let node: TimingNode
    let isActive: Bool
    let isPassed: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(nodeColor)
                .frame(width: 30, height: 30)
            
            if node.type == .reverse {
                Image(systemName: "arrow.uturn.backward")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            } else if node.type == .double {
                Text("2")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            if isActive {
                Circle()
                    .stroke(Color.white, lineWidth: 3)
                    .frame(width: 40, height: 40)
            }
        }
    }
    
    private var nodeColor: Color {
        if isPassed {
            return node.wasHit ? Color.mint.opacity(0.5) : Color.red.opacity(0.5)
        } else if isActive {
            return Color.mint
        } else {
            return Color.white.opacity(0.3)
        }
    }
}

#Preview {
    ZStack {
        Color("PrimaryBackground")
            .ignoresSafeArea()
        
        ChronoCascadeGame(level: 1, onComplete: { _, _ in })
    }
}

