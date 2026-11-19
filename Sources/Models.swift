//
//  Models.swift
//  DeliverEagle
//
//  The basic data types the app uses: restaurants, menu items, cart items, and orders.
//

import UIKit

struct MenuSize {
    let name: String   // e.g. "S"
    let price: Double
}

struct MenuItem {
    let id = UUID()
    let name: String
    let price: Double
    var sizes: [MenuSize] = []   // e.g. S / M / L for drinks; empty if the item has no sizes

    init(name: String, price: Double) {
        self.name = name
        self.price = price
    }

    /// An item that comes in sizes. Its base price is the first (smallest) size's price.
    init(name: String, sizes: [MenuSize]) {
        self.name = name
        self.price = sizes.first?.price ?? 0
        self.sizes = sizes
    }
}

struct Restaurant {
    let name: String
    let cuisine: String
    let distanceMiles: Double
    let deliveryMinutes: Int
    let iconName: String   // SF Symbol used as a placeholder image
    var logoName: String? = nil   // Logo in Assets.xcassets; falls back to iconName if missing
    let menu: [MenuItem]

    /// The restaurant's logo if it has one in the asset catalog.
    var logo: UIImage? {
        logoName.flatMap { UIImage(named: $0) }
    }
}

struct CartItem {
    let item: MenuItem
    var quantity: Int

    var lineTotal: Double {
        item.price * Double(quantity)
    }
}

enum OrderStatus: Int, CaseIterable {
    case preparing
    case onTheWay
    case delivered

    var title: String {
        switch self {
        case .preparing: return "Making"
        case .onTheWay: return "Out for delivery"
        case .delivered: return "Delivered"
        }
    }
}

struct Order {
    let number: Int
    let restaurantName: String
    let items: [CartItem]
    let total: Double
    var status: OrderStatus
}

extension Double {
    /// Formats a number as a price, e.g. 6.5 -> "$6.50"
    var asPrice: String {
        String(format: "$%.2f", self)
    }
}
