//
//  ShopView.swift
//  DF764
//

import SwiftUI

struct ShopView: View {
    @EnvironmentObject var appState2: AppState2
    @Environment(\.dismiss) var dismiss
    @State private var selectedCategory: ShopItemType = .avatar
    @State private var showPurchaseConfirmation: ShopItem?
    @State private var showPurchaseSuccess = false
    @State private var purchasedItemName = ""
    
    var filteredItems: [ShopItem] {
        ShopItem.allItems.filter { $0.type == selectedCategory }
    }
    
    var body: some View {
        ZStack {
            Color("PrimaryBackground")
                .ignoresSafeArea()
            
            // Background gradients
            GeometryReader { geometry in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.purple.opacity(0.15),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: geometry.size.width * 0.5
                        )
                    )
                    .frame(width: geometry.size.width, height: geometry.size.width)
                    .offset(x: -geometry.size.width * 0.2, y: -geometry.size.height * 0.1)
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color("HighlightTone").opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: geometry.size.width * 0.4
                        )
                    )
                    .frame(width: geometry.size.width * 0.8, height: geometry.size.width * 0.8)
                    .offset(x: geometry.size.width * 0.4, y: geometry.size.height * 0.5)
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
                    
                    Text("Shop")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Shard counter
                    HStack(spacing: 6) {
                        Image(systemName: "diamond.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color("HighlightTone"))
                        Text("\(appState2.shards)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                    )
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                // Category tabs
                HStack(spacing: 0) {
                    ForEach([ShopItemType.avatar, .theme, .booster], id: \.self) { category in
                        CategoryTab(
                            category: category,
                            isSelected: selectedCategory == category,
                            onTap: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedCategory = category
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                
                ScrollView(showsIndicators: false) {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 14),
                            GridItem(.flexible(), spacing: 14)
                        ],
                        spacing: 14
                    ) {
                        ForEach(filteredItems) { item in
                            ShopItemCard(
                                item: item,
                                isPurchased: appState2.isItemPurchased(item.id),
                                canAfford: appState2.shards >= item.price,
                                onTap: {
                                    if !appState2.isItemPurchased(item.id) {
                                        showPurchaseConfirmation = item
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            
            // Purchase confirmation
            if let item = showPurchaseConfirmation {
                PurchaseConfirmationOverlay(
                    item: item,
                    canAfford: appState2.shards >= item.price,
                    onConfirm: {
                        if appState2.purchaseItem(item) {
                            purchasedItemName = item.name
                            showPurchaseConfirmation = nil
                            showPurchaseSuccess = true
                        }
                    },
                    onCancel: {
                        showPurchaseConfirmation = nil
                    }
                )
            }
            
            // Success overlay
            if showPurchaseSuccess {
                PurchaseSuccessOverlay(
                    itemName: purchasedItemName,
                    onDismiss: {
                        showPurchaseSuccess = false
                    }
                )
            }
        }
    }
}

struct CategoryTab: View {
    let category: ShopItemType
    let isSelected: Bool
    let onTap: () -> Void
    
    var categoryName: String {
        switch category {
        case .avatar: return "Avatars"
        case .theme: return "Themes"
        case .booster: return "Boosters"
        }
    }
    
    var categoryIcon: String {
        switch category {
        case .avatar: return "person.circle.fill"
        case .theme: return "paintpalette.fill"
        case .booster: return "bolt.circle.fill"
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: categoryIcon)
                        .font(.system(size: 14))
                    Text(categoryName)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
                .foregroundColor(isSelected ? Color("AccentGlow") : Color.white.opacity(0.5))
                
                Rectangle()
                    .fill(isSelected ? Color("AccentGlow") : Color.clear)
                    .frame(height: 2)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct ShopItemCard: View {
    let item: ShopItem
    let isPurchased: Bool
    let canAfford: Bool
    let onTap: () -> Void
    
    private var itemColor: Color {
        switch item.type {
        case .avatar: return Color.purple
        case .theme: return Color.cyan
        case .booster: return Color.orange
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    itemColor.opacity(0.3),
                                    itemColor.opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 40
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: item.icon)
                        .font(.system(size: 32))
                        .foregroundColor(isPurchased ? Color.green : itemColor)
                    
                    if isPurchased {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .offset(x: 28, y: -28)
                    }
                }
                
                VStack(spacing: 4) {
                    Text(item.name)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(item.description)
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.5))
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
                
                // Price
                if isPurchased {
                    Text("Owned")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.green.opacity(0.15))
                        )
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "diamond.fill")
                            .font(.system(size: 12))
                            .foregroundColor(canAfford ? Color("HighlightTone") : Color.red)
                        Text("\(item.price)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(canAfford ? Color("HighlightTone") : Color.red)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(canAfford ? Color("HighlightTone").opacity(0.15) : Color.red.opacity(0.15))
                    )
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isPurchased ? Color.green.opacity(0.3) :
                                (canAfford ? itemColor.opacity(0.3) : Color.white.opacity(0.1)),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isPurchased)
    }
}

struct PurchaseConfirmationOverlay: View {
    let item: ShopItem
    let canAfford: Bool
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    private var itemColor: Color {
        switch item.type {
        case .avatar: return Color.purple
        case .theme: return Color.cyan
        case .booster: return Color.orange
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }
            
            VStack(spacing: 24) {
                // Item preview
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    itemColor.opacity(0.4),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: item.icon)
                        .font(.system(size: 50))
                        .foregroundColor(itemColor)
                }
                
                VStack(spacing: 8) {
                    Text(item.name)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(item.description)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                
                // Price
                HStack(spacing: 8) {
                    Image(systemName: "diamond.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color("HighlightTone"))
                    
                    Text("\(item.price) Shards")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(Color("HighlightTone"))
                }
                
                if !canAfford {
                    Text("Not enough shards!")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.red)
                }
                
                VStack(spacing: 12) {
                    Button(action: onConfirm) {
                        Text("Purchase")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(canAfford ? itemColor : Color.gray)
                            )
                    }
                    .disabled(!canAfford)
                    
                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(Color.white.opacity(0.7))
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color("PrimaryBackground"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(itemColor.opacity(0.3), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 32)
        }
    }
}

struct PurchaseSuccessOverlay: View {
    let itemName: String
    let onDismiss: () -> Void
    
    @State private var animate = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.green.opacity(0.4),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(animate ? 1.1 : 1.0)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                        .scaleEffect(animate ? 1 : 0)
                }
                
                VStack(spacing: 8) {
                    Text("Purchase Complete!")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(itemName)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.7))
                }
                
                Button(action: onDismiss) {
                    Text("Continue")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.green)
                        )
                }
                .padding(.horizontal, 40)
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color("PrimaryBackground"))
            )
            .padding(.horizontal, 32)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                animate = true
            }
        }
    }
}

#Preview {
    ShopView()
        .environmentObject(AppState2())
}
