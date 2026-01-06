//
//  ContentView.swift
//  DF764
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    
    @StateObject private var notificationService = NotificationService.shared
    @AppStorage("onboarding_completed") private var onboardingCompleted = false
    
    @StateObject private var appState = AppState()
    @StateObject private var network = NetworkMonitor.shared
    
    @StateObject private var appState2 = AppState2()
    
    var body: some View {
        ZStack {
            
            Group {
                switch appState.mode {
                case .none:
                    ProgressView()
                case .some(.white):
                    ZStack {
                        
                        Group {
                            if appState2.hasCompletedOnboarding {
                                HomeView()
                                    .environmentObject(appState2)
                                    .transition(.opacity)
                            } else {
                                OnboardingView()
                                    .environmentObject(appState2)
                                    .transition(.opacity)
                            }
                        }
                        .animation(.easeInOut(duration: 0.4), value: appState2.hasCompletedOnboarding)
                    }
                case .some(.grey):
                    
                    if let url = appState.savedGreyURL {
                        WebContainerView(initialURL: url) // из WebView слоя
                    } else {
                        ZStack {
                            
                            Group {
                                if appState2.hasCompletedOnboarding {
                                    HomeView()
                                        .environmentObject(appState2)
                                        .transition(.opacity)
                                } else {
                                    OnboardingView()
                                        .environmentObject(appState2)
                                        .transition(.opacity)
                                }
                            }
                            .animation(.easeInOut(duration: 0.4), value: appState2.hasCompletedOnboarding)
                        }
                    }
                }
            }
            .alert("No connection to internet",
                   isPresented: $appState.showNoInternetAlertForGrey) {
                Button("Open settings") { appState.openSettings() }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("To continue: turn on celullar data and come back to app")
            }
        }
        .onAppear {
            appState.bootstrap()
            
            // Обновляем статус разрешений при появлении экрана
            notificationService.updatePermissionStatus()
            
            // Логируем Player ID для отладки с задержкой
            Task {
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 секунды
                
                await MainActor.run {
                    if let playerId = notificationService.currentPlayerId {
                        print("🔔 Current OneSignal Player ID: \(playerId)")
                    } else {
                        print("🔔 OneSignal Player ID еще не доступен")
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
