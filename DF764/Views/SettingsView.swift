//
//  SettingsView.swift
//  DF764
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var showResetConfirmation = false
    @State private var showStats = false
    
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
                        
                        // Settings options
                        VStack(spacing: 12) {
                            SettingsButton(
                                icon: "chart.bar.fill",
                                title: "View Stats",
                                subtitle: "Check your progress and achievements",
                                color: Color("AccentGlow")
                            ) {
                                showStats = true
                            }
                            
                            SettingsButton(
                                icon: "arrow.counterclockwise",
                                title: "Reset Progress",
                                subtitle: "Clear all data and start fresh",
                                color: Color.red.opacity(0.8)
                            ) {
                                showResetConfirmation = true
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 32)
                        
                        Spacer(minLength: 100)
                        
                        // Version info (subtle)
                        Text("Version 1.0")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(Color.white.opacity(0.3))
                            .padding(.bottom, 40)
                    }
                }
            }
            
            // Reset confirmation modal
            if showResetConfirmation {
                ResetConfirmationModal(
                    onConfirm: {
                        appState.resetProgress()
                        showResetConfirmation = false
                    },
                    onCancel: {
                        showResetConfirmation = false
                    }
                )
            }
        }
        .fullScreenCover(isPresented: $showStats) {
            ProgressStatsView()
                .environmentObject(appState)
        }
    }
}

struct SettingsButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
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
        .environmentObject(AppState())
}
