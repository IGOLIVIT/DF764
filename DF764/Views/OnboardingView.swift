//
//  OnboardingView.swift
//  DF764
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState2: AppState2
    @State private var currentPage = 0
    @State private var animateElements = false
    @State private var showUsernameInput = false
    @State private var username = ""
    
    private let pages: [(title: String, description: String, icon: String)] = [
        ("Welcome to Shifting Horizons", "Explore dynamic worlds that react to your decisions.", "globe.americas.fill"),
        ("5 Unique Mini-Games", "Challenge yourself across layered mini-games with 60 levels.", "gamecontroller.fill"),
        ("Collect Shards & Achievements", "Advance through levels and earn unique rewards.", "diamond.fill"),
        ("Daily Challenges", "Complete daily challenges to maintain your streak.", "flame.fill"),
        ("Ready to Begin?", "Set your player name and start your journey!", "person.fill")
    ]
    
    var body: some View {
        ZStack {
            Color("PrimaryBackground")
                .ignoresSafeArea()
            
            // Animated background
            GeometryReader { geometry in
                ForEach(0..<5, id: \.self) { index in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    pageColor.opacity(0.1 - Double(index) * 0.02),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: CGFloat(100 + index * 50)
                            )
                        )
                        .frame(width: CGFloat(200 + index * 100), height: CGFloat(200 + index * 100))
                        .offset(
                            x: geometry.size.width * 0.5 - CGFloat(100 + index * 50),
                            y: geometry.size.height * 0.2 - CGFloat(100 + index * 50)
                        )
                        .scaleEffect(animateElements ? 1.05 : 1.0)
                }
            }
            
            VStack(spacing: 0) {
                Spacer()
                
                // Illustration
                ZStack {
                    // Background glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    pageColor.opacity(0.3),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .scaleEffect(animateElements ? 1.1 : 1.0)
                    
                    if currentPage < 4 {
                        GeometricIllustration(pageIndex: currentPage)
                            .frame(height: 200)
                    } else {
                        // Username input page
                        Image(systemName: pages[currentPage].icon)
                            .font(.system(size: 80))
                            .foregroundColor(pageColor)
                    }
                }
                .frame(height: 220)
                
                Spacer()
                    .frame(height: 30)
                
                // Title
                Text(pages[currentPage].title)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                
                Spacer()
                    .frame(height: 12)
                
                // Description text
                Text(pages[currentPage].description)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                // Username input for last page
                if currentPage == 4 {
                    VStack(spacing: 12) {
                        TextField("Enter your name", text: $username)
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(pageColor.opacity(0.5), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal, 40)
                        
                        Text("You can change this later in your profile")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(Color.white.opacity(0.4))
                    }
                    .padding(.top, 24)
                }
                
                Spacer()
                    .frame(height: 40)
                
                // Page indicators
                HStack(spacing: 10) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(currentPage == index ? pageColor : Color.white.opacity(0.3))
                            .frame(width: currentPage == index ? 24 : 8, height: 8)
                            .animation(.easeInOut(duration: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 32)
                
                // Navigation buttons
                VStack(spacing: 14) {
                    if currentPage < pages.count - 1 {
                        GlowingButton(title: "Continue") {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                currentPage += 1
                                animateElements = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.easeInOut(duration: 0.8)) {
                                    animateElements = true
                                }
                            }
                        }
                        
                        Button(action: {
                            appState2.hasCompletedOnboarding = true
                        }) {
                            Text("Skip")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(Color("HighlightTone").opacity(0.7))
                        }
                    } else {
                        GlowingButton(title: "Start Playing") {
                            if !username.isEmpty {
                                appState2.playerProfile.username = username
                            }
                            appState2.hasCompletedOnboarding = true
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                animateElements = true
            }
        }
    }
    
    private var pageColor: Color {
        switch currentPage {
        case 0: return Color("AccentGlow")
        case 1: return Color("HighlightTone")
        case 2: return Color.cyan
        case 3: return Color.orange
        case 4: return Color.purple
        default: return Color("AccentGlow")
        }
    }
}

struct GeometricIllustration: View {
    let pageIndex: Int
    
    var body: some View {
        ZStack {
            switch pageIndex {
            case 0:
                // Dynamic worlds - orbiting circles
                ZStack {
                    ForEach(0..<5, id: \.self) { index in
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color("AccentGlow").opacity(0.6),
                                        Color("HighlightTone").opacity(0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                            .frame(width: CGFloat(60 + index * 40), height: CGFloat(60 + index * 40))
                            .rotationEffect(.degrees(Double(index) * 15))
                    }
                    
                    // Center glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color("AccentGlow"),
                                    Color("AccentGlow").opacity(0.5),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 40
                            )
                        )
                        .frame(width: 80, height: 80)
                }
                
            case 1:
                // Mini-games - 5 game icons
                ZStack {
                    ForEach(0..<5, id: \.self) { index in
                        let angle = Double(index) * 72 - 90
                        let radius: CGFloat = 70
                        let icons = ["square.grid.3x3.fill", "arrow.left.arrow.right", "point.topleft.down.to.point.bottomright.curvepath.fill", "circle.dotted", "timer"]
                        let colors: [Color] = [Color("AccentGlow"), Color("HighlightTone"), .cyan, .purple, .mint]
                        
                        ZStack {
                            Circle()
                                .fill(colors[index].opacity(0.2))
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: icons[index])
                                .font(.system(size: 22))
                                .foregroundColor(colors[index])
                        }
                        .offset(
                            x: cos(angle * .pi / 180) * radius,
                            y: sin(angle * .pi / 180) * radius
                        )
                    }
                    
                    // Center gamecontroller
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color("HighlightTone"))
                }
                
            case 2:
                // Shards collection - scattered diamonds
                ZStack {
                    ForEach(0..<8, id: \.self) { index in
                        let angle = Double(index) * 45
                        let radius: CGFloat = index % 2 == 0 ? 90 : 60
                        
                        Image(systemName: "diamond.fill")
                            .font(.system(size: CGFloat(16 + (index % 3) * 8)))
                            .foregroundColor(
                                index % 2 == 0 ?
                                Color("AccentGlow") :
                                Color("HighlightTone")
                            )
                            .offset(
                                x: cos(angle * .pi / 180) * radius,
                                y: sin(angle * .pi / 180) * radius
                            )
                    }
                    
                    // Center large diamond
                    ZStack {
                        Image(systemName: "diamond.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color("HighlightTone"))
                            .blur(radius: 10)
                            .opacity(0.5)
                        
                        Image(systemName: "diamond.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color("HighlightTone"))
                    }
                }
                
            case 3:
                // Daily challenges - calendar with flame
                ZStack {
                    // Calendar background
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.orange.opacity(0.15))
                        .frame(width: 120, height: 120)
                    
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.orange.opacity(0.4), lineWidth: 2)
                        .frame(width: 120, height: 120)
                    
                    VStack(spacing: 8) {
                        // Day indicators
                        HStack(spacing: 6) {
                            ForEach(0..<7, id: \.self) { day in
                                Circle()
                                    .fill(day < 5 ? Color.orange : Color.white.opacity(0.2))
                                    .frame(width: 10, height: 10)
                            }
                        }
                        
                        Image(systemName: "flame.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                    }
                    
                    // Streak number
                    Text("5")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .offset(x: 45, y: -45)
                        .background(
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 30, height: 30)
                                .offset(x: 45, y: -45)
                        )
                }
                
            default:
                EmptyView()
            }
        }
    }
}

struct HexagonShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3 - .pi / 2
            let point = CGPoint(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            )
            
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppState2())
}
