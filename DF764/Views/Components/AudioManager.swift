//
//  AudioManager.swift
//  DF764
//

import SwiftUI
import AVFoundation
import Combine

/// Singleton manager for audio playback throughout the app
class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    // Reference to app state - should be set on app launch
    weak var appState: AppState2?
    
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var soundEffectPlayers: [String: AVAudioPlayer] = [:]
    
    @Published var isMusicPlaying = false
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    // MARK: - Settings Checks
    
    private var isSoundEnabled: Bool {
        appState?.settings.soundEnabled ?? true
    }
    
    private var isMusicEnabled: Bool {
        appState?.settings.musicEnabled ?? true
    }
    
    // MARK: - Background Music
    
    /// Start playing background music
    func playBackgroundMusic(named filename: String = "background_music", withExtension ext: String = "mp3", volume: Float = 0.3) {
        guard isMusicEnabled else {
            stopBackgroundMusic()
            return
        }
        
        guard let url = Bundle.main.url(forResource: filename, withExtension: ext) else {
            // No music file bundled - this is expected if no audio files are included
            return
        }
        
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.numberOfLoops = -1 // Loop indefinitely
            backgroundMusicPlayer?.volume = volume
            backgroundMusicPlayer?.prepareToPlay()
            backgroundMusicPlayer?.play()
            isMusicPlaying = true
        } catch {
            print("Failed to play background music: \(error)")
        }
    }
    
    /// Stop background music
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
        backgroundMusicPlayer = nil
        isMusicPlaying = false
    }
    
    /// Pause background music
    func pauseBackgroundMusic() {
        backgroundMusicPlayer?.pause()
        isMusicPlaying = false
    }
    
    /// Resume background music
    func resumeBackgroundMusic() {
        guard isMusicEnabled else { return }
        backgroundMusicPlayer?.play()
        isMusicPlaying = true
    }
    
    /// Set background music volume
    func setMusicVolume(_ volume: Float) {
        backgroundMusicPlayer?.volume = max(0, min(1, volume))
    }
    
    /// Toggle background music based on settings
    func updateMusicState() {
        if isMusicEnabled && !isMusicPlaying {
            playBackgroundMusic()
        } else if !isMusicEnabled && isMusicPlaying {
            stopBackgroundMusic()
        }
    }
    
    // MARK: - Sound Effects
    
    /// Play a sound effect
    func playSoundEffect(named filename: String, withExtension ext: String = "wav", volume: Float = 1.0) {
        guard isSoundEnabled else { return }
        
        guard let url = Bundle.main.url(forResource: filename, withExtension: ext) else {
            // No sound file bundled - this is expected if no audio files are included
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = volume
            player.prepareToPlay()
            player.play()
            
            // Store reference to prevent deallocation
            soundEffectPlayers[filename] = player
            
            // Clean up after playing
            DispatchQueue.main.asyncAfter(deadline: .now() + player.duration + 0.1) { [weak self] in
                self?.soundEffectPlayers.removeValue(forKey: filename)
            }
        } catch {
            print("Failed to play sound effect: \(error)")
        }
    }
    
    // MARK: - Game Sound Effects
    // These methods will try to play sounds if files exist, otherwise they do nothing
    
    /// Button tap sound
    func playButtonTap() {
        playSoundEffect(named: "button_tap", volume: 0.5)
    }
    
    /// Success sound
    func playSuccess() {
        playSoundEffect(named: "success", volume: 0.7)
    }
    
    /// Error/wrong sound
    func playError() {
        playSoundEffect(named: "error", volume: 0.6)
    }
    
    /// Level complete sound
    func playLevelComplete() {
        playSoundEffect(named: "level_complete", volume: 0.8)
    }
    
    /// Achievement unlocked sound
    func playAchievementUnlocked() {
        playSoundEffect(named: "achievement", volume: 0.8)
    }
    
    /// Collectible pickup sound
    func playCollectible() {
        playSoundEffect(named: "collectible", volume: 0.5)
    }
    
    /// Combo sound
    func playCombo() {
        playSoundEffect(named: "combo", volume: 0.6)
    }
    
    /// Timer warning sound
    func playTimerWarning() {
        playSoundEffect(named: "timer_warning", volume: 0.5)
    }
    
    /// Tile tap sound
    func playTileTap() {
        playSoundEffect(named: "tile_tap", volume: 0.4)
    }
    
    /// Correct answer sound
    func playCorrect() {
        playSoundEffect(named: "correct", volume: 0.6)
    }
    
    /// Purchase sound
    func playPurchase() {
        playSoundEffect(named: "purchase", volume: 0.7)
    }
    
    /// Gravity change sound
    func playGravityChange() {
        playSoundEffect(named: "gravity_change", volume: 0.5)
    }
    
    /// Portal enter sound
    func playPortal() {
        playSoundEffect(named: "portal", volume: 0.6)
    }
    
    /// Perfect timing sound
    func playPerfect() {
        playSoundEffect(named: "perfect", volume: 0.7)
    }
    
    /// Miss sound
    func playMiss() {
        playSoundEffect(named: "miss", volume: 0.4)
    }
    
    /// Game start sound
    func playGameStart() {
        playSoundEffect(named: "game_start", volume: 0.6)
    }
    
    /// Countdown tick sound
    func playCountdownTick() {
        playSoundEffect(named: "tick", volume: 0.3)
    }
}

// MARK: - SwiftUI Environment Key
struct AudioManagerKey: EnvironmentKey {
    static let defaultValue = AudioManager.shared
}

extension EnvironmentValues {
    var audioManager: AudioManager {
        get { self[AudioManagerKey.self] }
        set { self[AudioManagerKey.self] = newValue }
    }
}
