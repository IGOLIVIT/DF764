//
//  MomentumShiftArenaGame.swift
//  DF764
//

import SwiftUI
import Combine

struct MomentumShiftArenaGame: View {
    let difficulty: Difficulty
    let currentLevel: Int
    let onLevelComplete: () -> Void
    
    @State private var gameState: GamePlayState = .ready
    @State private var score = 0
    @State private var targetScore: Int = 0
    @State private var timeRemaining: Double = 30
    @State private var objects: [SlidingObject] = []
    @State private var showInstructions = true
    
    private let laneCount = 3
    private let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    
    private var objectSpeed: Double {
        let baseSpeed: Double
        switch currentLevel {
        case 1: baseSpeed = 80
        case 2: baseSpeed = 120
        case 3: baseSpeed = 160
        default: baseSpeed = 80
        }
        
        switch difficulty {
        case .easy: return baseSpeed * 0.8
        case .normal: return baseSpeed
        case .hard: return baseSpeed * 1.3
        }
    }
    
    private var spawnInterval: Double {
        switch difficulty {
        case .easy: return 1.5
        case .normal: return 1.2
        case .hard: return 0.9
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 16) {
                // Score and timer
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Score")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(Color("HighlightTone").opacity(0.7))
                        Text("\(score)/\(targetScore)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Time")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(Color("HighlightTone").opacity(0.7))
                        Text(String(format: "%.1f", max(0, timeRemaining)))
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(timeRemaining < 10 ? Color("AccentGlow") : .white)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                
                // Progress bar
                GeometryReader { barGeometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 8)
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color("AccentGlow"), Color("HighlightTone")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: barGeometry.size.width * CGFloat(score) / CGFloat(targetScore), height: 8)
                            .animation(.spring(response: 0.3), value: score)
                    }
                }
                .frame(height: 8)
                .padding(.horizontal, 24)
                
                // Game arena
                ZStack {
                    // Lanes background
                    VStack(spacing: 0) {
                        ForEach(0..<laneCount, id: \.self) { laneIndex in
                            ZStack {
                                Rectangle()
                                    .fill(laneIndex % 2 == 0 ? Color.white.opacity(0.03) : Color.white.opacity(0.06))
                                
                                // Lane dividers
                                if laneIndex < laneCount - 1 {
                                    VStack {
                                        Spacer()
                                        Rectangle()
                                            .fill(Color("AccentGlow").opacity(0.2))
                                            .frame(height: 1)
                                    }
                                }
                            }
                            .frame(height: (geometry.size.height - 200) / CGFloat(laneCount))
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
                        .position(x: 60, y: (geometry.size.height - 200) / 2)
                    
                    // Sliding objects
                    ForEach(objects) { object in
                        SlidingObjectView(object: object, laneHeight: (geometry.size.height - 200) / CGFloat(laneCount))
                            .onTapGesture {
                                handleObjectTap(object, geometry: geometry)
                            }
                    }
                }
                .frame(height: geometry.size.height - 200)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color("AccentGlow").opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal, 16)
                
                // Action button or instructions
                if gameState == .ready || gameState == .failed {
                    VStack(spacing: 12) {
                        GlowingButton(title: gameState == .ready ? "Start" : "Try Again") {
                            startGame(geometry: geometry)
                        }
                        .padding(.horizontal, 40)
                        
                        if showInstructions && gameState == .ready {
                            Text("Tap objects in the target zone to redirect them")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(Color("HighlightTone").opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                    }
                    .padding(.bottom, 20)
                }
                
                if gameState == .success {
                    Text("Target reached!")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(Color("AccentGlow"))
                        .padding(.bottom, 20)
                }
            }
        }
        .onReceive(timer) { _ in
            updateGame()
        }
        .onAppear {
            setupGame()
        }
    }
    
    private func setupGame() {
        targetScore = 5 + currentLevel * 2
        timeRemaining = 30
        score = 0
        objects = []
        gameState = .ready
    }
    
    private func startGame(geometry: GeometryProxy) {
        showInstructions = false
        gameState = .playing
        score = 0
        timeRemaining = 30
        objects = []
        spawnObject(geometry: geometry)
    }
    
    @State private var lastSpawnTime: Date = Date()
    
    private func updateGame() {
        guard gameState == .playing else { return }
        
        // Update timer
        timeRemaining -= 0.016
        
        if timeRemaining <= 0 {
            if score >= targetScore {
                gameState = .success
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    onLevelComplete()
                }
            } else {
                gameState = .failed
            }
            return
        }
        
        // Move objects
        objects = objects.map { object in
            var updated = object
            updated.x -= objectSpeed * 0.016
            return updated
        }
        
        // Remove objects that went off screen
        objects = objects.filter { $0.x > -50 }
        
        // Spawn new objects
        if Date().timeIntervalSince(lastSpawnTime) > spawnInterval {
            // We need geometry here, so we'll handle this differently
        }
    }
    
    private func spawnObject(geometry: GeometryProxy) {
        guard gameState == .playing else { return }
        
        let laneHeight = (geometry.size.height - 200) / CGFloat(laneCount)
        let lane = Int.random(in: 0..<laneCount)
        let newObject = SlidingObject(
            id: UUID(),
            lane: lane,
            x: geometry.size.width - 40,
            y: laneHeight * CGFloat(lane) + laneHeight / 2
        )
        objects.append(newObject)
        lastSpawnTime = Date()
        
        // Schedule next spawn
        DispatchQueue.main.asyncAfter(deadline: .now() + spawnInterval) {
            spawnObject(geometry: geometry)
        }
    }
    
    private func handleObjectTap(_ object: SlidingObject, geometry: GeometryProxy) {
        guard gameState == .playing else { return }
        
        // Check if object is in target zone (left side)
        if object.x < 120 && object.x > 20 {
            // Success - object redirected
            withAnimation(.spring(response: 0.2)) {
                objects.removeAll { $0.id == object.id }
                score += 1
            }
            
            // Check win condition
            if score >= targetScore {
                gameState = .success
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    onLevelComplete()
                }
            }
        }
    }
}

struct SlidingObject: Identifiable {
    let id: UUID
    let lane: Int
    var x: Double
    var y: Double
}

struct SlidingObjectView: View {
    let object: SlidingObject
    let laneHeight: CGFloat
    
    @State private var glowPulse = false
    
    var body: some View {
        ZStack {
            // Glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color("AccentGlow").opacity(0.6),
                            Color("AccentGlow").opacity(0.2),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 30
                    )
                )
                .frame(width: 60, height: 60)
                .scaleEffect(glowPulse ? 1.2 : 1.0)
            
            // Core
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color("AccentGlow"), Color("HighlightTone")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 36, height: 36)
            
            Circle()
                .stroke(Color.white.opacity(0.5), lineWidth: 2)
                .frame(width: 36, height: 36)
        }
        .position(x: object.x, y: object.y)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }
    }
}

#Preview {
    ZStack {
        Color("PrimaryBackground")
            .ignoresSafeArea()
        
        MomentumShiftArenaGame(
            difficulty: .easy,
            currentLevel: 1,
            onLevelComplete: {}
        )
    }
}

