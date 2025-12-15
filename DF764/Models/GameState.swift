//
//  GameState.swift
//  DF764
//

import SwiftUI
import Combine

// MARK: - Game Type Enum
enum GameType: String, CaseIterable, Codable {
    case pulsePathGrid = "Pulse Path Grid"
    case momentumShiftArena = "Momentum Shift Arena"
    case echoSequenceLabyrinth = "Echo Sequence Labyrinth"
    case gravityFlux = "Gravity Flux"
    case chronoCascade = "Chrono Cascade"
    
    var icon: String {
        switch self {
        case .pulsePathGrid: return "square.grid.3x3.fill"
        case .momentumShiftArena: return "arrow.left.arrow.right"
        case .echoSequenceLabyrinth: return "point.topleft.down.to.point.bottomright.curvepath.fill"
        case .gravityFlux: return "circle.dotted"
        case .chronoCascade: return "timer"
        }
    }
    
    var description: String {
        switch self {
        case .pulsePathGrid: return "Follow the glowing path sequence"
        case .momentumShiftArena: return "Redirect sliding objects with precision"
        case .echoSequenceLabyrinth: return "Trace the path through the digital maze"
        case .gravityFlux: return "Control gravity to guide the orb"
        case .chronoCascade: return "Chain taps in perfect timing"
        }
    }
    
    var themeColor: Color {
        switch self {
        case .pulsePathGrid: return Color("AccentGlow")
        case .momentumShiftArena: return Color("HighlightTone")
        case .echoSequenceLabyrinth: return Color.cyan
        case .gravityFlux: return Color.purple
        case .chronoCascade: return Color.mint
        }
    }
    
    var totalLevels: Int {
        return 12 // Each game has 12 levels
    }
    
    var unlockRequirement: Int {
        return 0 // All games unlocked from start
    }
}

// MARK: - Level Data
struct LevelData: Codable, Equatable, Identifiable {
    let id: Int
    var isCompleted: Bool = false
    var bestScore: Int = 0
    var stars: Int = 0 // 0-3 stars based on performance
    
    var isUnlocked: Bool {
        return id == 1 // First level always unlocked, others depend on previous
    }
}

// MARK: - Game Progress
struct GameProgressData: Codable, Equatable {
    var levels: [LevelData]
    var highestUnlockedLevel: Int = 1
    
    init(totalLevels: Int = 12) {
        self.levels = (1...totalLevels).map { LevelData(id: $0) }
    }
    
    var completedLevelsCount: Int {
        levels.filter { $0.isCompleted }.count
    }
    
    var totalStars: Int {
        levels.reduce(0) { $0 + $1.stars }
    }
    
    mutating func completeLevel(_ levelId: Int, score: Int, stars: Int) {
        if let index = levels.firstIndex(where: { $0.id == levelId }) {
            levels[index].isCompleted = true
            if score > levels[index].bestScore {
                levels[index].bestScore = score
            }
            if stars > levels[index].stars {
                levels[index].stars = stars
            }
            // Unlock next level
            if levelId < levels.count {
                highestUnlockedLevel = max(highestUnlockedLevel, levelId + 1)
            }
        }
    }
    
    func isLevelUnlocked(_ levelId: Int) -> Bool {
        return levelId <= highestUnlockedLevel
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
    
    @Published var gameProgress: [GameType: GameProgressData] = [:] {
        didSet {
            saveProgress()
        }
    }
    
    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        self.shards = UserDefaults.standard.integer(forKey: "shards")
        
        // Load progress for each game
        for gameType in GameType.allCases {
            let key = "progress_\(gameType.rawValue)"
            if let data = UserDefaults.standard.data(forKey: key),
               let progress = try? JSONDecoder().decode(GameProgressData.self, from: data) {
                self.gameProgress[gameType] = progress
            } else {
                self.gameProgress[gameType] = GameProgressData(totalLevels: gameType.totalLevels)
            }
        }
    }
    
    func progress(for gameType: GameType) -> GameProgressData {
        return gameProgress[gameType] ?? GameProgressData(totalLevels: gameType.totalLevels)
    }
    
    func completeLevel(gameType: GameType, level: Int, score: Int, stars: Int) {
        var progress = gameProgress[gameType] ?? GameProgressData(totalLevels: gameType.totalLevels)
        let wasCompleted = progress.levels.first(where: { $0.id == level })?.isCompleted ?? false
        
        progress.completeLevel(level, score: score, stars: stars)
        gameProgress[gameType] = progress
        
        // Award shards for first completion
        if !wasCompleted {
            shards += stars + 1 // 1-4 shards based on stars
        }
    }
    
    func isGameUnlocked(_ gameType: GameType) -> Bool {
        return totalCompletedLevels >= gameType.unlockRequirement
    }
    
    var totalCompletedLevels: Int {
        gameProgress.values.reduce(0) { $0 + $1.completedLevelsCount }
    }
    
    var totalStars: Int {
        gameProgress.values.reduce(0) { $0 + $1.totalStars }
    }
    
    func resetProgress() {
        shards = 0
        for gameType in GameType.allCases {
            gameProgress[gameType] = GameProgressData(totalLevels: gameType.totalLevels)
        }
        saveProgress()
    }
    
    private func saveProgress() {
        for (gameType, progress) in gameProgress {
            let key = "progress_\(gameType.rawValue)"
            if let data = try? JSONEncoder().encode(progress) {
                UserDefaults.standard.set(data, forKey: key)
            }
        }
    }
}
