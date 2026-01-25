//
//  MomentumShiftArenaGame.swift
//  DF764
//

import SwiftUI
import Combine

struct MomentumShiftArenaGame: View {
    let level: Int
    let onComplete: (Int, Int) -> Void
    
    @State private var gameState: GamePlayState = .ready
    @State private var score: Int = 0
    @State private var targetScore: Int = 0
    @State private var timeRemaining: Double = 30
    @State private var objects: [GameOrb] = []
    @State private var powerUps: [PowerUp] = []
    @State private var activePowerUp: PowerUpType? = nil
    @State private var combo: Int = 0
    @State private var lastCatchTime: Date = Date()
    @State private var multiplier: Double = 1.0
    
    private let laneCount = 3
    private let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    
    private var config: LevelConfig {
        LevelConfig.forLevel(level)
    }
    
    struct LevelConfig {
        let baseSpeed: Double
        let spawnInterval: Double
        let targetScore: Int
        let timeLimit: Double
        let hasPowerUps: Bool
        let hasSpecialOrbs: Bool
        let laneCount: Int
        
        static func forLevel(_ level: Int) -> LevelConfig {
            switch level {
            case 1: return LevelConfig(baseSpeed: 60, spawnInterval: 1.8, targetScore: 5, timeLimit: 30, hasPowerUps: false, hasSpecialOrbs: false, laneCount: 3)
            case 2: return LevelConfig(baseSpeed: 70, spawnInterval: 1.6, targetScore: 7, timeLimit: 30, hasPowerUps: false, hasSpecialOrbs: false, laneCount: 3)
            case 3: return LevelConfig(baseSpeed: 80, spawnInterval: 1.5, targetScore: 8, timeLimit: 30, hasPowerUps: true, hasSpecialOrbs: false, laneCount: 3)
            case 4: return LevelConfig(baseSpeed: 85, spawnInterval: 1.4, targetScore: 10, timeLimit: 35, hasPowerUps: true, hasSpecialOrbs: true, laneCount: 3)
            case 5: return LevelConfig(baseSpeed: 95, spawnInterval: 1.3, targetScore: 12, timeLimit: 35, hasPowerUps: true, hasSpecialOrbs: true, laneCount: 4)
            case 6: return LevelConfig(baseSpeed: 100, spawnInterval: 1.2, targetScore: 14, timeLimit: 35, hasPowerUps: true, hasSpecialOrbs: true, laneCount: 4)
            case 7: return LevelConfig(baseSpeed: 110, spawnInterval: 1.1, targetScore: 16, timeLimit: 40, hasPowerUps: true, hasSpecialOrbs: true, laneCount: 4)
            case 8: return LevelConfig(baseSpeed: 120, spawnInterval: 1.0, targetScore: 18, timeLimit: 40, hasPowerUps: true, hasSpecialOrbs: true, laneCount: 4)
            case 9: return LevelConfig(baseSpeed: 130, spawnInterval: 0.9, targetScore: 20, timeLimit: 40, hasPowerUps: true, hasSpecialOrbs: true, laneCount: 5)
            case 10: return LevelConfig(baseSpeed: 140, spawnInterval: 0.85, targetScore: 22, timeLimit: 45, hasPowerUps: true, hasSpecialOrbs: true, laneCount: 5)
            case 11: return LevelConfig(baseSpeed: 150, spawnInterval: 0.8, targetScore: 25, timeLimit: 45, hasPowerUps: true, hasSpecialOrbs: true, laneCount: 5)
            case 12: return LevelConfig(baseSpeed: 160, spawnInterval: 0.75, targetScore: 30, timeLimit: 50, hasPowerUps: true, hasSpecialOrbs: true, laneCount: 5)
            default: return LevelConfig(baseSpeed: 60, spawnInterval: 1.8, targetScore: 5, timeLimit: 30, hasPowerUps: false, hasSpecialOrbs: false, laneCount: 3)
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 12) {
                // Score and timer bar
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Score")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(Color("HighlightTone").opacity(0.7))
                        HStack(spacing: 4) {
                            Text("\(score)")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text("/\(targetScore)")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(Color("HighlightTone").opacity(0.6))
                        }
                    }
                    
                    Spacer()
                    
                    // Combo indicator
                    if combo > 1 {
                        HStack(spacing: 4) {
                            Text("x\(combo)")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(Color("AccentGlow"))
                            Text("COMBO")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundColor(Color("AccentGlow").opacity(0.7))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color("AccentGlow").opacity(0.2))
                        )
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Time")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(Color("HighlightTone").opacity(0.7))
                        Text(String(format: "%.1f", max(0, timeRemaining)))
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(timeRemaining < 10 ? Color("AccentGlow") : .white)
                    }
                }
                .padding(.horizontal, 20)
                
                // Progress bar
                GeometryReader { barGeometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 6)
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color("AccentGlow"), Color("HighlightTone")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: barGeometry.size.width * min(1, CGFloat(score) / CGFloat(targetScore)), height: 6)
                    }
                }
                .frame(height: 6)
                .padding(.horizontal, 20)
                
                // Active power-up indicator
                if let powerUp = activePowerUp {
                    HStack(spacing: 6) {
                        Image(systemName: powerUp.icon)
                            .font(.system(size: 14))
                            .foregroundColor(powerUp.color)
                        Text(powerUp.rawValue)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(powerUp.color)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(powerUp.color.opacity(0.2))
                    )
                }
                
                // Game arena
                ZStack {
                    // Lane backgrounds
                    VStack(spacing: 0) {
                        ForEach(0..<config.laneCount, id: \.self) { laneIndex in
                            Rectangle()
                                .fill(laneIndex % 2 == 0 ? Color.white.opacity(0.03) : Color.white.opacity(0.05))
                                .frame(height: (geometry.size.height - 180) / CGFloat(config.laneCount))
                        }
                    }
                    
                    // Target zone
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color("AccentGlow").opacity(0.3),
                                    Color("AccentGlow").opacity(0.1),
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 80)
                        .position(x: 50, y: (geometry.size.height - 180) / 2)
                    
                    // Perfect zone marker
                    Rectangle()
                        .fill(Color("AccentGlow").opacity(0.5))
                        .frame(width: 4)
                        .position(x: 50, y: (geometry.size.height - 180) / 2)
                    
                    // Game objects
                    ForEach(objects) { orb in
                        OrbView(orb: orb, laneHeight: (geometry.size.height - 180) / CGFloat(config.laneCount))
                            .onTapGesture {
                                handleOrbTap(orb, geometry: geometry)
                            }
                    }
                    
                    // Power-ups
                    ForEach(powerUps) { powerUp in
                        PowerUpView(powerUp: powerUp, laneHeight: (geometry.size.height - 180) / CGFloat(config.laneCount))
                            .onTapGesture {
                                collectPowerUp(powerUp)
                            }
                    }
                }
                .frame(height: geometry.size.height - 180)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color("AccentGlow").opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal, 12)
                
                // Start button
                if gameState == .ready || gameState == .failed {
                    GlowingButton(title: gameState == .ready ? "Start" : "Try Again") {
                        startGame(geometry: geometry)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 16)
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
    
    private func setupLevel() {
        targetScore = config.targetScore
        timeRemaining = config.timeLimit
        score = 0
        combo = 0
        multiplier = 1.0
        objects = []
        powerUps = []
        activePowerUp = nil
        gameState = .ready
    }
    
    private func startGame(geometry: GeometryProxy) {
        gameState = .playing
        score = 0
        combo = 0
        timeRemaining = config.timeLimit
        objects = []
        powerUps = []
        activePowerUp = nil
        spawnOrb(geometry: geometry)
        
        if config.hasPowerUps {
            schedulePowerUpSpawn(geometry: geometry)
        }
    }
    
    @State private var lastSpawnTime: Date = Date()
    @State private var lastPowerUpSpawn: Date = Date()
    
    private func updateGame() {
        guard gameState == .playing else { return }
        
        timeRemaining -= 0.016
        
        // Reset combo if too long between catches
        if Date().timeIntervalSince(lastCatchTime) > 2.0 && combo > 0 {
            combo = 0
            multiplier = 1.0
        }
        
        if timeRemaining <= 0 {
            endGame()
            return
        }
        
        // Move objects
        let speed = activePowerUp == .slowMotion ? config.baseSpeed * 0.5 : config.baseSpeed
        objects = objects.map { orb in
            var updated = orb
            updated.x -= speed * 0.016
            return updated
        }
        
        // Move power-ups
        powerUps = powerUps.map { pu in
            var updated = pu
            updated.x -= config.baseSpeed * 0.8 * 0.016
            return updated
        }
        
        // Remove off-screen objects
        objects = objects.filter { $0.x > -40 }
        powerUps = powerUps.filter { $0.x > -30 }
    }
    
    private func spawnOrb(geometry: GeometryProxy) {
        guard gameState == .playing else { return }
        
        let laneHeight = (geometry.size.height - 180) / CGFloat(config.laneCount)
        let lane = Int.random(in: 0..<config.laneCount)
        
        var orbType: OrbType = .normal
        if config.hasSpecialOrbs && Double.random(in: 0...1) < 0.2 {
            orbType = Bool.random() ? .golden : .danger
        }
        
        let newOrb = GameOrb(
            id: UUID(),
            lane: lane,
            x: geometry.size.width - 30,
            y: laneHeight * CGFloat(lane) + laneHeight / 2,
            type: orbType
        )
        objects.append(newOrb)
        lastSpawnTime = Date()
        
        let interval = activePowerUp == .rapidFire ? config.spawnInterval * 0.6 : config.spawnInterval
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            spawnOrb(geometry: geometry)
        }
    }
    
    private func schedulePowerUpSpawn(geometry: GeometryProxy) {
        guard gameState == .playing else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 5...10)) {
            guard gameState == .playing else { return }
            spawnPowerUp(geometry: geometry)
            schedulePowerUpSpawn(geometry: geometry)
        }
    }
    
    private func spawnPowerUp(geometry: GeometryProxy) {
        let laneHeight = (geometry.size.height - 180) / CGFloat(config.laneCount)
        let lane = Int.random(in: 0..<config.laneCount)
        let types: [PowerUpType] = [.slowMotion, .doublePoints, .rapidFire]
        
        let newPowerUp = PowerUp(
            id: UUID(),
            lane: lane,
            x: geometry.size.width - 20,
            y: laneHeight * CGFloat(lane) + laneHeight / 2,
            type: types.randomElement()!
        )
        powerUps.append(newPowerUp)
    }
    
    private func handleOrbTap(_ orb: GameOrb, geometry: GeometryProxy) {
        guard gameState == .playing else { return }
        
        // Check if orb is in target zone
        if orb.x < 90 && orb.x > 10 {
            objects.removeAll { $0.id == orb.id }
            
            switch orb.type {
            case .normal:
                let points = activePowerUp == .doublePoints ? 2 : 1
                score += Int(Double(points) * multiplier)
                combo += 1
                multiplier = 1.0 + Double(min(combo, 10)) * 0.1
                lastCatchTime = Date()
                HapticsManager.shared.orbCaught()
                AudioManager.shared.playCorrect()
                
                // Combo haptic feedback
                if combo > 0 && combo % 5 == 0 {
                    HapticsManager.shared.comboAchieved()
                    AudioManager.shared.playCombo()
                }
                
            case .golden:
                let points = activePowerUp == .doublePoints ? 6 : 3
                score += Int(Double(points) * multiplier)
                combo += 2
                multiplier = 1.0 + Double(min(combo, 10)) * 0.1
                lastCatchTime = Date()
                HapticsManager.shared.heavyImpact()
                AudioManager.shared.playCollectible()
                
            case .danger:
                score = max(0, score - 2)
                combo = 0
                multiplier = 1.0
                HapticsManager.shared.error()
                AudioManager.shared.playError()
            }
            
            checkWin()
        }
    }
    
    private func collectPowerUp(_ powerUp: PowerUp) {
        powerUps.removeAll { $0.id == powerUp.id }
        activePowerUp = powerUp.type
        HapticsManager.shared.collectiblePickup()
        AudioManager.shared.playCollectible()
        
        // Power-up duration
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            if activePowerUp == powerUp.type {
                activePowerUp = nil
            }
        }
    }
    
    private func checkWin() {
        if score >= targetScore {
            gameState = .success
            HapticsManager.shared.levelComplete()
            AudioManager.shared.playLevelComplete()
            let stars = calculateStars()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                onComplete(score, stars)
            }
        }
    }
    
    private func endGame() {
        if score >= targetScore {
            gameState = .success
            HapticsManager.shared.levelComplete()
            AudioManager.shared.playLevelComplete()
            let stars = calculateStars()
            onComplete(score, stars)
        } else {
            gameState = .failed
            HapticsManager.shared.error()
        }
    }
    
    private func calculateStars() -> Int {
        let percentage = Double(score) / Double(targetScore)
        if percentage >= 1.5 { return 3 }
        if percentage >= 1.2 { return 2 }
        return 1
    }
}

// MARK: - Game Objects

struct GameOrb: Identifiable {
    let id: UUID
    let lane: Int
    var x: Double
    var y: Double
    let type: OrbType
}

enum OrbType {
    case normal
    case golden
    case danger
    
    var color: Color {
        switch self {
        case .normal: return Color("AccentGlow")
        case .golden: return Color("HighlightTone")
        case .danger: return Color.red
        }
    }
}

struct OrbView: View {
    let orb: GameOrb
    let laneHeight: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            orb.type.color.opacity(0.6),
                            orb.type.color.opacity(0.2),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 25
                    )
                )
                .frame(width: 50, height: 50)
            
            Circle()
                .fill(
                    LinearGradient(
                        colors: [orb.type.color, orb.type.color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 30, height: 30)
            
            if orb.type == .golden {
                Image(systemName: "star.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.white)
            } else if orb.type == .danger {
                Image(systemName: "exclamationmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Circle()
                .stroke(orb.type.color.opacity(0.8), lineWidth: 2)
                .frame(width: 30, height: 30)
        }
        .position(x: orb.x, y: orb.y)
    }
}

struct PowerUp: Identifiable {
    let id: UUID
    let lane: Int
    var x: Double
    var y: Double
    let type: PowerUpType
}

enum PowerUpType: String {
    case slowMotion = "Slow Mo"
    case doublePoints = "2x Points"
    case rapidFire = "Rapid"
    
    var icon: String {
        switch self {
        case .slowMotion: return "tortoise.fill"
        case .doublePoints: return "star.fill"
        case .rapidFire: return "bolt.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .slowMotion: return Color.cyan
        case .doublePoints: return Color("HighlightTone")
        case .rapidFire: return Color.orange
        }
    }
}

struct PowerUpView: View {
    let powerUp: PowerUp
    let laneHeight: CGFloat
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(powerUp.type.color.opacity(0.3))
                .frame(width: 36, height: 36)
            
            Image(systemName: powerUp.type.icon)
                .font(.system(size: 16))
                .foregroundColor(powerUp.type.color)
            
            RoundedRectangle(cornerRadius: 8)
                .stroke(powerUp.type.color, lineWidth: 2)
                .frame(width: 36, height: 36)
        }
        .position(x: powerUp.x, y: powerUp.y)
    }
}

#Preview {
    ZStack {
        Color("PrimaryBackground")
            .ignoresSafeArea()
        
        MomentumShiftArenaGame(level: 5, onComplete: { _, _ in })
    }
}
