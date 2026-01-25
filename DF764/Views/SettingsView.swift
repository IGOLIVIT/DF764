//
//  SettingsView.swift
//  DF764
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState2: AppState2
    @Environment(\.dismiss) var dismiss
    @State private var showResetConfirmation = false
    @State private var showFullResetConfirmation = false
    @State private var showStats = false
    @State private var showTutorials = false
    
    var body: some View {
        ZStack {
            Color("PrimaryBackground")
                .ignoresSafeArea()
            
            // Background glow
            GeometryReader { geometry in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color("HighlightTone").opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: geometry.size.width * 0.5
                        )
                    )
                    .frame(width: geometry.size.width, height: geometry.size.width)
                    .offset(x: -geometry.size.width * 0.2, y: geometry.size.height * 0.3)
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
                    
                    Text("Settings")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Invisible spacer for alignment
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .opacity(0)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Settings icon
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Color("AccentGlow").opacity(0.2),
                                            Color.clear
                                        ],
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 50
                                    )
                                )
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 44))
                                .foregroundColor(Color("AccentGlow"))
                        }
                        .padding(.top, 20)
                        
                        // Game settings section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("GAME SETTINGS")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(Color("HighlightTone").opacity(0.6))
                                .tracking(1)
                                .padding(.leading, 4)
                            
                            SettingsToggle(
                                icon: "hand.tap.fill",
                                title: "Haptic Feedback",
                                subtitle: "Vibration on interactions",
                                isOn: Binding(
                                    get: { appState2.settings.hapticFeedbackEnabled },
                                    set: { appState2.settings.hapticFeedbackEnabled = $0 }
                                ),
                                color: Color.purple
                            )
                            
                            SettingsToggle(
                                icon: "speaker.wave.2.fill",
                                title: "Sound Effects",
                                subtitle: "Game audio feedback",
                                isOn: Binding(
                                    get: { appState2.settings.soundEnabled },
                                    set: { appState2.settings.soundEnabled = $0 }
                                ),
                                color: Color.blue
                            )
                            
                            SettingsToggle(
                                icon: "music.note",
                                title: "Background Music",
                                subtitle: "Ambient game music",
                                isOn: Binding(
                                    get: { appState2.settings.musicEnabled },
                                    set: { appState2.settings.musicEnabled = $0 }
                                ),
                                color: Color.green
                            )
                            
                            SettingsToggle(
                                icon: "figure.walk.motion",
                                title: "Reduced Motion",
                                subtitle: "Less animations and effects",
                                isOn: Binding(
                                    get: { appState2.settings.reducedMotion },
                                    set: { appState2.settings.reducedMotion = $0 }
                                ),
                                color: Color.orange
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        
                        // Help & Info section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("HELP & INFO")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(Color("HighlightTone").opacity(0.6))
                                .tracking(1)
                                .padding(.leading, 4)
                            
                            SettingsButton(
                                icon: "questionmark.circle.fill",
                                title: "Game Tutorials",
                                subtitle: "Learn how to play each game",
                                color: Color.cyan
                            ) {
                                showTutorials = true
                            }
                            
                            SettingsButton(
                                icon: "chart.bar.fill",
                                title: "View Statistics",
                                subtitle: "Check your progress and achievements",
                                color: Color("AccentGlow")
                            ) {
                                showStats = true
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Danger zone section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("DANGER ZONE")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(Color.red.opacity(0.6))
                                .tracking(1)
                                .padding(.leading, 4)
                            
                            SettingsButton(
                                icon: "arrow.counterclockwise",
                                title: "Reset Game Progress",
                                subtitle: "Clear levels, stars, and achievements",
                                color: Color.orange
                            ) {
                                showResetConfirmation = true
                            }
                            
                            SettingsButton(
                                icon: "exclamationmark.triangle.fill",
                                title: "Reset Entire App",
                                subtitle: "Delete ALL data and return to initial state",
                                color: Color.red
                            ) {
                                showFullResetConfirmation = true
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // App info
                        VStack(spacing: 8) {
                            Image("logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .cornerRadius(12)
                            
                            Text("Shifting Horizons")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Version 1.0.0")
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundColor(Color.white.opacity(0.4))
                        }
                        .padding(.top, 32)
                        .padding(.bottom, 40)
                    }
                }
            }
            
            // Reset confirmation modal
            if showResetConfirmation {
                ResetConfirmationModal(
                    onConfirm: {
                        appState2.resetGameProgressOnly()
                        showResetConfirmation = false
                    },
                    onCancel: {
                        showResetConfirmation = false
                    }
                )
            }
            
            // Full app reset confirmation modal
            if showFullResetConfirmation {
                FullResetConfirmationModal(
                    onConfirm: {
                        appState2.resetAppToInitialState()
                        showFullResetConfirmation = false
                        dismiss()
                    },
                    onCancel: {
                        showFullResetConfirmation = false
                    }
                )
            }
        }
        .fullScreenCover(isPresented: $showStats) {
            ProgressStatsView()
                .environmentObject(appState2)
        }
        .fullScreenCover(isPresented: $showTutorials) {
            TutorialListView()
                .environmentObject(appState2)
        }
    }
}

struct FullResetConfirmationModal: View {
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }
            
            VStack(spacing: 24) {
                // Warning icon
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.2))
                        .frame(width: 90, height: 90)
                    
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(Color.red)
                }
                
                VStack(spacing: 10) {
                    Text("Reset Entire App?")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("This will completely reset the app to its initial state.")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                            Text("All game progress will be deleted")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(Color.white.opacity(0.6))
                        }
                        HStack(spacing: 8) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                            Text("All shards will be lost")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(Color.white.opacity(0.6))
                        }
                        HStack(spacing: 8) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                            Text("Profile and achievements will be reset")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(Color.white.opacity(0.6))
                        }
                        HStack(spacing: 8) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                            Text("All purchases will be removed")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(Color.white.opacity(0.6))
                        }
                    }
                    .padding(.top, 8)
                }
                
                Text("This action cannot be undone!")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.red)
                
                VStack(spacing: 12) {
                    Button(action: onConfirm) {
                        Text("Yes, Reset Everything")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.red)
                            )
                    }
                    
                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(Color("HighlightTone"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color("HighlightTone").opacity(0.5), lineWidth: 2)
                            )
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color("PrimaryBackground"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.red.opacity(0.4), lineWidth: 1.5)
                    )
            )
            .padding(.horizontal, 20)
        }
    }
}

struct SettingsToggle: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(Color("HighlightTone").opacity(0.6))
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: color))
                .labelsHidden()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(color.opacity(0.15), lineWidth: 1)
                )
        )
    }
}

struct SettingsButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticsManager.shared.buttonPress()
            AudioManager.shared.playButtonTap()
            action()
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(Color("HighlightTone").opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("HighlightTone").opacity(0.5))
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(color.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ResetConfirmationModal: View {
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }
            
            VStack(spacing: 24) {
                // Warning icon
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color.red.opacity(0.9))
                }
                
                VStack(spacing: 8) {
                    Text("Reset Progress?")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("This will delete all your Shards and level progress. This action cannot be undone.")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }
                
                VStack(spacing: 12) {
                    Button(action: onConfirm) {
                        Text("Reset Everything")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.red.opacity(0.8))
                            )
                    }
                    
                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(Color("HighlightTone"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color("HighlightTone").opacity(0.5), lineWidth: 2)
                            )
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color("PrimaryBackground"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState2())
}
