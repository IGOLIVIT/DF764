//
//  DailyChallengeView.swift
//  DF764
//

import SwiftUI

struct DailyChallengeView: View {
    @EnvironmentObject var appState2: AppState2
    @Environment(\.dismiss) var dismiss
    @State private var showGame = false
    @State private var animateGlow = false
    
    var todaysChallenge: DailyChallenge? {
        appState2.todaysDailyChallenge
    }
    
    var body: some View {
        ZStack {
            Color("PrimaryBackground")
                .ignoresSafeArea()
            
            // Animated background
            GeometryReader { geometry in
                ZStack {
                    // Pulsing circle
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.orange.opacity(animateGlow ? 0.2 : 0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: geometry.size.width * 0.5
                            )
                        )
                        .frame(width: geometry.size.width, height: geometry.size.width)
                        .offset(y: -geometry.size.height * 0.15)
                        .scaleEffect(animateGlow ? 1.1 : 1.0)
                    
                    // Secondary glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color("AccentGlow").opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: geometry.size.width * 0.3
                            )
                        )
                        .frame(width: geometry.size.width * 0.6, height: geometry.size.width * 0.6)
                        .offset(x: -geometry.size.width * 0.3, y: geometry.size.height * 0.4)
                }
            }
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Color("HighlightTone").opacity(0.6))
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 2) {
                        Text("Daily Challenge")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(Date().formatted(date: .abbreviated, time: .omitted))
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(Color.orange)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .opacity(0)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Streak indicator
                        StreakCard(
                            currentStreak: appState2.playerProfile.consecutiveDays,
                            completedChallenges: appState2.completedDailyChallengesCount
                        )
                        .padding(.horizontal, 20)
                        
                        // Today's challenge card
                        if let challenge = todaysChallenge {
                            TodaysChallengeCard(
                                challenge: challenge,
                                onPlay: {
                                    showGame = true
                                }
                            )
                            .padding(.horizontal, 20)
                        }
                        
                        // Past challenges
                        PastChallengesSection(challenges: appState2.dailyChallenges.filter {
                            $0.id != todaysChallenge?.id
                        }.sorted(by: { $0.date > $1.date }))
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.top, 8)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                animateGlow = true
            }
            appState2.ensureTodaysDailyChallenge()
        }
        .fullScreenCover(isPresented: $showGame) {
            if let challenge = todaysChallenge {
                LevelMapView(gameType: challenge.gameType)
                    .environmentObject(appState2)
            }
        }
    }
}

struct StreakCard: View {
    let currentStreak: Int
    let completedChallenges: Int
    
    var body: some View {
        HStack(spacing: 20) {
            // Streak
            VStack(spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color.orange)
                    Text("\(currentStreak)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                Text("Day Streak")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.6))
            }
            
            Divider()
                .frame(height: 40)
                .background(Color.white.opacity(0.2))
            
            // Total completed
            VStack(spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color.green)
                    Text("\(completedChallenges)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                Text("Completed")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.6))
            }
            
            Divider()
                .frame(height: 40)
                .background(Color.white.opacity(0.2))
            
            // Weekly goal
            VStack(spacing: 6) {
                let weeklyCompleted = min(completedChallenges % 7, 7)
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: 18))
                        .foregroundColor(Color.blue)
                    Text("\(weeklyCompleted)/7")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                Text("This Week")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            LinearGradient(
                                colors: [Color.orange.opacity(0.3), Color("HighlightTone").opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
}

struct TodaysChallengeCard: View {
    let challenge: DailyChallenge
    let onPlay: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("TODAY'S CHALLENGE")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(Color.orange)
                    .tracking(1)
                
                Spacer()
                
                if challenge.isCompleted {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Completed")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.green)
                    }
                }
            }
            
            // Game info
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(challenge.gameType.themeColor.opacity(0.2))
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: challenge.gameType.icon)
                        .font(.system(size: 32))
                        .foregroundColor(challenge.gameType.themeColor)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(challenge.gameType.rawValue)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Level \(challenge.targetLevel)")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(challenge.gameType.themeColor)
                    
                    if challenge.isCompleted {
                        HStack(spacing: 8) {
                            // Stars
                            HStack(spacing: 2) {
                                ForEach(1...3, id: \.self) { star in
                                    Image(systemName: star <= challenge.stars ? "star.fill" : "star")
                                        .font(.system(size: 12))
                                        .foregroundColor(star <= challenge.stars ? Color("HighlightTone") : Color.white.opacity(0.3))
                                }
                            }
                            
                            Text("Score: \(challenge.bestScore)")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(Color.white.opacity(0.6))
                        }
                    }
                }
                
                Spacer()
            }
            
            // Bonus info
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Bonus Reward")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.5))
                    
                    HStack(spacing: 4) {
                        Image(systemName: "diamond.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color("HighlightTone"))
                        Text("+\(challenge.shardBonus) Shards")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(Color("HighlightTone"))
                    }
                }
                
                Spacer()
                
                Text("1.5x Points")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(Color.orange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(Color.orange.opacity(0.2))
                    )
            }
            
            // Play button
            Button(action: onPlay) {
                HStack {
                    Image(systemName: challenge.isCompleted ? "arrow.clockwise" : "play.fill")
                        .font(.system(size: 16))
                    Text(challenge.isCompleted ? "Play Again" : "Start Challenge")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [Color.orange, Color.orange.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [Color.orange.opacity(0.4), challenge.gameType.themeColor.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
        )
    }
}

struct PastChallengesSection: View {
    let challenges: [DailyChallenge]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !challenges.isEmpty {
                Text("Past Challenges")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.leading, 4)
                
                ForEach(challenges.prefix(7)) { challenge in
                    PastChallengeRow(challenge: challenge)
                }
            }
        }
    }
}

struct PastChallengeRow: View {
    let challenge: DailyChallenge
    
    var body: some View {
        HStack(spacing: 12) {
            // Date
            VStack(spacing: 2) {
                Text(challenge.date.formatted(.dateTime.day()))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(challenge.date.formatted(.dateTime.weekday(.abbreviated)))
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.5))
            }
            .frame(width: 40)
            
            // Game icon
            ZStack {
                Circle()
                    .fill(challenge.gameType.themeColor.opacity(0.2))
                    .frame(width: 36, height: 36)
                
                Image(systemName: challenge.gameType.icon)
                    .font(.system(size: 16))
                    .foregroundColor(challenge.gameType.themeColor)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 3) {
                Text("Level \(challenge.targetLevel)")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(challenge.gameType.rawValue)
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.5))
            }
            
            Spacer()
            
            // Status
            if challenge.isCompleted {
                HStack(spacing: 4) {
                    ForEach(1...3, id: \.self) { star in
                        Image(systemName: star <= challenge.stars ? "star.fill" : "star")
                            .font(.system(size: 10))
                            .foregroundColor(star <= challenge.stars ? Color("HighlightTone") : Color.white.opacity(0.2))
                    }
                }
            } else {
                Text("Missed")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(Color.red.opacity(0.7))
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.03))
        )
    }
}

#Preview {
    DailyChallengeView()
        .environmentObject(AppState2())
}
