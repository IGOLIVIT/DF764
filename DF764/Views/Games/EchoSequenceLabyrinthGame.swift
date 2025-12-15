//
//  EchoSequenceLabyrinthGame.swift
//  DF764
//

import SwiftUI
import Combine

struct EchoSequenceLabyrinthGame: View {
    let level: Int
    let onComplete: (Int, Int) -> Void
    
    @State private var gameState: GamePlayState = .ready
    @State private var maze: [[MazeCell]] = []
    @State private var startPoint: CGPoint = .zero
    @State private var endPoint: CGPoint = .zero
    @State private var currentPath: [CGPoint] = []
    @State private var collectibles: [CGPoint] = []
    @State private var collectedItems: Set<String> = []
    @State private var timeRemaining: Double = 0
    @State private var score: Int = 0
    @State private var revealedCells: Set<String> = []
    @State private var hasFog: Bool = false
    
    private var config: LevelConfig {
        LevelConfig.forLevel(level)
    }
    
    struct LevelConfig {
        let mazeSize: Int
        let timeLimit: Double
        let collectibleCount: Int
        let hasFog: Bool
        let fogRadius: Int
        let hasMovingObstacles: Bool
        
        static func forLevel(_ level: Int) -> LevelConfig {
            switch level {
            case 1: return LevelConfig(mazeSize: 5, timeLimit: 30, collectibleCount: 0, hasFog: false, fogRadius: 0, hasMovingObstacles: false)
            case 2: return LevelConfig(mazeSize: 5, timeLimit: 28, collectibleCount: 2, hasFog: false, fogRadius: 0, hasMovingObstacles: false)
            case 3: return LevelConfig(mazeSize: 6, timeLimit: 30, collectibleCount: 2, hasFog: false, fogRadius: 0, hasMovingObstacles: false)
            case 4: return LevelConfig(mazeSize: 6, timeLimit: 35, collectibleCount: 3, hasFog: true, fogRadius: 2, hasMovingObstacles: false)
            case 5: return LevelConfig(mazeSize: 7, timeLimit: 40, collectibleCount: 3, hasFog: true, fogRadius: 2, hasMovingObstacles: false)
            case 6: return LevelConfig(mazeSize: 7, timeLimit: 40, collectibleCount: 4, hasFog: true, fogRadius: 2, hasMovingObstacles: false)
            case 7: return LevelConfig(mazeSize: 8, timeLimit: 45, collectibleCount: 4, hasFog: true, fogRadius: 2, hasMovingObstacles: true)
            case 8: return LevelConfig(mazeSize: 8, timeLimit: 45, collectibleCount: 5, hasFog: true, fogRadius: 1, hasMovingObstacles: true)
            case 9: return LevelConfig(mazeSize: 9, timeLimit: 50, collectibleCount: 5, hasFog: true, fogRadius: 1, hasMovingObstacles: true)
            case 10: return LevelConfig(mazeSize: 9, timeLimit: 50, collectibleCount: 6, hasFog: true, fogRadius: 1, hasMovingObstacles: true)
            case 11: return LevelConfig(mazeSize: 10, timeLimit: 55, collectibleCount: 6, hasFog: true, fogRadius: 1, hasMovingObstacles: true)
            case 12: return LevelConfig(mazeSize: 10, timeLimit: 60, collectibleCount: 8, hasFog: true, fogRadius: 1, hasMovingObstacles: true)
            default: return LevelConfig(mazeSize: 5, timeLimit: 30, collectibleCount: 0, hasFog: false, fogRadius: 0, hasMovingObstacles: false)
            }
        }
    }
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 16) {
                // Stats bar
                HStack {
                    // Collectibles
                    HStack(spacing: 4) {
                        Image(systemName: "diamond.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color.cyan)
                        Text("\(collectedItems.count)/\(collectibles.count)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // Score
                    VStack(spacing: 2) {
                        Text("Score")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(Color("HighlightTone").opacity(0.7))
                        Text("\(score)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(Color("AccentGlow"))
                    }
                    
                    Spacer()
                    
                    // Timer
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 14))
                            .foregroundColor(timeRemaining < 10 ? Color("AccentGlow") : Color("HighlightTone"))
                        Text(String(format: "%.1f", max(0, timeRemaining)))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(timeRemaining < 10 ? Color("AccentGlow") : .white)
                    }
                }
                .padding(.horizontal, 24)
                
                // Timer bar
                GeometryReader { barGeometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.cyan, Color("HighlightTone")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: barGeometry.size.width * CGFloat(timeRemaining / config.timeLimit))
                    }
                }
                .frame(height: 6)
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Maze
                let cellSize = min((geometry.size.width - 40) / CGFloat(config.mazeSize), 50.0)
                
                ZStack {
                    // Maze grid
                    VStack(spacing: 0) {
                        ForEach(0..<config.mazeSize, id: \.self) { row in
                            HStack(spacing: 0) {
                                ForEach(0..<config.mazeSize, id: \.self) { col in
                                    let point = CGPoint(x: col, y: row)
                                    let key = "\(col),\(row)"
                                    let isVisible = !config.hasFog || isCellVisible(col: col, row: row)
                                    
                                    LabyrinthCellView(
                                        cell: getCellAt(row: row, col: col),
                                        isStart: point == startPoint,
                                        isEnd: point == endPoint,
                                        isInPath: currentPath.contains(point),
                                        hasCollectible: collectibles.contains(point) && !collectedItems.contains(key),
                                        isVisible: isVisible,
                                        size: cellSize
                                    )
                                }
                            }
                        }
                    }
                    .overlay(
                        PathDrawingOverlay(
                            path: currentPath,
                            cellSize: cellSize,
                            mazeSize: config.mazeSize
                        )
                    )
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                handleDrag(value, cellSize: cellSize)
                            }
                            .onEnded { _ in
                                handleDragEnd()
                            }
                    )
                    .disabled(gameState != .playing)
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Action button
                if gameState == .ready || gameState == .failed {
                    VStack(spacing: 12) {
                        GlowingButton(title: gameState == .ready ? "Start" : "Try Again") {
                            startGame()
                        }
                        .padding(.horizontal, 40)
                        
                        if config.hasFog {
                            Text("Navigate through the fog!")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(Color.cyan.opacity(0.7))
                        }
                    }
                    .padding(.bottom, 16)
                }
            }
        }
        .onReceive(timer) { _ in
            if gameState == .playing {
                timeRemaining -= 0.1
                if timeRemaining <= 0 {
                    gameState = .failed
                }
            }
        }
        .onAppear {
            generateMaze()
        }
    }
    
    private func getCellAt(row: Int, col: Int) -> MazeCell {
        guard maze.indices.contains(row) && maze[row].indices.contains(col) else {
            return .wall
        }
        return maze[row][col]
    }
    
    private func isCellVisible(col: Int, row: Int) -> Bool {
        guard config.hasFog else { return true }
        
        // Always show start and end
        if CGPoint(x: col, y: row) == startPoint || CGPoint(x: col, y: row) == endPoint {
            return true
        }
        
        // Check if near current path position
        if let lastPoint = currentPath.last {
            let dx = abs(Int(lastPoint.x) - col)
            let dy = abs(Int(lastPoint.y) - row)
            if dx <= config.fogRadius && dy <= config.fogRadius {
                return true
            }
        }
        
        // Check if near start when no path yet
        if currentPath.isEmpty {
            let dx = abs(Int(startPoint.x) - col)
            let dy = abs(Int(startPoint.y) - row)
            if dx <= config.fogRadius && dy <= config.fogRadius {
                return true
            }
        }
        
        // Check if previously revealed
        return revealedCells.contains("\(col),\(row)")
    }
    
    private func generateMaze() {
        let size = config.mazeSize
        maze = Array(repeating: Array(repeating: MazeCell.wall, count: size), count: size)
        
        startPoint = CGPoint(x: 0, y: 0)
        endPoint = CGPoint(x: size - 1, y: size - 1)
        
        generatePath()
        addExtraPaths()
        generateCollectibles()
        
        gameState = .ready
    }
    
    private func generatePath() {
        var current = startPoint
        maze[Int(current.y)][Int(current.x)] = .path
        
        while current != endPoint {
            var possibleMoves: [CGPoint] = []
            
            if current.x < endPoint.x {
                possibleMoves.append(CGPoint(x: current.x + 1, y: current.y))
            }
            if current.y < endPoint.y {
                possibleMoves.append(CGPoint(x: current.x, y: current.y + 1))
            }
            
            // Add some randomness for more interesting paths
            if Bool.random() && current.x > 0 {
                let backPoint = CGPoint(x: current.x - 1, y: current.y)
                if maze[Int(backPoint.y)][Int(backPoint.x)] == .wall {
                    possibleMoves.append(backPoint)
                }
            }
            if Bool.random() && current.y > 0 {
                let backPoint = CGPoint(x: current.x, y: current.y - 1)
                if maze[Int(backPoint.y)][Int(backPoint.x)] == .wall {
                    possibleMoves.append(backPoint)
                }
            }
            
            if let nextMove = possibleMoves.randomElement() {
                current = nextMove
                maze[Int(current.y)][Int(current.x)] = .path
            } else {
                if current.x < endPoint.x {
                    current = CGPoint(x: current.x + 1, y: current.y)
                } else {
                    current = CGPoint(x: current.x, y: current.y + 1)
                }
                maze[Int(current.y)][Int(current.x)] = .path
            }
        }
    }
    
    private func addExtraPaths() {
        let extraCells = config.mazeSize * 3
        for _ in 0..<extraCells {
            let x = Int.random(in: 0..<config.mazeSize)
            let y = Int.random(in: 0..<config.mazeSize)
            
            if isAdjacentToPath(x: x, y: y) {
                maze[y][x] = .path
            }
        }
    }
    
    private func isAdjacentToPath(x: Int, y: Int) -> Bool {
        let neighbors = [(x-1, y), (x+1, y), (x, y-1), (x, y+1)]
        for (nx, ny) in neighbors {
            if nx >= 0 && nx < config.mazeSize && ny >= 0 && ny < config.mazeSize {
                if maze[ny][nx] == .path {
                    return true
                }
            }
        }
        return false
    }
    
    private func generateCollectibles() {
        collectibles = []
        var attempts = 0
        
        while collectibles.count < config.collectibleCount && attempts < 100 {
            let x = Int.random(in: 1..<config.mazeSize-1)
            let y = Int.random(in: 1..<config.mazeSize-1)
            let point = CGPoint(x: x, y: y)
            
            if maze[y][x] == .path && point != startPoint && point != endPoint && !collectibles.contains(point) {
                collectibles.append(point)
            }
            attempts += 1
        }
    }
    
    private func startGame() {
        generateMaze()
        timeRemaining = config.timeLimit
        currentPath = []
        collectedItems = []
        revealedCells = []
        score = 0
        gameState = .playing
    }
    
    private func handleDrag(_ value: DragGesture.Value, cellSize: CGFloat) {
        guard gameState == .playing else { return }
        
        let col = Int(value.location.x / cellSize)
        let row = Int(value.location.y / cellSize)
        
        guard row >= 0 && row < config.mazeSize && col >= 0 && col < config.mazeSize else { return }
        guard maze[row][col] == .path else { return }
        
        let point = CGPoint(x: col, y: row)
        
        if currentPath.isEmpty {
            if point == startPoint {
                currentPath.append(point)
                revealCellsAround(col: col, row: row)
            }
            return
        }
        
        if let lastPoint = currentPath.last {
            let dx = abs(point.x - lastPoint.x)
            let dy = abs(point.y - lastPoint.y)
            
            if (dx == 1 && dy == 0) || (dx == 0 && dy == 1) {
                if !currentPath.contains(point) {
                    currentPath.append(point)
                    revealCellsAround(col: col, row: row)
                    
                    // Check for collectibles
                    let key = "\(col),\(row)"
                    if collectibles.contains(point) && !collectedItems.contains(key) {
                        collectedItems.insert(key)
                        score += 50
                    }
                    
                    if point == endPoint {
                        completeLevel()
                    }
                }
            }
        }
    }
    
    private func revealCellsAround(col: Int, row: Int) {
        for dx in -config.fogRadius...config.fogRadius {
            for dy in -config.fogRadius...config.fogRadius {
                let nx = col + dx
                let ny = row + dy
                if nx >= 0 && nx < config.mazeSize && ny >= 0 && ny < config.mazeSize {
                    revealedCells.insert("\(nx),\(ny)")
                }
            }
        }
    }
    
    private func handleDragEnd() {
        if gameState == .playing && currentPath.last != endPoint {
            currentPath = []
        }
    }
    
    private func completeLevel() {
        gameState = .success
        
        // Bonus for remaining time
        let timeBonus = Int(timeRemaining * 2)
        score += timeBonus
        
        // Bonus for collecting all items
        if collectedItems.count == collectibles.count && collectibles.count > 0 {
            score += 100
        }
        
        let stars = calculateStars()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onComplete(score, stars)
        }
    }
    
    private func calculateStars() -> Int {
        let allCollected = collectedItems.count == collectibles.count
        let timePercentage = timeRemaining / config.timeLimit
        
        if allCollected && timePercentage > 0.5 { return 3 }
        if allCollected || timePercentage > 0.3 { return 2 }
        return 1
    }
}

enum MazeCell {
    case wall
    case path
}

struct LabyrinthCellView: View {
    let cell: MazeCell
    let isStart: Bool
    let isEnd: Bool
    let isInPath: Bool
    let hasCollectible: Bool
    let isVisible: Bool
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(cellColor)
                .frame(width: size, height: size)
            
            if isVisible {
                if isStart {
                    Circle()
                        .fill(Color.cyan)
                        .frame(width: size * 0.5, height: size * 0.5)
                }
                
                if isEnd {
                    Image(systemName: "flag.fill")
                        .font(.system(size: size * 0.4))
                        .foregroundColor(Color("HighlightTone"))
                }
                
                if hasCollectible {
                    Image(systemName: "diamond.fill")
                        .font(.system(size: size * 0.35))
                        .foregroundColor(Color.cyan)
                }
            }
            
            Rectangle()
                .stroke(Color.white.opacity(0.05), lineWidth: 0.5)
                .frame(width: size, height: size)
        }
    }
    
    private var cellColor: Color {
        if !isVisible {
            return Color.black.opacity(0.8)
        }
        if cell == .wall {
            return Color("PrimaryBackground")
        } else if isInPath {
            return Color.cyan.opacity(0.3)
        } else {
            return Color.white.opacity(0.08)
        }
    }
}

struct PathDrawingOverlay: View {
    let path: [CGPoint]
    let cellSize: CGFloat
    let mazeSize: Int
    
    var body: some View {
        Canvas { context, size in
            guard path.count > 1 else { return }
            
            var drawPath = Path()
            
            for (index, point) in path.enumerated() {
                let x = point.x * cellSize + cellSize / 2
                let y = point.y * cellSize + cellSize / 2
                
                if index == 0 {
                    drawPath.move(to: CGPoint(x: x, y: y))
                } else {
                    drawPath.addLine(to: CGPoint(x: x, y: y))
                }
            }
            
            context.stroke(
                drawPath,
                with: .color(Color.cyan.opacity(0.5)),
                style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round)
            )
            
            context.stroke(
                drawPath,
                with: .linearGradient(
                    Gradient(colors: [Color.cyan, Color("HighlightTone")]),
                    startPoint: CGPoint(x: 0, y: 0),
                    endPoint: CGPoint(x: size.width, y: size.height)
                ),
                style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round)
            )
        }
    }
}

#Preview {
    ZStack {
        Color("PrimaryBackground")
            .ignoresSafeArea()
        
        EchoSequenceLabyrinthGame(level: 5, onComplete: { _, _ in })
    }
}
