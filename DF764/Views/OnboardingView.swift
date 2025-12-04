//
//  OnboardingView.swift
//  DF764
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentPage = 0
    
    private let pages: [(title: String, description: String)] = [
        ("", "Explore dynamic worlds that react to your decisions."),
        ("", "Challenge yourself across layered mini-games."),
        ("", "Advance through levels and earn unique Shards.")
    ]
    
    var body: some View {
        ZStack {
            Color("PrimaryBackground")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Abstract geometric illustration
                GeometricIllustration(pageIndex: currentPage)
                    .frame(height: 280)
                
                Spacer()
                    .frame(height: 40)
                
                // Description text
                Text(pages[currentPage].description)
                    .font(.system(size: 22, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                Spacer()
                    .frame(height: 60)
                
                // Page indicators
                HStack(spacing: 12) {
                    ForEach(0..<3, id: \.self) { index in
                        Capsule()
                            .fill(currentPage == index ? Color("AccentGlow") : Color.white.opacity(0.3))
                            .frame(width: currentPage == index ? 28 : 10, height: 10)
                    }
                }
                .padding(.bottom, 40)
                
                // Navigation buttons
                VStack(spacing: 16) {
                    if currentPage < 2 {
                        GlowingButton(title: "Continue") {
                            currentPage += 1
                        }
                        
                        Button(action: {
                            appState.hasCompletedOnboarding = true
                        }) {
                            Text("Skip")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color("HighlightTone").opacity(0.8))
                        }
                    } else {
                        GlowingButton(title: "Start") {
                            appState.hasCompletedOnboarding = true
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
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
                // Layered challenges - stacked hexagons
                ZStack {
                    ForEach(0..<4, id: \.self) { index in
                        HexagonShape()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color("AccentGlow").opacity(0.8 - Double(index) * 0.15),
                                        Color("HighlightTone").opacity(0.5 - Double(index) * 0.1)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 2.5
                            )
                            .frame(width: CGFloat(180 - index * 30), height: CGFloat(180 - index * 30))
                            .offset(y: CGFloat(index * 15))
                            .rotationEffect(.degrees(30))
                    }
                    
                    // Center diamond
                    Image(systemName: "diamond.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color("HighlightTone"))
                        .offset(y: 22)
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
        .environmentObject(AppState())
}
