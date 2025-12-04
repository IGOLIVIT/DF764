//
//  GameState.swift
//  DF764
//

import SwiftUI
import Combine

// MARK: - Difficulty Enum
enum Difficulty: String, CaseIterable, Codable {
    case easy = "Easy"
    case normal = "Normal"
    case hard = "Hard"
    
    var shardReward: Int {
        switch self {
        case .easy: return 1
        case .normal: return 2
        case .hard: return 3
        }
    }
    
    var color: Color {
        switch self {
        case .easy: return Color("HighlightTone")
        case .normal: return Color("AccentGlow")
        case .hard: return Color.red.opacity(0.8)
        }
    }
}

// MARK: - Game Type Enum
enum GameType: String, CaseIterable, Codable {
    case pulsePathGrid = "Pulse Path Grid"
    case momentumShiftArena = "Momentum Shift Arena"
    case echoSequenceLabyrinth = "Echo Sequence Labyrinth"
    
    var icon: String {
        switch self {
        case .pulsePathGrid: return "square.grid.3x3.fill"
        case .momentumShiftArena: return "arrow.left.arrow.right"
        case .echoSequenceLabyrinth: return "point.topleft.down.to.point.bottomright.curvepath.fill"
        }
    }
    
    var description: String {
        switch self {
        case .pulsePathGrid: return "Follow the glowing path sequence"
        case .momentumShiftArena: return "Redirect sliding objects with precision"
        case .echoSequenceLabyrinth: return "Trace the path through the digital maze"
        }
    }
}

// MARK: - Level Progress
struct LevelProgress: Codable, Equatable {
    var level1Completed: Bool = false
    var level2Completed: Bool = false
    var level3Completed: Bool = false
    
    var completedCount: Int {
        [level1Completed, level2Completed, level3Completed].filter { $0 }.count
    }
}

// MARK: - Game Progress
struct GameProgress: Codable, Equatable {
    var easy: LevelProgress = LevelProgress()
    var normal: LevelProgress = LevelProgress()
    var hard: LevelProgress = LevelProgress()
    
    func progress(for difficulty: Difficulty) -> LevelProgress {
        switch difficulty {
        case .easy: return easy
        case .normal: return normal
        case .hard: return hard
        }
    }
    
    mutating func setProgress(for difficulty: Difficulty, progress: LevelProgress) {
        switch difficulty {
        case .easy: easy = progress
        case .normal: normal = progress
        case .hard: hard = progress
        }
    }
    
    var totalLevelsCompleted: Int {
        easy.completedCount + normal.completedCount + hard.completedCount
    }
}

// MARK: - App State
class AppState: ObservableObject {
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        }
    }
    
    @Published var shards: Int {
        didSet {
            UserDefaults.standard.set(shards, forKey: "shards")
        }
    }
    
    @Published var pulsePathGridProgress: GameProgress {
        didSet {
            saveProgress()
        }
    }
    
    @Published var momentumShiftArenaProgress: GameProgress {
        didSet {
            saveProgress()
        }
    }
    
    @Published var echoSequenceLabyrinthProgress: GameProgress {
        didSet {
            saveProgress()
        }
    }
    
    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        self.shards = UserDefaults.standard.integer(forKey: "shards")
        
        if let data = UserDefaults.standard.data(forKey: "pulsePathGridProgress"),
           let progress = try? JSONDecoder().decode(GameProgress.self, from: data) {
            self.pulsePathGridProgress = progress
        } else {
            self.pulsePathGridProgress = GameProgress()
        }
        
        if let data = UserDefaults.standard.data(forKey: "momentumShiftArenaProgress"),
           let progress = try? JSONDecoder().decode(GameProgress.self, from: data) {
            self.momentumShiftArenaProgress = progress
        } else {
            self.momentumShiftArenaProgress = GameProgress()
        }
        
        if let data = UserDefaults.standard.data(forKey: "echoSequenceLabyrinthProgress"),
           let progress = try? JSONDecoder().decode(GameProgress.self, from: data) {
            self.echoSequenceLabyrinthProgress = progress
        } else {
            self.echoSequenceLabyrinthProgress = GameProgress()
        }
    }
    
    func progress(for gameType: GameType) -> GameProgress {
        switch gameType {
        case .pulsePathGrid: return pulsePathGridProgress
        case .momentumShiftArena: return momentumShiftArenaProgress
        case .echoSequenceLabyrinth: return echoSequenceLabyrinthProgress
        }
    }
    
    func setProgress(for gameType: GameType, progress: GameProgress) {
        switch gameType {
        case .pulsePathGrid: pulsePathGridProgress = progress
        case .momentumShiftArena: momentumShiftArenaProgress = progress
        case .echoSequenceLabyrinth: echoSequenceLabyrinthProgress = progress
        }
    }
    
    func completeLevel(gameType: GameType, difficulty: Difficulty, level: Int) {
        var gameProgress = progress(for: gameType)
        var levelProgress = gameProgress.progress(for: difficulty)
        
        var alreadyCompleted = false
        switch level {
        case 1:
            alreadyCompleted = levelProgress.level1Completed
            levelProgress.level1Completed = true
        case 2:
            alreadyCompleted = levelProgress.level2Completed
            levelProgress.level2Completed = true
        case 3:
            alreadyCompleted = levelProgress.level3Completed
            levelProgress.level3Completed = true
        default: break
        }
        
        gameProgress.setProgress(for: difficulty, progress: levelProgress)
        setProgress(for: gameType, progress: gameProgress)
        
        if !alreadyCompleted {
            shards += difficulty.shardReward
        }
    }
    
    func resetProgress() {
        shards = 0
        pulsePathGridProgress = GameProgress()
        momentumShiftArenaProgress = GameProgress()
        echoSequenceLabyrinthProgress = GameProgress()
        saveProgress()
    }
    
    private func saveProgress() {
        if let data = try? JSONEncoder().encode(pulsePathGridProgress) {
            UserDefaults.standard.set(data, forKey: "pulsePathGridProgress")
        }
        if let data = try? JSONEncoder().encode(momentumShiftArenaProgress) {
            UserDefaults.standard.set(data, forKey: "momentumShiftArenaProgress")
        }
        if let data = try? JSONEncoder().encode(echoSequenceLabyrinthProgress) {
            UserDefaults.standard.set(data, forKey: "echoSequenceLabyrinthProgress")
        }
    }
    
    var totalLevelsCompleted: Int {
        pulsePathGridProgress.totalLevelsCompleted +
        momentumShiftArenaProgress.totalLevelsCompleted +
        echoSequenceLabyrinthProgress.totalLevelsCompleted
    }
}

