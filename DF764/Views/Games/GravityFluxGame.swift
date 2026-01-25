//
//  GravityFluxGame.swift
//  DF764
//

import SwiftUI
import Combine

struct GravityFluxGame: View {
    let level: Int
    let onComplete: (Int, Int) -> Void
    
    @State private var gameState: GamePlayState = .ready
    @State private var orbPosition: CGPoint = .zero
    @State private var orbVelocity: CGPoint = .zero
    @State private var gravityDirection: GravityDirection = .down
    @State private var targetPosition: CGPoint = .zero
    @State private var obstacles: [Obstacle] = []
    @State private var portals: [Portal] = []
    @State private var collectibles: [Collectible] = []
    @State private var collectedCount: Int = 0
    @State private var score: Int = 0
    @State private var timeRemaining: Double = 0
    @State private var moves: Int = 0
    @State private var gameAreaSize: CGSize = .zero
    
    private let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    
    private var config: LevelConfig {
        LevelConfig.forLevel(level)
    }
    
    struct LevelConfig {
        let timeLimit: Double
        let obstacleCount: Int
        let collectibleCount: Int
        let hasPortals: Bool
        let gravityStrength: Double
        let maxMoves: Int
        
        static func forLevel(_ level: Int) -> LevelConfig {
            switch level {
            case 1: return LevelConfig(timeLimit: 45, obstacleCount: 2, collectibleCount: 1, hasPortals: false, gravityStrength: 150, maxMoves: 10)
            case 2: return LevelConfig(timeLimit: 45, obstacleCount: 3, collectibleCount: 2, hasPortals: false, gravityStrength: 160, maxMoves: 12)
            case 3: return LevelConfig(timeLimit: 50, obstacleCount: 4, collectibleCount: 2, hasPortals: false, gravityStrength: 170, maxMoves: 12)
            case 4: return LevelConfig(timeLimit: 50, obstacleCount: 4, collectibleCount: 3, hasPortals: true, gravityStrength: 180, maxMoves: 15)
            case 5: return LevelConfig(timeLimit: 55, obstacleCount: 5, collectibleCount: 3, hasPortals: true, gravityStrength: 190, maxMoves: 15)
            case 6: return LevelConfig(timeLimit: 55, obstacleCount: 6, collectibleCount: 3, hasPortals: true, gravityStrength: 200, maxMoves: 18)
            case 7: return LevelConfig(timeLimit: 60, obstacleCount: 6, collectibleCount: 4, hasPortals: true, gravityStrength: 210, maxMoves: 18)
            case 8: return LevelConfig(timeLimit: 60, obstacleCount: 7, collectibleCount: 4, hasPortals: true, gravityStrength: 220, maxMoves: 20)
            case 9: return LevelConfig(timeLimit: 65, obstacleCount: 8, collectibleCount: 5, hasPortals: true, gravityStrength: 230, maxMoves: 20)
            case 10: return LevelConfig(timeLimit: 65, obstacleCount: 8, collectibleCount: 5, hasPortals: true, gravityStrength: 240, maxMoves: 22)
            case 11: return LevelConfig(timeLimit: 70, obstacleCount: 9, collectibleCount: 6, hasPortals: true, gravityStrength: 250, maxMoves: 22)
            case 12: return LevelConfig(timeLimit: 70, obstacleCount: 10, collectibleCount: 6, hasPortals: true, gravityStrength: 260, maxMoves: 25)
            default: return LevelConfig(timeLimit: 45, obstacleCount: 2, collectibleCount: 1, hasPortals: false, gravityStrength: 150, maxMoves: 10)
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let gameHeight = geometry.size.height - 200
            
            VStack(spacing: 12) {
                // Stats bar
                HStack {
                    // Collectibles
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color.purple)
                        Text("\(collectedCount)/\(collectibles.count)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // Moves
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.turn.down.right")
                            .font(.system(size: 14))
                            .foregroundColor(Color("HighlightTone"))
                        Text("\(moves)/\(config.maxMoves)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(moves >= config.maxMoves ? Color.red : .white)
                    }
                    
                    Spacer()
                    
                    // Timer
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 14))
                            .foregroundColor(timeRemaining < 10 ? Color("AccentGlow") : Color("HighlightTone"))
                        Text(String(format: "%.0f", max(0, timeRemaining)))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(timeRemaining < 10 ? Color("AccentGlow") : .white)
                    }
                }
                .padding(.horizontal, 24)
                
                // Gravity indicator
                HStack(spacing: 8) {
                    ForEach(GravityDirection.allCases, id: \.self) { direction in
                        Button(action: {
                            if gameState == .playing && moves < config.maxMoves {
                                changeGravity(to: direction)
                            }
                        }) {
                            Image(systemName: direction.icon)
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(gravityDirection == direction ? Color.purple : Color.white.opacity(0.5))
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .fill(gravityDirection == direction ? Color.purple.opacity(0.3) : Color.white.opacity(0.1))
                                )
                        }
                        .disabled(gameState != .playing)
                    }
                }
                
                // Game area
                GeometryReader { gameGeometry in
                    ZStack {
                        // Background
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.3))
                        
                        // Grid lines
                        GridPattern()
                            .stroke(Color.purple.opacity(0.1), lineWidth: 1)
                        
                        // Portals
                        ForEach(portals) { portal in
                            PortalView(portal: portal)
                        }
                        
                        // Obstacles
                        ForEach(obstacles) { obstacle in
                            ObstacleView(obstacle: obstacle)
                        }
                        
                        // Collectibles
                        ForEach(collectibles) { collectible in
                            if !collectible.isCollected {
                                CollectibleView(collectible: collectible)
                            }
                        }
                        
                        // Target
                        TargetView(position: targetPosition)
                        
                        // Orb
                        GravityOrbView(position: orbPosition)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.purple.opacity(0.4), lineWidth: 1)
                    )
                    .gesture(
                        DragGesture(minimumDistance: 20)
                            .onEnded { value in
                                if gameState == .playing && moves < config.maxMoves {
                                    handleSwipe(value)
                                }
                            }
                    )
                    .onAppear {
                        gameAreaSize = gameGeometry.size
                    }
                    .onChange(of: gameGeometry.size) { newSize in
                        gameAreaSize = newSize
                    }
                }
                .frame(height: gameHeight)
                .padding(.horizontal, 16)
                
                // Start button
                if gameState == .ready || gameState == .failed {
                    VStack(spacing: 8) {
                        GlowingButton(title: gameState == .ready ? "Start" : "Retry") {
                            startGame()
                        }
                        .padding(.horizontal, 40)
                        
                        Text("Swipe or tap arrows to change gravity")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(Color.purple.opacity(0.7))
                    }
                    .padding(.bottom, 12)
                }
            }
        }
        .onReceive(timer) { _ in
            updatePhysics()
        }
        .onAppear {
            setupLevel()
        }
    }
    
    private func setupLevel() {
        gameState = .ready
        score = 0
        moves = 0
        collectedCount = 0
        gravityDirection = .down
    }
    
    private func startGame() {
        guard gameAreaSize.width > 0 && gameAreaSize.height > 0 else { return }
        
        let padding: CGFloat = 50
        
        // Set start position (top-left area)
        orbPosition = CGPoint(x: padding, y: padding)
        orbVelocity = .zero
        
        // Set target position (bottom-right area)
        targetPosition = CGPoint(x: gameAreaSize.width - padding, y: gameAreaSize.height - padding)
        
        // Generate obstacles
        obstacles = generateObstacles()
        
        // Generate collectibles
        collectibles = generateCollectibles()
        collectedCount = 0
        
        // Generate portals
        if config.hasPortals {
            portals = generatePortals()
        } else {
            portals = []
        }
        
        timeRemaining = config.timeLimit
        moves = 0
        gravityDirection = .down
        gameState = .playing
    }
    
    private func generateObstacles() -> [Obstacle] {
        var result: [Obstacle] = []
        let padding: CGFloat = 80
        
        for _ in 0..<config.obstacleCount {
            let width = CGFloat.random(in: 40...70)
            let height = CGFloat.random(in: 40...70)
            let x = CGFloat.random(in: padding...(gameAreaSize.width - width - padding))
            let y = CGFloat.random(in: padding...(gameAreaSize.height - height - padding))
            
            // Make sure obstacle doesn't overlap with start or target
            let frame = CGRect(x: x, y: y, width: width, height: height)
            let startArea = CGRect(x: 0, y: 0, width: 100, height: 100)
            let targetArea = CGRect(x: gameAreaSize.width - 100, y: gameAreaSize.height - 100, width: 100, height: 100)
            
            if !frame.intersects(startArea) && !frame.intersects(targetArea) {
                result.append(Obstacle(
                    id: UUID(),
                    frame: frame,
                    type: result.count % 3 == 0 ? .bounce : .solid
                ))
            }
        }
        
        return result
    }
    
    private func generateCollectibles() -> [Collectible] {
        var result: [Collectible] = []
        let padding: CGFloat = 60
        
        for _ in 0..<config.collectibleCount {
            let x = CGFloat.random(in: padding...(gameAreaSize.width - padding))
            let y = CGFloat.random(in: padding...(gameAreaSize.height - padding))
            
            result.append(Collectible(
                id: UUID(),
                position: CGPoint(x: x, y: y),
                isCollected: false
            ))
        }
        
        return result
    }
    
    private func generatePortals() -> [Portal] {
        let padding: CGFloat = 60
        let portal1Pos = CGPoint(
            x: CGFloat.random(in: padding...(gameAreaSize.width / 2 - 30)),
            y: CGFloat.random(in: padding...(gameAreaSize.height - padding))
        )
        let portal2Pos = CGPoint(
            x: CGFloat.random(in: (gameAreaSize.width / 2 + 30)...(gameAreaSize.width - padding)),
            y: CGFloat.random(in: padding...(gameAreaSize.height - padding))
        )
        
        let portalId = UUID()
        return [
            Portal(id: portalId, position: portal1Pos, linkedPortalId: portalId, isEntry: true),
            Portal(id: UUID(), position: portal2Pos, linkedPortalId: portalId, isEntry: false)
        ]
    }
    
    private func changeGravity(to direction: GravityDirection) {
        if gravityDirection != direction {
            gravityDirection = direction
            moves += 1
            HapticsManager.shared.gravityChanged()
            AudioManager.shared.playGravityChange()
        }
    }
    
    private func handleSwipe(_ value: DragGesture.Value) {
        let horizontal = value.translation.width
        let vertical = value.translation.height
        
        if abs(horizontal) > abs(vertical) {
            changeGravity(to: horizontal > 0 ? .right : .left)
        } else {
            changeGravity(to: vertical > 0 ? .down : .up)
        }
    }
    
    private func updatePhysics() {
        guard gameState == .playing else { return }
        guard gameAreaSize.width > 0 && gameAreaSize.height > 0 else { return }
        
        timeRemaining -= 0.016
        
        if timeRemaining <= 0 {
            gameState = .failed
            return
        }
        
        // Apply gravity
        let gravityForce = config.gravityStrength * 0.016
        switch gravityDirection {
        case .up: orbVelocity.y -= gravityForce
        case .down: orbVelocity.y += gravityForce
        case .left: orbVelocity.x -= gravityForce
        case .right: orbVelocity.x += gravityForce
        }
        
        // Apply friction
        orbVelocity.x *= 0.98
        orbVelocity.y *= 0.98
        
        // Update position
        orbPosition.x += orbVelocity.x * 0.016
        orbPosition.y += orbVelocity.y * 0.016
        
        // Boundary collision - use actual game area size
        let orbRadius: CGFloat = 15
        let maxX = gameAreaSize.width
        let maxY = gameAreaSize.height
        
        if orbPosition.x < orbRadius {
            orbPosition.x = orbRadius
            orbVelocity.x = -orbVelocity.x * 0.5
        }
        if orbPosition.x > maxX - orbRadius {
            orbPosition.x = maxX - orbRadius
            orbVelocity.x = -orbVelocity.x * 0.5
        }
        if orbPosition.y < orbRadius {
            orbPosition.y = orbRadius
            orbVelocity.y = -orbVelocity.y * 0.5
        }
        if orbPosition.y > maxY - orbRadius {
            orbPosition.y = maxY - orbRadius
            orbVelocity.y = -orbVelocity.y * 0.5
        }
        
        // Check obstacle collisions
        for obstacle in obstacles {
            if obstacle.frame.contains(orbPosition) {
                if obstacle.type == .bounce {
                    // Bounce off
                    orbVelocity.x = -orbVelocity.x * 1.2
                    orbVelocity.y = -orbVelocity.y * 1.2
                } else {
                    // Push out
                    let center = CGPoint(x: obstacle.frame.midX, y: obstacle.frame.midY)
                    let dx = orbPosition.x - center.x
                    let dy = orbPosition.y - center.y
                    let distance = sqrt(dx * dx + dy * dy)
                    if distance > 0 {
                        orbPosition.x += (dx / distance) * 5
                        orbPosition.y += (dy / distance) * 5
                    }
                    orbVelocity.x *= -0.3
                    orbVelocity.y *= -0.3
                }
            }
        }
        
        // Check collectible collisions
        for i in 0..<collectibles.count {
            if !collectibles[i].isCollected {
                let dx = orbPosition.x - collectibles[i].position.x
                let dy = orbPosition.y - collectibles[i].position.y
                let distance = sqrt(dx * dx + dy * dy)
                
                if distance < 25 {
                    collectibles[i].isCollected = true
                    collectedCount += 1
                    score += 50
                    HapticsManager.shared.collectiblePickup()
                    AudioManager.shared.playCollectible()
                }
            }
        }
        
        // Check portal collisions
        for portal in portals where portal.isEntry {
            let dx = orbPosition.x - portal.position.x
            let dy = orbPosition.y - portal.position.y
            let distance = sqrt(dx * dx + dy * dy)
            
            if distance < 20 {
                // Find exit portal
                if let exitPortal = portals.first(where: { !$0.isEntry }) {
                    orbPosition = exitPortal.position
                    score += 10
                    HapticsManager.shared.portalEntered()
                    AudioManager.shared.playPortal()
                }
            }
        }
        
        // Check target collision
        let targetDx = orbPosition.x - targetPosition.x
        let targetDy = orbPosition.y - targetPosition.y
        let targetDistance = sqrt(targetDx * targetDx + targetDy * targetDy)
        
        if targetDistance < 30 {
            completeLevel()
        }
    }
    
    private func completeLevel() {
        gameState = .success
        HapticsManager.shared.levelComplete()
        AudioManager.shared.playLevelComplete()
        
        // Time bonus
        score += Int(timeRemaining * 2)
        
        // Moves bonus
        if moves < config.maxMoves / 2 {
            score += 100
        }
        
        // All collectibles bonus
        if collectedCount == collectibles.count {
            score += 150
            HapticsManager.shared.comboAchieved()
        }
        
        let stars = calculateStars()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onComplete(score, stars)
        }
    }
    
    private func calculateStars() -> Int {
        let movesEfficiency = 1.0 - (Double(moves) / Double(config.maxMoves))
        let collectibleRatio = Double(collectedCount) / Double(max(1, collectibles.count))
        
        if movesEfficiency > 0.5 && collectibleRatio == 1.0 { return 3 }
        if collectibleRatio >= 0.5 { return 2 }
        return 1
    }
}

// MARK: - Supporting Types

enum GravityDirection: CaseIterable {
    case up, down, left, right
    
    var icon: String {
        switch self {
        case .up: return "arrow.up"
        case .down: return "arrow.down"
        case .left: return "arrow.left"
        case .right: return "arrow.right"
        }
    }
}

struct Obstacle: Identifiable {
    let id: UUID
    let frame: CGRect
    let type: ObstacleType
}

enum ObstacleType {
    case solid
    case bounce
}

struct Portal: Identifiable {
    let id: UUID
    let position: CGPoint
    let linkedPortalId: UUID
    let isEntry: Bool
}

struct Collectible: Identifiable {
    let id: UUID
    let position: CGPoint
    var isCollected: Bool
}

// MARK: - View Components

struct GridPattern: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let spacing: CGFloat = 30
        
        for x in stride(from: 0, to: rect.width, by: spacing) {
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: rect.height))
        }
        
        for y in stride(from: 0, to: rect.height, by: spacing) {
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: rect.width, y: y))
        }
        
        return path
    }
}

struct GravityOrbView: View {
    let position: CGPoint
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.purple, Color.purple.opacity(0.3), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 30
                    )
                )
                .frame(width: 60, height: 60)
            
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.purple, Color.pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 30, height: 30)
            
            Circle()
                .fill(Color.white.opacity(0.4))
                .frame(width: 10, height: 10)
                .offset(x: -5, y: -5)
        }
        .position(position)
    }
}

struct TargetView: View {
    let position: CGPoint
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color("HighlightTone").opacity(0.5), lineWidth: 3)
                .frame(width: 60, height: 60)
            
            Circle()
                .stroke(Color("HighlightTone").opacity(0.7), lineWidth: 2)
                .frame(width: 40, height: 40)
            
            Circle()
                .fill(Color("HighlightTone"))
                .frame(width: 20, height: 20)
        }
        .position(position)
    }
}

struct ObstacleView: View {
    let obstacle: Obstacle
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(obstacle.type == .bounce ? Color.orange.opacity(0.5) : Color.gray.opacity(0.5))
            .frame(width: obstacle.frame.width, height: obstacle.frame.height)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(obstacle.type == .bounce ? Color.orange : Color.gray, lineWidth: 2)
            )
            .position(x: obstacle.frame.midX, y: obstacle.frame.midY)
    }
}

struct PortalView: View {
    let portal: Portal
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            portal.isEntry ? Color.cyan : Color.green,
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 25
                    )
                )
                .frame(width: 50, height: 50)
            
            Circle()
                .stroke(portal.isEntry ? Color.cyan : Color.green, lineWidth: 2)
                .frame(width: 30, height: 30)
            
            Image(systemName: portal.isEntry ? "arrow.down.circle" : "arrow.up.circle")
                .font(.system(size: 16))
                .foregroundColor(portal.isEntry ? Color.cyan : Color.green)
        }
        .position(portal.position)
    }
}

struct CollectibleView: View {
    let collectible: Collectible
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.yellow.opacity(0.3))
                .frame(width: 30, height: 30)
            
            Image(systemName: "star.fill")
                .font(.system(size: 16))
                .foregroundColor(Color.yellow)
        }
        .position(collectible.position)
    }
}

#Preview {
    ZStack {
        Color("PrimaryBackground")
            .ignoresSafeArea()
        
        GravityFluxGame(level: 1, onComplete: { _, _ in })
    }
}
