//
//  PlayerProfileView.swift
//  DF764
//

import SwiftUI

struct PlayerProfileView: View {
    @EnvironmentObject var appState2: AppState2
    @Environment(\.dismiss) var dismiss
    @State private var isEditingName = false
    @State private var tempUsername = ""
    @State private var showAvatarPicker = false
    @State private var showResetProfileConfirmation = false
    @State private var showDeleteProfileConfirmation = false
    @State private var showResetAppConfirmation = false
    
    var profile: PlayerProfile {
        appState2.playerProfile
    }
    
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
                                profile.rankColor.opacity(0.15),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: geometry.size.width * 0.5
                        )
                    )
                    .frame(width: geometry.size.width, height: geometry.size.width)
                    .offset(y: -geometry.size.height * 0.25)
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
                    
                    Text("Profile")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .opacity(0)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Avatar and name
                        ProfileHeaderCard(
                            profile: profile,
                            onEditName: {
                                tempUsername = profile.username
                                isEditingName = true
                            },
                            onEditAvatar: {
                                showAvatarPicker = true
                            }
                        )
                        .padding(.horizontal, 20)
                        
                        // Rank card
                        RankCard(profile: profile, totalScore: appState2.playerProfile.totalScore)
                            .padding(.horizontal, 20)
                        
                        // Stats grid
                        StatsGridCard(
                            appState2: appState2,
                            profile: profile
                        )
                        .padding(.horizontal, 20)
                        
                        // Game-specific stats
                        GameStatsBreakdown(appState2: appState2)
                            .padding(.horizontal, 20)
                        
                        // Achievements summary
                        AchievementsSummaryCard(
                            unlockedCount: appState2.unlockedAchievementsCount,
                            totalCount: AchievementType.allCases.count
                        )
                        .padding(.horizontal, 20)
                        
                        // Profile management section
                        ProfileManagementSection(
                            onResetProfile: { showResetProfileConfirmation = true },
                            onDeleteProfile: { showDeleteProfileConfirmation = true },
                            onResetApp: { showResetAppConfirmation = true }
                        )
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.top, 8)
                }
            }
            
            // Edit name overlay
            if isEditingName {
                EditNameOverlay(
                    username: $tempUsername,
                    onSave: {
                        appState2.updateUsername(tempUsername)
                        isEditingName = false
                    },
                    onCancel: {
                        isEditingName = false
                    }
                )
            }
            
            // Avatar picker
            if showAvatarPicker {
                AvatarPickerOverlay(
                    currentIndex: profile.avatarIndex,
                    onSelect: { index in
                        appState2.updateAvatar(index: index)
                        showAvatarPicker = false
                    },
                    onCancel: {
                        showAvatarPicker = false
                    }
                )
            }
            
            // Reset profile confirmation
            if showResetProfileConfirmation {
                ProfileActionConfirmationOverlay(
                    title: "Reset Profile?",
                    message: "This will reset your profile statistics (games played, play time, combo records) but keep your game progress and shards.",
                    confirmTitle: "Reset Profile",
                    confirmColor: .orange,
                    icon: "arrow.counterclockwise.circle.fill",
                    onConfirm: {
                        appState2.resetPlayerProfile()
                        showResetProfileConfirmation = false
                    },
                    onCancel: {
                        showResetProfileConfirmation = false
                    }
                )
            }
            
            // Delete profile confirmation
            if showDeleteProfileConfirmation {
                ProfileActionConfirmationOverlay(
                    title: "Delete Profile?",
                    message: "This will delete your profile completely and create a new default profile. Your name, avatar, and all profile statistics will be lost.",
                    confirmTitle: "Delete Profile",
                    confirmColor: .red,
                    icon: "trash.circle.fill",
                    onConfirm: {
                        appState2.deletePlayerProfile()
                        showDeleteProfileConfirmation = false
                    },
                    onCancel: {
                        showDeleteProfileConfirmation = false
                    }
                )
            }
            
            // Reset app confirmation
            if showResetAppConfirmation {
                ProfileActionConfirmationOverlay(
                    title: "Reset Everything?",
                    message: "This will completely reset the app to its initial state. ALL data will be deleted: profile, game progress, shards, achievements, purchases, and settings. This cannot be undone!",
                    confirmTitle: "Reset Everything",
                    confirmColor: .red,
                    icon: "exclamationmark.triangle.fill",
                    onConfirm: {
                        appState2.resetAppToInitialState()
                        showResetAppConfirmation = false
                        dismiss()
                    },
                    onCancel: {
                        showResetAppConfirmation = false
                    }
                )
            }
        }
    }
}

// MARK: - Profile Management Section
struct ProfileManagementSection: View {
    let onResetProfile: () -> Void
    let onDeleteProfile: () -> Void
    let onResetApp: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PROFILE MANAGEMENT")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(Color.white.opacity(0.4))
                .tracking(1)
                .padding(.leading, 4)
            
            ProfileActionButton(
                icon: "arrow.counterclockwise",
                title: "Reset Profile Statistics",
                subtitle: "Clear play time, combo records",
                color: .orange,
                action: onResetProfile
            )
            
            ProfileActionButton(
                icon: "trash",
                title: "Delete Profile",
                subtitle: "Remove profile and start fresh",
                color: .red.opacity(0.8),
                action: onDeleteProfile
            )
            
            Divider()
                .background(Color.white.opacity(0.1))
                .padding(.vertical, 8)
            
            Text("DANGER ZONE")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(Color.red.opacity(0.6))
                .tracking(1)
                .padding(.leading, 4)
            
            ProfileActionButton(
                icon: "exclamationmark.triangle",
                title: "Reset Entire App",
                subtitle: "Delete ALL data and start over",
                color: .red,
                action: onResetApp
            )
        }
    }
}

struct ProfileActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.5))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(Color.white.opacity(0.3))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ProfileActionConfirmationOverlay: View {
    let title: String
    let message: String
    let confirmTitle: String
    let confirmColor: Color
    let icon: String
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }
            
            VStack(spacing: 20) {
                // Icon
                ZStack {
                    Circle()
                        .fill(confirmColor.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: icon)
                        .font(.system(size: 36))
                        .foregroundColor(confirmColor)
                }
                
                VStack(spacing: 8) {
                    Text(title)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(message)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }
                
                VStack(spacing: 12) {
                    Button(action: onConfirm) {
                        Text(confirmTitle)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(confirmColor)
                            )
                    }
                    
                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(Color.white.opacity(0.7))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color("PrimaryBackground"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(confirmColor.opacity(0.3), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 24)
        }
    }
}

struct ProfileHeaderCard: View {
    let profile: PlayerProfile
    let onEditName: () -> Void
    let onEditAvatar: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                profile.rankColor.opacity(0.3),
                                profile.rankColor.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Circle()
                    .fill(profile.rankColor.opacity(0.2))
                    .frame(width: 90, height: 90)
                
                Image(systemName: PlayerProfile.avatarOptions[profile.avatarIndex])
                    .font(.system(size: 44))
                    .foregroundColor(profile.rankColor)
                
                // Edit button
                Button(action: onEditAvatar) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color("AccentGlow"))
                        .background(Circle().fill(Color("PrimaryBackground")))
                }
                .offset(x: 35, y: 35)
            }
            
            // Name
            VStack(spacing: 6) {
                HStack(spacing: 8) {
                    Text(profile.username)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Button(action: onEditName) {
                        Image(systemName: "pencil")
                            .font(.system(size: 14))
                            .foregroundColor(Color("HighlightTone").opacity(0.6))
                    }
                }
                
                // Rank badge
                HStack(spacing: 6) {
                    Image(systemName: "shield.fill")
                        .font(.system(size: 12))
                        .foregroundColor(profile.rankColor)
                    Text(profile.playerRank)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(profile.rankColor)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(profile.rankColor.opacity(0.15))
                )
            }
            
            // Join date
            Text("Playing since \(profile.joinDate.formatted(date: .abbreviated, time: .omitted))")
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundColor(Color.white.opacity(0.4))
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(profile.rankColor.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct RankCard: View {
    let profile: PlayerProfile
    let totalScore: Int
    
    private var nextRankThreshold: Int {
        switch totalScore {
        case 0..<500: return 500
        case 500..<2000: return 2000
        case 2000..<5000: return 5000
        case 5000..<10000: return 10000
        case 10000..<25000: return 25000
        case 25000..<50000: return 50000
        default: return totalScore
        }
    }
    
    private var currentRankThreshold: Int {
        switch totalScore {
        case 0..<500: return 0
        case 500..<2000: return 500
        case 2000..<5000: return 2000
        case 5000..<10000: return 5000
        case 10000..<25000: return 10000
        case 25000..<50000: return 25000
        default: return 50000
        }
    }
    
    private var progress: Double {
        let range = nextRankThreshold - currentRankThreshold
        let current = totalScore - currentRankThreshold
        return Double(current) / Double(range)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Rank Progress")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(totalScore) / \(nextRankThreshold) XP")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(profile.rankColor)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.1))
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [profile.rankColor, profile.rankColor.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * min(1, progress))
                }
            }
            .frame(height: 10)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct StatsGridCard: View {
    let appState2: AppState2
    let profile: PlayerProfile
    
    var body: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ],
            spacing: 12
        ) {
            StatCell(
                icon: "gamecontroller.fill",
                value: "\(profile.gamesPlayed)",
                label: "Games Played",
                color: Color("AccentGlow")
            )
            
            StatCell(
                icon: "clock.fill",
                value: profile.formattedPlayTime,
                label: "Play Time",
                color: Color.blue
            )
            
            StatCell(
                icon: "star.fill",
                value: "\(appState2.totalStars)",
                label: "Total Stars",
                color: Color("HighlightTone")
            )
            
            StatCell(
                icon: "sparkles",
                value: "\(profile.bestCombo)x",
                label: "Best Combo",
                color: Color.pink
            )
            
            StatCell(
                icon: "flag.fill",
                value: "\(appState2.totalCompletedLevels)",
                label: "Levels Done",
                color: Color.green
            )
            
            StatCell(
                icon: "diamond.fill",
                value: "\(appState2.shards)",
                label: "Shards",
                color: Color.cyan
            )
        }
    }
}

struct StatCell: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(Color.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.15), lineWidth: 1)
                )
        )
    }
}

struct GameStatsBreakdown: View {
    let appState2: AppState2
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Game Completion")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            
            ForEach(GameType.allCases, id: \.self) { gameType in
                let progress = appState2.progress(for: gameType)
                let percentage = appState2.gameCompletionPercentage(for: gameType)
                
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(gameType.themeColor.opacity(0.2))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: gameType.icon)
                            .font(.system(size: 14))
                            .foregroundColor(gameType.themeColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(gameType.rawValue)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 5)
                                
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(gameType.themeColor)
                                    .frame(width: geometry.size.width * percentage, height: 5)
                            }
                        }
                        .frame(height: 5)
                    }
                    
                    Text("\(progress.completedLevelsCount)/12")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(gameType.themeColor)
                        .frame(width: 40)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.03))
                )
            }
        }
    }
}

struct AchievementsSummaryCard: View {
    let unlockedCount: Int
    let totalCount: Int
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 4)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: Double(unlockedCount) / Double(totalCount))
                    .stroke(Color("HighlightTone"), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                
                Image(systemName: "trophy.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color("HighlightTone"))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Achievements")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("\(unlockedCount) of \(totalCount) unlocked")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.5))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(Color.white.opacity(0.3))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color("HighlightTone").opacity(0.15), lineWidth: 1)
                )
        )
    }
}

struct EditNameOverlay: View {
    @Binding var username: String
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }
            
            VStack(spacing: 20) {
                Text("Edit Username")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                TextField("Username", text: $username)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("AccentGlow").opacity(0.5), lineWidth: 1)
                    )
                
                HStack(spacing: 12) {
                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(Color.white.opacity(0.7))
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    Button(action: onSave) {
                        Text("Save")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color("AccentGlow"))
                            )
                    }
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color("PrimaryBackground"))
            )
            .padding(.horizontal, 32)
        }
    }
}

struct AvatarPickerOverlay: View {
    let currentIndex: Int
    let onSelect: (Int) -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }
            
            VStack(spacing: 20) {
                Text("Choose Avatar")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 4),
                    spacing: 16
                ) {
                    ForEach(0..<PlayerProfile.avatarOptions.count, id: \.self) { index in
                        Button(action: { onSelect(index) }) {
                            ZStack {
                                Circle()
                                    .fill(
                                        currentIndex == index ?
                                        Color("AccentGlow").opacity(0.3) :
                                        Color.white.opacity(0.1)
                                    )
                                    .frame(width: 60, height: 60)
                                
                                Image(systemName: PlayerProfile.avatarOptions[index])
                                    .font(.system(size: 26))
                                    .foregroundColor(
                                        currentIndex == index ?
                                        Color("AccentGlow") :
                                        Color.white.opacity(0.7)
                                    )
                                
                                if currentIndex == index {
                                    Circle()
                                        .stroke(Color("AccentGlow"), lineWidth: 3)
                                        .frame(width: 60, height: 60)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 8)
                
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color("AccentGlow"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color("AccentGlow"), lineWidth: 2)
                        )
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color("PrimaryBackground"))
            )
            .padding(.horizontal, 32)
        }
    }
}

#Preview {
    PlayerProfileView()
        .environmentObject(AppState2())
}
