//
//  HapticsManager.swift
//  DF764
//

import SwiftUI
import UIKit

/// Singleton manager for haptic feedback throughout the app
class HapticsManager {
    static let shared = HapticsManager()
    
    private init() {}
    
    // Reference to app state - should be set on app launch
    weak var appState: AppState2?
    
    private var isEnabled: Bool {
        appState?.settings.hapticFeedbackEnabled ?? true
    }
    
    // MARK: - Impact Haptics
    
    /// Light impact - for subtle interactions like scrolling, hovering
    func lightImpact() {
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Medium impact - for button taps, selections
    func mediumImpact() {
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Heavy impact - for important actions, confirmations
    func heavyImpact() {
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Soft impact - for gentle feedback
    func softImpact() {
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Rigid impact - for firm feedback
    func rigidImpact() {
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // MARK: - Notification Haptics
    
    /// Success notification - for completed actions, level complete
    func success() {
        guard isEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
    
    /// Warning notification - for alerts, near-miss situations
    func warning() {
        guard isEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }
    
    /// Error notification - for failures, wrong actions
    func error() {
        guard isEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }
    
    // MARK: - Selection Haptics
    
    /// Selection changed - for picker changes, tab switches
    func selectionChanged() {
        guard isEnabled else { return }
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    // MARK: - Game-specific Haptics
    
    /// Tile tap in memory game
    func tileTap() {
        lightImpact()
    }
    
    /// Correct sequence in memory game
    func correctSequence() {
        success()
    }
    
    /// Wrong sequence in memory game
    func wrongSequence() {
        error()
    }
    
    /// Orb caught in momentum game
    func orbCaught() {
        mediumImpact()
    }
    
    /// Combo achieved
    func comboAchieved() {
        heavyImpact()
    }
    
    /// Level complete
    func levelComplete() {
        success()
    }
    
    /// Achievement unlocked
    func achievementUnlocked() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.success()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.heavyImpact()
        }
    }
    
    /// Daily challenge complete
    func dailyChallengeComplete() {
        heavyImpact()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.success()
        }
    }
    
    /// Purchase made
    func purchaseMade() {
        success()
    }
    
    /// Button press feedback
    func buttonPress() {
        lightImpact()
    }
    
    /// Toggle switch changed
    func toggleChanged() {
        selectionChanged()
    }
    
    /// Timer warning (low time)
    func timerWarning() {
        warning()
    }
    
    /// Gravity direction changed
    func gravityChanged() {
        rigidImpact()
    }
    
    /// Portal entered
    func portalEntered() {
        softImpact()
    }
    
    /// Collectible picked up
    func collectiblePickup() {
        lightImpact()
    }
    
    /// Perfect timing hit
    func perfectHit() {
        mediumImpact()
    }
    
    /// Good timing hit
    func goodHit() {
        lightImpact()
    }
    
    /// Missed hit
    func missedHit() {
        error()
    }
}

// MARK: - SwiftUI View Extension for easy haptic access
extension View {
    /// Add haptic feedback to any view on tap
    func hapticOnTap(_ type: HapticType = .medium) -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded { _ in
                switch type {
                case .light: HapticsManager.shared.lightImpact()
                case .medium: HapticsManager.shared.mediumImpact()
                case .heavy: HapticsManager.shared.heavyImpact()
                case .success: HapticsManager.shared.success()
                case .error: HapticsManager.shared.error()
                case .warning: HapticsManager.shared.warning()
                case .selection: HapticsManager.shared.selectionChanged()
                }
            }
        )
    }
}

enum HapticType {
    case light
    case medium
    case heavy
    case success
    case error
    case warning
    case selection
}
