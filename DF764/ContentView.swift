//
//  ContentView.swift
//  DF764
//


import SwiftUI
import UserNotifications

struct ContentView: View {
    
    @StateObject private var appState = AppState()

//    @StateObject private var notificationService = NotificationService.shared
    @AppStorage("onboarding_completed") private var onboardingCompleted = false
    
    @StateObject private var appState2 = AppState2()
    @StateObject private var network = NetworkMonitor.shared
    
    var body: some View {
        ZStack {
            
            Group {
                switch appState2.mode {
                case .none:
                    ProgressView()
                case .some(.white):
                    ZStack {
                        
                        Group {
                            if appState.hasCompletedOnboarding {
                                HomeView()
                                    .environmentObject(appState)
                                    .transition(.opacity)
                            } else {
                                OnboardingView()
                                    .environmentObject(appState)
                                    .transition(.opacity)
                            }
                        }
                        .animation(.easeInOut(duration: 0.4), value: appState.hasCompletedOnboarding)
                    }
                case .some(.grey):
                    
                    if let url = appState2.savedGreyURL {
                        WebContainerView(initialURL: url) // из WebView слоя
                    } else {
                        ZStack {
                            
                            Group {
                                if appState.hasCompletedOnboarding {
                                    HomeView()
                                        .environmentObject(appState)
                                        .transition(.opacity)
                                } else {
                                    OnboardingView()
                                        .environmentObject(appState)
                                        .transition(.opacity)
                                }
                            }
                            .animation(.easeInOut(duration: 0.4), value: appState.hasCompletedOnboarding)
                        }
                    }
                }
            }
            .alert("No connection to internet",
                   isPresented: $appState2.showNoInternetAlertForGrey) {
                Button("Open settings") { appState2.openSettings() }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("To continue: turn on celullar data and come back to app")
            }
        }
        .onAppear {
            
            appState2.bootstrap()
        }
    }
}

#Preview {
    ContentView()
}
