//
//  CartStore.swift
//  DeliverEagle
//
//  One shared object that holds the cart and the current order.
//  Screens listen for the notifications below to know when to refresh.
//

import Foundation

extension Notification.Name {
    static let cartDidChange = Notification.Name("cartDidChange")
    static let orderDidChange = Notification.Name("orderDidChange")
}

final class CartStore: NSObject {
    static let shared = CartStore()
    private override init() {
        super.init()
    }

    static let deliveryFee = 3.00
    /// How often the simulated order moves to the next status.
    static let statusUpdateSeconds: TimeInterval = 10

    private(set) var restaurantName: String?
    private(set) var items: [CartItem] = []
    private(set) var currentOrder: Order?
    private var statusTimer: Timer?

    // MARK: - Cart totals

    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    var subtotal: Double {
        items.reduce(0) { $0 + $1.lineTotal }
    }

    var total: Double {
        items.isEmpty ? 0 : subtotal + CartStore.deliveryFee
    }

    // MARK: - Changing the cart

    /// A cart can only hold items from one restaurant at a time.
    func canAdd(from restaurant: Restaurant) -> Bool {
        restaurantName == nil || restaurantName == restaurant.name
    }

    func add(_ item: MenuItem, from restaurant: Restaurant) {
        if !canAdd(from: restaurant) {
            items.removeAll()
        }
        restaurantName = restaurant.name

        if let index = items.firstIndex(where: { $0.item.id == item.id }) {
            items[index].quantity += 1
        } else {
            items.append(CartItem(item: item, quantity: 1))
        }
        notifyCartChanged()
    }

    func setQuantity(_ quantity: Int, at index: Int) {
        guard items.indices.contains(index) else { return }

        if quantity <= 0 {
            items.remove(at: index)
        } else {
            items[index].quantity = quantity
        }
        if items.isEmpty {
            restaurantName = nil
        }
        notifyCartChanged()
    }

    func clearCart() {
        items.removeAll()
        restaurantName = nil
        notifyCartChanged()
    }

    // MARK: - Orders

    /// Turns the cart into an order (simulated checkout, no real payment).
    @discardableResult
    func placeOrder() -> Order? {
        guard let name = restaurantName, !items.isEmpty else { return nil }

        let order = Order(
            number: Int.random(in: 1000...9999),
            restaurantName: name,
            items: items,
            total: total,
            status: .preparing
        )
        currentOrder = order
        clearCart()
        notifyOrderChanged()
        startStatusUpdates()
        return order
    }

    /// Called when the user taps Done on the Order Status screen.
    func finishOrder() {
        statusTimer?.invalidate()
        statusTimer = nil
        currentOrder = nil
        notifyOrderChanged()
    }

    /// Moves the order from Preparing -> On the way -> Delivered on a timer.
    private func startStatusUpdates() {
        statusTimer?.invalidate()
        statusTimer = Timer.scheduledTimer(
            timeInterval: CartStore.statusUpdateSeconds,
            target: self,
            selector: #selector(advanceOrderStatus),
            userInfo: nil,
            repeats: true
        )
    }

    @objc private func advanceOrderStatus() {
        guard var order = currentOrder,
              let nextStatus = OrderStatus(rawValue: order.status.rawValue + 1) else {
            statusTimer?.invalidate()
            statusTimer = nil
            return
        }
        order.status = nextStatus
        currentOrder = order
        notifyOrderChanged()

        if nextStatus == .delivered {
            statusTimer?.invalidate()
            statusTimer = nil
        }
    }

    // MARK: - Notifications

    private func notifyCartChanged() {
        NotificationCenter.default.post(name: .cartDidChange, object: nil)
    }

    private func notifyOrderChanged() {
        NotificationCenter.default.post(name: .orderDidChange, object: nil)
    }
}
