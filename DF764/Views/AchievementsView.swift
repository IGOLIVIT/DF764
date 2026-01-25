//
//  AchievementsView.swift
//  DF764
//

import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject var appState2: AppState2
    @Environment(\.dismiss) var dismiss
    @State private var selectedAchievement: Achievement?
    @State private var showCelebration = false
    
    var body: some View {
        ZStack {
            Color("PrimaryBackground")
                .ignoresSafeArea()
            
            // Background accents
            GeometryReader { geometry in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color("HighlightTone").opacity(0.15),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: geometry.size.width * 0.5
                        )
                    )
                    .frame(width: geometry.size.width, height: geometry.size.width)
                    .offset(x: geometry.size.width * 0.3, y: -geometry.size.height * 0.1)
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color("AccentGlow").opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: geometry.size.width * 0.4
                        )
                    )
                    .frame(width: geometry.size.width * 0.8, height: geometry.size.width * 0.8)
                    .offset(x: -geometry.size.width * 0.3, y: geometry.size.height * 0.5)
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
                        Text("Achievements")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("\(appState2.unlockedAchievementsCount)/\(AchievementType.allCases.count) Unlocked")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(Color("HighlightTone"))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .opacity(0)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                // Progress ring
                AchievementProgressRing(
                    progress: Double(appState2.unlockedAchievementsCount) / Double(AchievementType.allCases.count)
                )
                .padding(.vertical, 16)
                
                ScrollView(showsIndicators: false) {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ],
                        spacing: 12
                    ) {
                        ForEach(appState2.achievements.sorted(by: { a, b in
                            if a.isUnlocked != b.isUnlocked {
                                return a.isUnlocked
                            }
                            return a.progressPercentage > b.progressPercentage
                        })) { achievement in
                            AchievementCard(achievement: achievement)
                                .onTapGesture {
                                    selectedAchievement = achievement
                                }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
            }
            
            // Achievement detail sheet
            if let achievement = selectedAchievement {
                AchievementDetailSheet(
                    achievement: achievement,
                    onDismiss: { selectedAchievement = nil }
                )
            }
        }
    }
}

struct AchievementProgressRing: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 8)
                .frame(width: 100, height: 100)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [Color("AccentGlow"), Color("HighlightTone")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: 100, height: 100)
                .rotationEffect(.degrees(-90))
            
            // Percentage text
            VStack(spacing: 2) {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Complete")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(Color("HighlightTone").opacity(0.7))
            }
        }
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 10) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        achievement.isUnlocked ?
                        achievement.type.color.opacity(0.2) :
                        Color.gray.opacity(0.15)
                    )
                    .frame(width: 50, height: 50)
                
                if achievement.isUnlocked {
                    Image(systemName: achievement.type.icon)
                        .font(.system(size: 22))
                        .foregroundColor(achievement.type.color)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color.gray.opacity(0.5))
                }
            }
            
            // Title
            Text(achievement.type.title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(achievement.isUnlocked ? .white : Color.gray)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            // Progress bar
            if !achievement.isUnlocked {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 4)
                        
                        RoundedRectangle(cornerRadius: 3)
                            .fill(achievement.type.color)
                            .frame(width: geometry.size.width * achievement.progressPercentage, height: 4)
                    }
                }
                .frame(height: 4)
                
                Text("\(achievement.progress)/\(achievement.requiredProgress)")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(Color.gray)
            } else {
                // Shard reward badge
                HStack(spacing: 3) {
                    Image(systemName: "diamond.fill")
                        .font(.system(size: 8))
                        .foregroundColor(Color("HighlightTone"))
                    Text("+\(achievement.type.shardReward)")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(Color("HighlightTone"))
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            achievement.isUnlocked ?
                            achievement.type.color.opacity(0.3) :
                            Color.white.opacity(0.1),
                            lineWidth: 1
                        )
                )
        )
    }
}

struct AchievementDetailSheet: View {
    let achievement: Achievement
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
            
            VStack(spacing: 20) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    achievement.isUnlocked ?
                                    achievement.type.color.opacity(0.4) :
                                    Color.gray.opacity(0.2),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: achievement.isUnlocked ? achievement.type.icon : "lock.fill")
                        .font(.system(size: 50))
                        .foregroundColor(
                            achievement.isUnlocked ?
                            achievement.type.color :
                            Color.gray.opacity(0.5)
                        )
                }
                
                VStack(spacing: 8) {
                    Text(achievement.type.title)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(achievement.type.description)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                
                // Progress
                if !achievement.isUnlocked {
                    VStack(spacing: 8) {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 10)
                                
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(achievement.type.color)
                                    .frame(width: geometry.size.width * achievement.progressPercentage, height: 10)
                            }
                        }
                        .frame(height: 10)
                        .padding(.horizontal, 20)
                        
                        Text("\(achievement.progress) / \(achievement.requiredProgress)")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(Color.white.opacity(0.6))
                    }
                } else if let unlockedDate = achievement.unlockedDate {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Unlocked on \(unlockedDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(Color.white.opacity(0.6))
                    }
                }
                
                // Reward
                HStack(spacing: 8) {
                    Image(systemName: "diamond.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color("HighlightTone"))
                    
                    Text("\(achievement.isUnlocked ? "+" : "")\(achievement.type.shardReward) Shards")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(Color("HighlightTone"))
                }
                .padding(.top, 8)
                
                Button(action: onDismiss) {
                    Text("Close")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color("AccentGlow"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color("AccentGlow"), lineWidth: 2)
                        )
                }
                .padding(.horizontal, 40)
                .padding(.top, 8)
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color("PrimaryBackground"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                achievement.isUnlocked ?
                                achievement.type.color.opacity(0.3) :
                                Color.white.opacity(0.1),
                                lineWidth: 1
                            )
                    )
            )
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    AchievementsView()
        .environmentObject(AppState2())
}
