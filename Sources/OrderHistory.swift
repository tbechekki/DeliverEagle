//
//  OrderHistory.swift
//  DeliverEagle
//
//  Saves placed orders on the device with UserDefaults + Codable,
//  and shows them on the Past Orders screen (opened from Home).
//

import UIKit

/// A placed order, saved so it's still there after the app is closed.
struct PastOrder: Codable {
    let number: Int
    let restaurantName: String
    let itemSummary: String
    let total: Double
    let date: Date
}

enum OrderHistory {
    private static let key = "pastOrders"

    static func load() -> [PastOrder] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let orders = try? JSONDecoder().decode([PastOrder].self, from: data) else {
            return []
        }
        return orders
    }

    static func save(_ order: Order) {
        let summary = order.items.map { "\($0.quantity)× \($0.item.name)" }.joined(separator: ", ")
        let pastOrder = PastOrder(
            number: order.number,
            restaurantName: order.restaurantName,
            itemSummary: summary,
            total: order.total,
            date: Date()
        )

        var orders = load()
        orders.insert(pastOrder, at: 0)
        if let data = try? JSONEncoder().encode(orders) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

/// Lists saved orders, newest first.
final class PastOrdersViewController: UITableViewController {

    private var orders: [PastOrder] = []
    private let cellID = "PastOrderCell"

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Past Orders"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        orders = OrderHistory.load()
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        max(orders.count, 1)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        cell.selectionStyle = .none

        var content = UIListContentConfiguration.subtitleCell()
        if orders.isEmpty {
            content.text = "No past orders yet"
            content.secondaryText = "Orders you place will be saved here."
        } else {
            let order = orders[indexPath.row]
            content.text = "\(order.restaurantName) · \(order.total.asPrice)"
            content.secondaryText = "\(dateFormatter.string(from: order.date))\n\(order.itemSummary)"
            content.secondaryTextProperties.numberOfLines = 0
        }
        content.secondaryTextProperties.color = .secondaryLabel
        cell.contentConfiguration = content
        return cell
    }
}
