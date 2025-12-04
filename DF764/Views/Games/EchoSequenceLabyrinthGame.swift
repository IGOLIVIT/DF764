//
//  EchoSequenceLabyrinthGame.swift
//  DF764
//

import SwiftUI
import Combine

struct EchoSequenceLabyrinthGame: View {
    let difficulty: Difficulty
    let currentLevel: Int
    let onLevelComplete: () -> Void
    
    @State private var gameState: GamePlayState = .ready
    @State private var maze: [[MazeCell]] = []
    @State private var startPoint: CGPoint = .zero
    @State private var endPoint: CGPoint = .zero
    @State private var currentPath: [CGPoint] = []
    @State private var correctPath: [CGPoint] = []
    @State private var timeRemaining: Double = 0
    @State private var showInstructions = true
    @State private var isDrawing = false
    @State private var pathProgress: CGFloat = 0
    
    private var mazeSize: Int {
        switch currentLevel {
        case 1: return 5
        case 2: return 6
        case 3: return 7
        default: return 5
        }
    }
    
    private var timeLimit: Double {
        let baseTime: Double
        switch currentLevel {
        case 1: baseTime = 20
        case 2: baseTime = 25
        case 3: baseTime = 30
        default: baseTime = 20
        }
        
        switch difficulty {
        case .easy: return baseTime * 1.5
        case .normal: return baseTime
        case .hard: return baseTime * 0.7
        }
    }
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                // Timer
                VStack(spacing: 8) {
                    Text("Time Remaining")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color("HighlightTone").opacity(0.7))
                    
                    Text(String(format: "%.1f", max(0, timeRemaining)))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(timeRemaining < 5 ? Color("AccentGlow") : .white)
                    
                    // Timer bar
                    GeometryReader { barGeometry in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.1))
                            
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color("AccentGlow"), Color("HighlightTone")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: barGeometry.size.width * CGFloat(timeRemaining / timeLimit))
                                .animation(.linear(duration: 0.1), value: timeRemaining)
                        }
                    }
                    .frame(height: 6)
                    .padding(.horizontal, 40)
                }
                .padding(.top, 16)
                
                Spacer()
                
                // Maze
                let cellSize = min((geometry.size.width - 48) / CGFloat(mazeSize), 60.0)
                
                ZStack {
                    // Maze grid
                    VStack(spacing: 0) {
                        ForEach(0..<mazeSize, id: \.self) { row in
                            HStack(spacing: 0) {
                                ForEach(0..<mazeSize, id: \.self) { col in
                                    MazeCellView(
                                        cell: maze.indices.contains(row) && maze[row].indices.contains(col) ? maze[row][col] : .wall,
                                        isStart: CGPoint(x: col, y: row) == startPoint,
                                        isEnd: CGPoint(x: col, y: row) == endPoint,
                                        isInPath: currentPath.contains(CGPoint(x: col, y: row)),
                                        size: cellSize
                                    )
                                }
                            }
                        }
                    }
                    .overlay(
                        // Path drawing overlay
                        PathDrawingView(
                            path: currentPath,
                            cellSize: cellSize,
                            mazeSize: mazeSize,
                            isComplete: gameState == .success
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
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Action button
                if gameState == .ready || gameState == .failed {
                    VStack(spacing: 12) {
                        GlowingButton(title: gameState == .ready ? "Start" : "Try Again") {
                            startGame()
                        }
                        .padding(.horizontal, 40)
                        
                        if showInstructions && gameState == .ready {
                            Text("Draw a path from start to end through the maze")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(Color("HighlightTone").opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                    }
                    .padding(.bottom, 20)
                }
                
                if gameState == .success {
                    Text("Path Complete!")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(Color("AccentGlow"))
                        .padding(.bottom, 20)
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
    
    private func generateMaze() {
        // Initialize maze with walls
        maze = Array(repeating: Array(repeating: MazeCell.wall, count: mazeSize), count: mazeSize)
        
        // Set start and end points
        startPoint = CGPoint(x: 0, y: 0)
        endPoint = CGPoint(x: mazeSize - 1, y: mazeSize - 1)
        
        // Generate a solvable path using a simple algorithm
        generatePath()
        
        // Add some extra open cells for variety
        addExtraPaths()
        
        gameState = .ready
    }
    
    private func generatePath() {
        var current = startPoint
        correctPath = [current]
        maze[Int(current.y)][Int(current.x)] = .path
        
        while current != endPoint {
            var possibleMoves: [CGPoint] = []
            
            // Prefer moving towards end
            if current.x < endPoint.x {
                possibleMoves.append(CGPoint(x: current.x + 1, y: current.y))
            }
            if current.y < endPoint.y {
                possibleMoves.append(CGPoint(x: current.x, y: current.y + 1))
            }
            
            // Add some randomness
            if Bool.random() && current.x > 0 && !correctPath.contains(CGPoint(x: current.x - 1, y: current.y)) {
                possibleMoves.append(CGPoint(x: current.x - 1, y: current.y))
            }
            if Bool.random() && current.y > 0 && !correctPath.contains(CGPoint(x: current.x, y: current.y - 1)) {
                possibleMoves.append(CGPoint(x: current.x, y: current.y - 1))
            }
            
            if let nextMove = possibleMoves.randomElement() {
                current = nextMove
                if !correctPath.contains(current) {
                    correctPath.append(current)
                    maze[Int(current.y)][Int(current.x)] = .path
                }
            } else {
                // Force move towards end
                if current.x < endPoint.x {
                    current = CGPoint(x: current.x + 1, y: current.y)
                } else {
                    current = CGPoint(x: current.x, y: current.y + 1)
                }
                if !correctPath.contains(current) {
                    correctPath.append(current)
                    maze[Int(current.y)][Int(current.x)] = .path
                }
            }
        }
    }
    
    private func addExtraPaths() {
        // Add some random open cells to make the maze more interesting
        let extraCells = mazeSize * 2
        for _ in 0..<extraCells {
            let x = Int.random(in: 0..<mazeSize)
            let y = Int.random(in: 0..<mazeSize)
            
            // Only add if adjacent to an existing path
            if isAdjacentToPath(x: x, y: y) {
                maze[y][x] = .path
            }
        }
    }
    
    private func isAdjacentToPath(x: Int, y: Int) -> Bool {
        let neighbors = [(x-1, y), (x+1, y), (x, y-1), (x, y+1)]
        for (nx, ny) in neighbors {
            if nx >= 0 && nx < mazeSize && ny >= 0 && ny < mazeSize {
                if maze[ny][nx] == .path {
                    return true
                }
            }
        }
        return false
    }
    
    private func startGame() {
        showInstructions = false
        generateMaze()
        timeRemaining = timeLimit
        currentPath = []
        gameState = .playing
    }
    
    private func handleDrag(_ value: DragGesture.Value, cellSize: CGFloat) {
        guard gameState == .playing else { return }
        
        let col = Int(value.location.x / cellSize)
        let row = Int(value.location.y / cellSize)
        
        guard row >= 0 && row < mazeSize && col >= 0 && col < mazeSize else { return }
        
        let point = CGPoint(x: col, y: row)
        
        // Check if this is a valid path cell
        guard maze[row][col] == .path else { return }
        
        // If starting, must start from start point
        if currentPath.isEmpty {
            if point == startPoint {
                currentPath.append(point)
            }
            return
        }
        
        // Check if adjacent to last point
        if let lastPoint = currentPath.last {
            let dx = abs(point.x - lastPoint.x)
            let dy = abs(point.y - lastPoint.y)
            
            if (dx == 1 && dy == 0) || (dx == 0 && dy == 1) {
                if !currentPath.contains(point) {
                    currentPath.append(point)
                    
                    // Check if reached end
                    if point == endPoint {
                        gameState = .success
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            onLevelComplete()
                        }
                    }
                }
            }
        }
    }
    
    private func handleDragEnd() {
        if gameState == .playing && currentPath.last != endPoint {
            // Reset path if not complete
            currentPath = []
        }
    }
}

enum MazeCell {
    case wall
    case path
}

struct MazeCellView: View {
    let cell: MazeCell
    let isStart: Bool
    let isEnd: Bool
    let isInPath: Bool
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(cellColor)
                .frame(width: size, height: size)
            
            if isStart {
                Circle()
                    .fill(Color("AccentGlow"))
                    .frame(width: size * 0.5, height: size * 0.5)
                    .shadow(color: Color("AccentGlow").opacity(0.5), radius: 4)
            }
            
            if isEnd {
                Image(systemName: "flag.fill")
                    .font(.system(size: size * 0.4))
                    .foregroundColor(Color("HighlightTone"))
            }
            
            Rectangle()
                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                .frame(width: size, height: size)
        }
    }
    
    private var cellColor: Color {
        if cell == .wall {
            return Color("PrimaryBackground")
        } else if isInPath {
            return Color("AccentGlow").opacity(0.4)
        } else {
            return Color.white.opacity(0.08)
        }
    }
}

struct PathDrawingView: View {
    let path: [CGPoint]
    let cellSize: CGFloat
    let mazeSize: Int
    let isComplete: Bool
    
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
            
            // Draw glow
            context.stroke(
                drawPath,
                with: .color(Color("AccentGlow").opacity(0.5)),
                style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round)
            )
            
            // Draw main path
            context.stroke(
                drawPath,
                with: .linearGradient(
                    Gradient(colors: [Color("AccentGlow"), Color("HighlightTone")]),
                    startPoint: CGPoint(x: 0, y: 0),
                    endPoint: CGPoint(x: size.width, y: size.height)
                ),
                style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round)
            )
        }
    }
}

#Preview {
    ZStack {
        Color("PrimaryBackground")
            .ignoresSafeArea()
        
        EchoSequenceLabyrinthGame(
            difficulty: .easy,
            currentLevel: 1,
            onLevelComplete: {}
        )
    }
}

