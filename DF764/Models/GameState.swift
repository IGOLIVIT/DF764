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
    
    var tutorialSteps: [String] {
        switch self {
        case .pulsePathGrid:
            return [
                "Watch the tiles light up in sequence",
                "Memorize the pattern carefully",
                "Tap the tiles in the same order",
                "Collect bonus stars for extra points",
                "Avoid obstacle tiles marked with X"
            ]
        case .momentumShiftArena:
            return [
                "Orbs slide towards you from the right",
                "Tap orbs when they reach the target zone",
                "Golden orbs give bonus points",
                "Avoid red danger orbs",
                "Build combos for multiplier bonuses"
            ]
        case .echoSequenceLabyrinth:
            return [
                "Drag from start to find the exit",
                "Navigate through the maze paths",
                "Collect diamonds for bonus points",
                "Fog limits your visibility",
                "Reach the flag before time runs out"
            ]
        case .gravityFlux:
            return [
                "Control gravity to move the orb",
                "Swipe or tap arrows to change direction",
                "Collect stars along the way",
                "Use portals to teleport",
                "Reach the target in minimal moves"
            ]
        case .chronoCascade:
            return [
                "Watch the progress ring rotate",
                "Tap when it reaches each node",
                "Perfect timing gives bonus points",
                "Build chains for score multipliers",
                "Don't miss too many nodes"
            ]
        }
    }
}

// MARK: - Achievement System
enum AchievementType: String, CaseIterable, Codable {
    case firstWin = "first_win"
    case collector = "collector"
    case perfectionist = "perfectionist"
    case speedRunner = "speed_runner"
    case dedicated = "dedicated"
    case master = "master"
    case starHunter = "star_hunter"
    case shardMaster = "shard_master"
    case dailyPlayer = "daily_player"
    case weeklyWarrior = "weekly_warrior"
    case comboKing = "combo_king"
    case explorer = "explorer"
    case completionist = "completionist"
    case legendary = "legendary"
    case champion = "champion"
    
    var title: String {
        switch self {
        case .firstWin: return "First Victory"
        case .collector: return "Collector"
        case .perfectionist: return "Perfectionist"
        case .speedRunner: return "Speed Runner"
        case .dedicated: return "Dedicated Player"
        case .master: return "Game Master"
        case .starHunter: return "Star Hunter"
        case .shardMaster: return "Shard Master"
        case .dailyPlayer: return "Daily Player"
        case .weeklyWarrior: return "Weekly Warrior"
        case .comboKing: return "Combo King"
        case .explorer: return "Explorer"
        case .completionist: return "Completionist"
        case .legendary: return "Legendary"
        case .champion: return "Champion"
        }
    }
    
    var description: String {
        switch self {
        case .firstWin: return "Complete your first level"
        case .collector: return "Collect 100 shards"
        case .perfectionist: return "Get 3 stars on 10 levels"
        case .speedRunner: return "Complete 5 levels with max time bonus"
        case .dedicated: return "Play for 7 consecutive days"
        case .master: return "Master all games (complete all levels)"
        case .starHunter: return "Collect 50 stars total"
        case .shardMaster: return "Collect 500 shards"
        case .dailyPlayer: return "Complete 3 daily challenges"
        case .weeklyWarrior: return "Complete 7 daily challenges"
        case .comboKing: return "Achieve a 10x combo"
        case .explorer: return "Try all 5 mini-games"
        case .completionist: return "Complete all 60 levels"
        case .legendary: return "Get 3 stars on all levels"
        case .champion: return "Earn all achievements"
        }
    }
    
    var icon: String {
        switch self {
        case .firstWin: return "trophy.fill"
        case .collector: return "diamond.fill"
        case .perfectionist: return "star.circle.fill"
        case .speedRunner: return "bolt.fill"
        case .dedicated: return "calendar.badge.clock"
        case .master: return "crown.fill"
        case .starHunter: return "star.fill"
        case .shardMaster: return "diamond.circle.fill"
        case .dailyPlayer: return "sun.max.fill"
        case .weeklyWarrior: return "flame.fill"
        case .comboKing: return "sparkles"
        case .explorer: return "map.fill"
        case .completionist: return "checkmark.seal.fill"
        case .legendary: return "star.square.fill"
        case .champion: return "medal.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .firstWin: return Color("AccentGlow")
        case .collector: return Color("HighlightTone")
        case .perfectionist: return Color.yellow
        case .speedRunner: return Color.orange
        case .dedicated: return Color.blue
        case .master: return Color.purple
        case .starHunter: return Color.yellow
        case .shardMaster: return Color.cyan
        case .dailyPlayer: return Color.mint
        case .weeklyWarrior: return Color.red
        case .comboKing: return Color.pink
        case .explorer: return Color.green
        case .completionist: return Color.indigo
        case .legendary: return Color.purple
        case .champion: return Color("HighlightTone")
        }
    }
    
    var shardReward: Int {
        switch self {
        case .firstWin: return 10
        case .collector: return 25
        case .perfectionist: return 50
        case .speedRunner: return 30
        case .dedicated: return 75
        case .master: return 200
        case .starHunter: return 40
        case .shardMaster: return 100
        case .dailyPlayer: return 35
        case .weeklyWarrior: return 100
        case .comboKing: return 45
        case .explorer: return 25
        case .completionist: return 150
        case .legendary: return 300
        case .champion: return 500
        }
    }
}

struct Achievement: Codable, Equatable, Identifiable {
    var id: String { type.rawValue }
    let type: AchievementType
    var isUnlocked: Bool = false
    var unlockedDate: Date?
    var progress: Int = 0
    var requiredProgress: Int
    
    var progressPercentage: Double {
        guard requiredProgress > 0 else { return isUnlocked ? 1.0 : 0.0 }
        return min(1.0, Double(progress) / Double(requiredProgress))
    }
}

// MARK: - Daily Challenge System
struct DailyChallenge: Codable, Equatable, Identifiable {
    let id: String
    let gameType: GameType
    let targetLevel: Int
    let date: Date
    var isCompleted: Bool = false
    var bestScore: Int = 0
    var stars: Int = 0
    
    var bonusMultiplier: Double {
        // Daily challenges give bonus rewards
        return 1.5
    }
    
    var shardBonus: Int {
        return 10 + (stars * 5)
    }
    
    static func generateForDate(_ date: Date) -> DailyChallenge {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        
        let gameIndex = dayOfYear % GameType.allCases.count
        let gameType = GameType.allCases[gameIndex]
        
        // Level varies based on week of year for variety
        let weekOfYear = calendar.component(.weekOfYear, from: date)
        let targetLevel = (weekOfYear % 12) + 1
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let id = dateFormatter.string(from: date)
        
        return DailyChallenge(
            id: id,
            gameType: gameType,
            targetLevel: targetLevel,
            date: date
        )
    }
}

// MARK: - Player Profile
struct PlayerProfile: Codable, Equatable {
    var username: String = "Player"
    var avatarIndex: Int = 0
    var themeIndex: Int = 0
    var totalPlayTime: TimeInterval = 0
    var gamesPlayed: Int = 0
    var totalScore: Int = 0
    var bestCombo: Int = 0
    var perfectLevels: Int = 0
    var consecutiveDays: Int = 0
    var lastPlayDate: Date?
    var joinDate: Date = Date()
    
    static let avatarOptions = [
        "person.circle.fill",
        "star.circle.fill",
        "flame.circle.fill",
        "bolt.circle.fill",
        "crown.fill",
        "diamond.fill",
        "hexagon.fill",
        "triangle.fill"
    ]
    
    static let themeNames = [
        "Neon Pulse",
        "Cosmic Drift",
        "Cyber Wave",
        "Aurora Glow"
    ]
    
    var formattedPlayTime: String {
        let hours = Int(totalPlayTime) / 3600
        let minutes = (Int(totalPlayTime) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    var playerRank: String {
        switch totalScore {
        case 0..<500: return "Novice"
        case 500..<2000: return "Apprentice"
        case 2000..<5000: return "Skilled"
        case 5000..<10000: return "Expert"
        case 10000..<25000: return "Master"
        case 25000..<50000: return "Champion"
        default: return "Legend"
        }
    }
    
    var rankColor: Color {
        switch totalScore {
        case 0..<500: return Color.gray
        case 500..<2000: return Color.green
        case 2000..<5000: return Color.blue
        case 5000..<10000: return Color.purple
        case 10000..<25000: return Color.orange
        case 25000..<50000: return Color("HighlightTone")
        default: return Color("AccentGlow")
        }
    }
}

// MARK: - Shop Items
enum ShopItemType: String, CaseIterable, Codable {
    case avatar
    case theme
    case booster
}

struct ShopItem: Codable, Identifiable, Equatable {
    let id: String
    let type: ShopItemType
    let name: String
    let description: String
    let price: Int
    let icon: String
    var isPurchased: Bool = false
    
    static let allItems: [ShopItem] = [
        // Avatars
        ShopItem(id: "avatar_crown", type: .avatar, name: "Royal Crown", description: "A majestic crown avatar", price: 100, icon: "crown.fill"),
        ShopItem(id: "avatar_star", type: .avatar, name: "Shining Star", description: "Radiant star avatar", price: 75, icon: "star.circle.fill"),
        ShopItem(id: "avatar_fire", type: .avatar, name: "Blazing Flame", description: "Fiery flame avatar", price: 80, icon: "flame.fill"),
        ShopItem(id: "avatar_bolt", type: .avatar, name: "Lightning Bolt", description: "Electrifying avatar", price: 90, icon: "bolt.circle.fill"),
        ShopItem(id: "avatar_gem", type: .avatar, name: "Crystal Gem", description: "Precious gem avatar", price: 150, icon: "diamond.fill"),
        
        // Themes
        ShopItem(id: "theme_cosmic", type: .theme, name: "Cosmic Dreams", description: "Deep space vibes", price: 200, icon: "moon.stars.fill"),
        ShopItem(id: "theme_aurora", type: .theme, name: "Aurora Lights", description: "Northern lights inspired", price: 200, icon: "sparkles"),
        ShopItem(id: "theme_cyber", type: .theme, name: "Cyber Punk", description: "Neon-lit future", price: 250, icon: "cpu.fill"),
        
        // Boosters
        ShopItem(id: "booster_time", type: .booster, name: "Time Extender", description: "+10 seconds per level", price: 50, icon: "clock.badge.fill"),
        ShopItem(id: "booster_score", type: .booster, name: "Score Multiplier", description: "2x score for next game", price: 75, icon: "multiply.circle.fill"),
        ShopItem(id: "booster_hint", type: .booster, name: "Hint Pack", description: "3 hints for tough levels", price: 40, icon: "lightbulb.fill")
    ]
}

// MARK: - Settings
struct GameSettings: Codable, Equatable {
    var hapticFeedbackEnabled: Bool = true
    var soundEnabled: Bool = true
    var musicEnabled: Bool = true
    var showTutorials: Bool = true
    var reducedMotion: Bool = false
    var autoSaveProgress: Bool = true
    var notificationsEnabled: Bool = true
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
class AppState2: ObservableObject {
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        }
    }
    
    @Published var shards: Int {
        didSet {
            UserDefaults.standard.set(shards, forKey: "shards")
            checkShardAchievements()
        }
    }
    
    @Published var gameProgress: [GameType: GameProgressData] = [:] {
        didSet {
            saveProgress()
        }
    }
    
    @Published var achievements: [Achievement] = [] {
        didSet {
            saveAchievements()
        }
    }
    
    @Published var dailyChallenges: [DailyChallenge] = [] {
        didSet {
            saveDailyChallenges()
        }
    }
    
    @Published var playerProfile: PlayerProfile = PlayerProfile() {
        didSet {
            savePlayerProfile()
        }
    }
    
    @Published var settings: GameSettings = GameSettings() {
        didSet {
            saveSettings()
            applySettingsChanges(oldValue: oldValue)
        }
    }
    
    private func applySettingsChanges(oldValue: GameSettings) {
        // Handle music toggle
        if settings.musicEnabled != oldValue.musicEnabled {
            if settings.musicEnabled {
                AudioManager.shared.playBackgroundMusic()
            } else {
                AudioManager.shared.stopBackgroundMusic()
            }
        }
        
        // Haptic feedback for toggle changes
        if settings.hapticFeedbackEnabled {
            HapticsManager.shared.toggleChanged()
        }
    }
    
    @Published var purchasedItems: Set<String> = [] {
        didSet {
            savePurchasedItems()
        }
    }
    
    @Published var activeBoosters: Set<String> = []
    
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
        
        // Load achievements
        loadAchievements()
        
        // Load daily challenges
        loadDailyChallenges()
        
        // Load player profile
        loadPlayerProfile()
        
        // Load settings
        loadSettings()
        
        // Load purchased items
        loadPurchasedItems()
        
        // Update consecutive days
        updateConsecutiveDays()
        
        // Ensure today's daily challenge exists
        ensureTodaysDailyChallenge()
        
        // Initialize managers with reference to this state
        setupManagers()
    }
    
    // MARK: - Manager Setup
    
    private func setupManagers() {
        HapticsManager.shared.appState = self
        AudioManager.shared.appState = self
        
        // Start background music if enabled
        if settings.musicEnabled {
            AudioManager.shared.playBackgroundMusic()
        }
    }
    
    // MARK: - Progress Methods
    
    func progress(for gameType: GameType) -> GameProgressData {
        return gameProgress[gameType] ?? GameProgressData(totalLevels: gameType.totalLevels)
    }
    
    func completeLevel(gameType: GameType, level: Int, score: Int, stars: Int) {
        var progress = gameProgress[gameType] ?? GameProgressData(totalLevels: gameType.totalLevels)
        let wasCompleted = progress.levels.first(where: { $0.id == level })?.isCompleted ?? false
        
        progress.completeLevel(level, score: score, stars: stars)
        gameProgress[gameType] = progress
        
        // Award shards for first completion
        var earnedShards = 0
        if !wasCompleted {
            earnedShards = stars + 1 // 1-4 shards based on stars
            shards += earnedShards
        }
        
        // Update player profile
        playerProfile.gamesPlayed += 1
        playerProfile.totalScore += score
        if stars == 3 {
            playerProfile.perfectLevels += 1
        }
        
        // Check achievements
        checkLevelCompletionAchievements()
        checkStarAchievements()
        checkGameMasterAchievement()
        
        // Check if this was a daily challenge
        checkDailyChallengeCompletion(gameType: gameType, level: level, score: score, stars: stars)
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
        achievements = initializeAchievements()
        dailyChallenges = []
        playerProfile = PlayerProfile()
        purchasedItems = []
        activeBoosters = []
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
    
    // MARK: - Achievement Methods
    
    private func initializeAchievements() -> [Achievement] {
        return AchievementType.allCases.map { type in
            let required: Int
            switch type {
            case .firstWin: required = 1
            case .collector: required = 100
            case .perfectionist: required = 10
            case .speedRunner: required = 5
            case .dedicated: required = 7
            case .master: required = 60
            case .starHunter: required = 50
            case .shardMaster: required = 500
            case .dailyPlayer: required = 3
            case .weeklyWarrior: required = 7
            case .comboKing: required = 10
            case .explorer: required = 5
            case .completionist: required = 60
            case .legendary: required = 180
            case .champion: required = 14
            }
            return Achievement(type: type, requiredProgress: required)
        }
    }
    
    private func loadAchievements() {
        if let data = UserDefaults.standard.data(forKey: "achievements"),
           let loaded = try? JSONDecoder().decode([Achievement].self, from: data) {
            self.achievements = loaded
        } else {
            self.achievements = initializeAchievements()
        }
    }
    
    private func saveAchievements() {
        if let data = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(data, forKey: "achievements")
        }
    }
    
    func unlockAchievement(_ type: AchievementType) {
        guard let index = achievements.firstIndex(where: { $0.type == type }) else { return }
        guard !achievements[index].isUnlocked else { return }
        
        achievements[index].isUnlocked = true
        achievements[index].unlockedDate = Date()
        achievements[index].progress = achievements[index].requiredProgress
        
        // Award shards
        shards += type.shardReward
        
        // Check for champion achievement
        checkChampionAchievement()
    }
    
    func updateAchievementProgress(_ type: AchievementType, progress: Int) {
        guard let index = achievements.firstIndex(where: { $0.type == type }) else { return }
        guard !achievements[index].isUnlocked else { return }
        
        achievements[index].progress = progress
        
        if achievements[index].progress >= achievements[index].requiredProgress {
            unlockAchievement(type)
        }
    }
    
    private func checkLevelCompletionAchievements() {
        // First win
        if totalCompletedLevels >= 1 {
            updateAchievementProgress(.firstWin, progress: 1)
        }
        
        // Completionist
        updateAchievementProgress(.completionist, progress: totalCompletedLevels)
    }
    
    private func checkStarAchievements() {
        // Star hunter
        updateAchievementProgress(.starHunter, progress: totalStars)
        
        // Perfectionist (3-star levels)
        updateAchievementProgress(.perfectionist, progress: playerProfile.perfectLevels)
        
        // Legendary (all 3 stars)
        updateAchievementProgress(.legendary, progress: totalStars)
    }
    
    private func checkShardAchievements() {
        updateAchievementProgress(.collector, progress: shards)
        updateAchievementProgress(.shardMaster, progress: shards)
    }
    
    private func checkGameMasterAchievement() {
        // Check if all games have been played
        var gamesPlayed = 0
        for gameType in GameType.allCases {
            if progress(for: gameType).completedLevelsCount > 0 {
                gamesPlayed += 1
            }
        }
        updateAchievementProgress(.explorer, progress: gamesPlayed)
        
        // Check if all levels completed
        updateAchievementProgress(.master, progress: totalCompletedLevels)
    }
    
    private func checkChampionAchievement() {
        let unlockedCount = achievements.filter { $0.isUnlocked && $0.type != .champion }.count
        updateAchievementProgress(.champion, progress: unlockedCount)
    }
    
    var unlockedAchievementsCount: Int {
        achievements.filter { $0.isUnlocked }.count
    }
    
    // MARK: - Daily Challenge Methods
    
    private func loadDailyChallenges() {
        if let data = UserDefaults.standard.data(forKey: "dailyChallenges"),
           let loaded = try? JSONDecoder().decode([DailyChallenge].self, from: data) {
            self.dailyChallenges = loaded
        }
    }
    
    private func saveDailyChallenges() {
        if let data = try? JSONEncoder().encode(dailyChallenges) {
            UserDefaults.standard.set(data, forKey: "dailyChallenges")
        }
    }
    
    func ensureTodaysDailyChallenge() {
        let today = Calendar.current.startOfDay(for: Date())
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayId = dateFormatter.string(from: today)
        
        if !dailyChallenges.contains(where: { $0.id == todayId }) {
            let newChallenge = DailyChallenge.generateForDate(today)
            dailyChallenges.append(newChallenge)
        }
        
        // Keep only last 30 days of challenges
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: today) ?? today
        dailyChallenges = dailyChallenges.filter { $0.date >= thirtyDaysAgo }
    }
    
    var todaysDailyChallenge: DailyChallenge? {
        let today = Calendar.current.startOfDay(for: Date())
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayId = dateFormatter.string(from: today)
        return dailyChallenges.first(where: { $0.id == todayId })
    }
    
    private func checkDailyChallengeCompletion(gameType: GameType, level: Int, score: Int, stars: Int) {
        guard let challenge = todaysDailyChallenge,
              challenge.gameType == gameType,
              challenge.targetLevel == level,
              !challenge.isCompleted else { return }
        
        if let index = dailyChallenges.firstIndex(where: { $0.id == challenge.id }) {
            dailyChallenges[index].isCompleted = true
            dailyChallenges[index].bestScore = score
            dailyChallenges[index].stars = stars
            
            // Award bonus shards
            shards += dailyChallenges[index].shardBonus
            
            // Update achievement progress
            let completedDailies = dailyChallenges.filter { $0.isCompleted }.count
            updateAchievementProgress(.dailyPlayer, progress: completedDailies)
            updateAchievementProgress(.weeklyWarrior, progress: completedDailies)
        }
    }
    
    var completedDailyChallengesCount: Int {
        dailyChallenges.filter { $0.isCompleted }.count
    }
    
    // MARK: - Player Profile Methods
    
    private func loadPlayerProfile() {
        if let data = UserDefaults.standard.data(forKey: "playerProfile"),
           let loaded = try? JSONDecoder().decode(PlayerProfile.self, from: data) {
            self.playerProfile = loaded
        }
    }
    
    private func savePlayerProfile() {
        if let data = try? JSONEncoder().encode(playerProfile) {
            UserDefaults.standard.set(data, forKey: "playerProfile")
        }
    }
    
    func updatePlayTime(_ seconds: TimeInterval) {
        playerProfile.totalPlayTime += seconds
    }
    
    func updateBestCombo(_ combo: Int) {
        if combo > playerProfile.bestCombo {
            playerProfile.bestCombo = combo
            updateAchievementProgress(.comboKing, progress: combo)
        }
    }
    
    private func updateConsecutiveDays() {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastPlay = playerProfile.lastPlayDate {
            let lastPlayDay = Calendar.current.startOfDay(for: lastPlay)
            
            if lastPlayDay == today {
                // Already played today, no change
                return
            } else if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today),
                      lastPlayDay == yesterday {
                // Played yesterday, increment streak
                playerProfile.consecutiveDays += 1
                updateAchievementProgress(.dedicated, progress: playerProfile.consecutiveDays)
            } else {
                // Streak broken
                playerProfile.consecutiveDays = 1
            }
        } else {
            playerProfile.consecutiveDays = 1
        }
        
        playerProfile.lastPlayDate = today
    }
    
    // MARK: - Profile Editing
    
    /// Update player username
    func updateUsername(_ newUsername: String) {
        guard !newUsername.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        playerProfile.username = newUsername.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Update player avatar
    func updateAvatar(index: Int) {
        guard index >= 0 && index < PlayerProfile.avatarOptions.count else { return }
        playerProfile.avatarIndex = index
    }
    
    /// Update player theme
    func updateTheme(index: Int) {
        guard index >= 0 && index < PlayerProfile.themeNames.count else { return }
        playerProfile.themeIndex = index
    }
    
    /// Reset only player profile (keeps game progress)
    func resetPlayerProfile() {
        let oldJoinDate = playerProfile.joinDate
        playerProfile = PlayerProfile()
        playerProfile.joinDate = oldJoinDate // Preserve original join date
    }
    
    /// Delete player profile completely (creates new default profile)
    func deletePlayerProfile() {
        playerProfile = PlayerProfile()
        UserDefaults.standard.removeObject(forKey: "playerProfile")
    }
    
    // MARK: - Full App Reset
    
    /// Completely reset the app to initial state (deletes everything)
    func resetAppToInitialState() {
        // Reset all progress
        shards = 0
        for gameType in GameType.allCases {
            gameProgress[gameType] = GameProgressData(totalLevels: gameType.totalLevels)
        }
        
        // Reset achievements
        achievements = initializeAchievements()
        
        // Reset daily challenges
        dailyChallenges = []
        
        // Reset player profile
        playerProfile = PlayerProfile()
        
        // Reset settings to defaults
        settings = GameSettings()
        
        // Reset shop
        purchasedItems = []
        activeBoosters = []
        
        // Reset onboarding
        hasCompletedOnboarding = false
        
        // Clear all UserDefaults for this app
        clearAllUserDefaults()
        
        // Save fresh state
        saveProgress()
        saveAchievements()
        saveDailyChallenges()
        savePlayerProfile()
        saveSettings()
        savePurchasedItems()
    }
    
    /// Reset only game progress (keeps profile and settings)
    func resetGameProgressOnly() {
        shards = 0
        for gameType in GameType.allCases {
            gameProgress[gameType] = GameProgressData(totalLevels: gameType.totalLevels)
        }
        
        // Reset achievements related to progress
        achievements = initializeAchievements()
        
        // Reset daily challenges
        dailyChallenges = []
        
        // Keep profile stats but reset game-related ones
        playerProfile.gamesPlayed = 0
        playerProfile.totalScore = 0
        playerProfile.bestCombo = 0
        playerProfile.perfectLevels = 0
        playerProfile.consecutiveDays = 0
        playerProfile.lastPlayDate = nil
        
        saveProgress()
        saveAchievements()
        saveDailyChallenges()
    }
    
    /// Clear all UserDefaults keys used by the app
    private func clearAllUserDefaults() {
        let keys = [
            "hasCompletedOnboarding",
            "shards",
            "achievements",
            "dailyChallenges",
            "playerProfile",
            "gameSettings",
            "purchasedItems"
        ]
        
        for key in keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
        
        // Clear game progress keys
        for gameType in GameType.allCases {
            let key = "progress_\(gameType.rawValue)"
            UserDefaults.standard.removeObject(forKey: key)
        }
        
        UserDefaults.standard.synchronize()
    }
    
    /// Export profile data as JSON string (for backup)
    func exportProfileData() -> String? {
        let exportData = ProfileExportData(
            profile: playerProfile,
            shards: shards,
            achievements: achievements,
            gameProgress: gameProgress,
            settings: settings,
            purchasedItems: Array(purchasedItems)
        )
        
        guard let data = try? JSONEncoder().encode(exportData) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    /// Import profile data from JSON string (for restore)
    func importProfileData(from jsonString: String) -> Bool {
        guard let data = jsonString.data(using: .utf8),
              let importData = try? JSONDecoder().decode(ProfileExportData.self, from: data) else {
            return false
        }
        
        playerProfile = importData.profile
        shards = importData.shards
        achievements = importData.achievements
        gameProgress = importData.gameProgress
        settings = importData.settings
        purchasedItems = Set(importData.purchasedItems)
        
        return true
    }
    
    // MARK: - Settings Methods
    
    private func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: "gameSettings"),
           let loaded = try? JSONDecoder().decode(GameSettings.self, from: data) {
            self.settings = loaded
        }
    }
    
    private func saveSettings() {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: "gameSettings")
        }
    }
    
    // MARK: - Shop Methods
    
    private func loadPurchasedItems() {
        if let items = UserDefaults.standard.stringArray(forKey: "purchasedItems") {
            self.purchasedItems = Set(items)
        }
    }
    
    private func savePurchasedItems() {
        UserDefaults.standard.set(Array(purchasedItems), forKey: "purchasedItems")
    }
    
    func purchaseItem(_ item: ShopItem) -> Bool {
        guard shards >= item.price else { return false }
        guard !purchasedItems.contains(item.id) else { return false }
        
        shards -= item.price
        purchasedItems.insert(item.id)
        
        // Apply item effects
        switch item.type {
        case .avatar:
            if let index = PlayerProfile.avatarOptions.firstIndex(of: item.icon) {
                playerProfile.avatarIndex = index
            }
        case .theme:
            // Theme logic
            break
        case .booster:
            activeBoosters.insert(item.id)
        }
        
        return true
    }
    
    func isItemPurchased(_ itemId: String) -> Bool {
        purchasedItems.contains(itemId)
    }
    
    func useBooster(_ boosterId: String) {
        activeBoosters.remove(boosterId)
    }
    
    // MARK: - Statistics
    
    var overallCompletionPercentage: Double {
        let total = GameType.allCases.count * 12
        return Double(totalCompletedLevels) / Double(total)
    }
    
    var averageStarsPerLevel: Double {
        guard totalCompletedLevels > 0 else { return 0 }
        return Double(totalStars) / Double(totalCompletedLevels)
    }
    
    func gameCompletionPercentage(for gameType: GameType) -> Double {
        let progress = self.progress(for: gameType)
        return Double(progress.completedLevelsCount) / Double(gameType.totalLevels)
    }
}

// MARK: - Profile Export/Import Data Structure
struct ProfileExportData: Codable {
    let profile: PlayerProfile
    let shards: Int
    let achievements: [Achievement]
    let gameProgress: [GameType: GameProgressData]
    let settings: GameSettings
    let purchasedItems: [String]
    
    var exportDate: Date = Date()
    var appVersion: String = "1.0.0"
}
