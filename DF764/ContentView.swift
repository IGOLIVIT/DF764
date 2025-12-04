//
//  ContentView.swift
//  DF764
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState()
    
    var body: some View {
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

#Preview {
    ContentView()
}
