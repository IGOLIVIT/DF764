//
//  AnimationSettings.swift
//  DF764
//

import SwiftUI

/// Global animation settings that respect user preferences
struct AnimationSettings {
    static var isReducedMotion: Bool {
        // Check both system setting and app setting
        let systemReducedMotion = UIAccessibility.isReduceMotionEnabled
        // App setting can be checked via AppState if needed
        return systemReducedMotion
    }
    
    /// Standard animation duration
    static var standardDuration: Double {
        isReducedMotion ? 0.1 : 0.3
    }
    
    /// Quick animation duration
    static var quickDuration: Double {
        isReducedMotion ? 0.05 : 0.15
    }
    
    /// Slow animation duration
    static var slowDuration: Double {
        isReducedMotion ? 0.2 : 0.5
    }
    
    /// Standard spring animation
    static var standardSpring: Animation {
        isReducedMotion ? .linear(duration: 0.1) : .spring(response: 0.4, dampingFraction: 0.7)
    }
    
    /// Bouncy spring animation
    static var bouncySpring: Animation {
        isReducedMotion ? .linear(duration: 0.1) : .spring(response: 0.5, dampingFraction: 0.5)
    }
    
    /// Ease out animation
    static var easeOut: Animation {
        isReducedMotion ? .linear(duration: 0.1) : .easeOut(duration: 0.3)
    }
    
    /// Ease in out animation
    static var easeInOut: Animation {
        isReducedMotion ? .linear(duration: 0.1) : .easeInOut(duration: 0.3)
    }
}

/// View modifier that respects reduced motion setting
struct ReducedMotionModifier: ViewModifier {
    let animation: Animation
    let reducedAnimation: Animation
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    func body(content: Content) -> some View {
        content
            .animation(reduceMotion ? reducedAnimation : animation, value: UUID())
    }
}

/// View extension for reduced motion aware animations
extension View {
    /// Apply animation that respects reduced motion preference
    func animationRespectingReducedMotion(_ animation: Animation, reduced: Animation = .linear(duration: 0.1)) -> some View {
        modifier(ReducedMotionModifier(animation: animation, reducedAnimation: reduced))
    }
    
    /// Conditionally apply animation based on reduced motion
    @ViewBuilder
    func conditionalAnimation<V: Equatable>(_ animation: Animation?, value: V) -> some View {
        if AnimationSettings.isReducedMotion {
            self.animation(.linear(duration: 0.05), value: value)
        } else {
            self.animation(animation, value: value)
        }
    }
    
    /// Apply scale effect only if reduced motion is disabled
    @ViewBuilder
    func conditionalScaleEffect(_ scale: CGFloat) -> some View {
        if AnimationSettings.isReducedMotion {
            self
        } else {
            self.scaleEffect(scale)
        }
    }
    
    /// Apply rotation effect only if reduced motion is disabled
    @ViewBuilder
    func conditionalRotationEffect(_ angle: Angle) -> some View {
        if AnimationSettings.isReducedMotion {
            self
        } else {
            self.rotationEffect(angle)
        }
    }
    
    /// Apply offset only if reduced motion is disabled
    @ViewBuilder
    func conditionalOffset(x: CGFloat = 0, y: CGFloat = 0) -> some View {
        if AnimationSettings.isReducedMotion {
            self
        } else {
            self.offset(x: x, y: y)
        }
    }
}

/// Pulsing animation that respects reduced motion
struct PulsingEffect: ViewModifier {
    @State private var isPulsing = false
    let isActive: Bool
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isActive && !AnimationSettings.isReducedMotion && isPulsing ? 1.05 : 1.0)
            .animation(
                isActive && !AnimationSettings.isReducedMotion ?
                    .easeInOut(duration: 1.0).repeatForever(autoreverses: true) :
                    .default,
                value: isPulsing
            )
            .onAppear {
                if isActive && !AnimationSettings.isReducedMotion {
                    isPulsing = true
                }
            }
    }
}

extension View {
    func pulsing(isActive: Bool = true) -> some View {
        modifier(PulsingEffect(isActive: isActive))
    }
}

/// Floating animation that respects reduced motion
struct FloatingEffect: ViewModifier {
    @State private var offset: CGFloat = 0
    let amplitude: CGFloat
    let duration: Double
    
    func body(content: Content) -> some View {
        content
            .offset(y: AnimationSettings.isReducedMotion ? 0 : offset)
            .onAppear {
                if !AnimationSettings.isReducedMotion {
                    withAnimation(
                        .easeInOut(duration: duration)
                        .repeatForever(autoreverses: true)
                    ) {
                        offset = amplitude
                    }
                }
            }
    }
}

extension View {
    func floating(amplitude: CGFloat = 5, duration: Double = 2.0) -> some View {
        modifier(FloatingEffect(amplitude: amplitude, duration: duration))
    }
}

/// Shimmering effect that respects reduced motion
struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    let isActive: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        .clear,
                        Color.white.opacity(0.3),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .mask(content)
                .offset(x: phase)
                .opacity(isActive && !AnimationSettings.isReducedMotion ? 1 : 0)
            )
            .onAppear {
                if isActive && !AnimationSettings.isReducedMotion {
                    withAnimation(
                        .linear(duration: 2.0)
                        .repeatForever(autoreverses: false)
                    ) {
                        phase = 200
                    }
                }
            }
    }
}

extension View {
    func shimmer(isActive: Bool = true) -> some View {
        modifier(ShimmerEffect(isActive: isActive))
    }
}
