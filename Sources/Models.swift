//
//  Models.swift
//  DeliverEagle
//
//  The basic data types the app uses: restaurants, menu items, cart items, and orders.
//

import Foundation

struct MenuItem {
    let id = UUID()
    let name: String
    let price: Double
}

struct Restaurant {
    let name: String
    let cuisine: String
    let distanceMiles: Double
    let deliveryMinutes: Int
    let iconName: String   // SF Symbol used as a placeholder image
    let menu: [MenuItem]
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
        case .preparing: return "Preparing"
        case .onTheWay: return "On the way"
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
