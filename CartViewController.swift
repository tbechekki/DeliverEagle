//
//  CartViewController.swift
//  DeliverEagle
//
//  Cart tab (also opened from a menu's "View Cart" button).
//  Change quantities with the − / + buttons, see the total, and place the order.
//  The layout lives in Main.storyboard.
//

import UIKit

final class CartViewController: UITableViewController {

    private let itemsSection = 0
    private let totalsSection = 1

    private let emptyLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpEmptyState()

        NotificationCenter.default.addObserver(self, selector: #selector(cartChanged), name: .cartDidChange, object: nil)
        cartChanged()
    }

    // MARK: - Setup

    private func setUpEmptyState() {
        emptyLabel.text = "Your cart is empty.\nAdd something from a restaurant's menu."
        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.font = .preferredFont(forTextStyle: .body)
        emptyLabel.adjustsFontForContentSizeCategory = true
    }

    // MARK: - Updates

    @objc private func cartChanged() {
        let isEmpty = CartStore.shared.items.isEmpty
        tableView.backgroundView = isEmpty ? emptyLabel : nil
        tableView.tableFooterView?.isHidden = isEmpty
        tableView.reloadData()
    }

    private func changeQuantity(at index: Int, by amount: Int) {
        let cart = CartStore.shared
        guard cart.items.indices.contains(index) else { return }
        cart.setQuantity(cart.items[index].quantity + amount, at: index)
    }

    /// The "Order" button under the total.
    @IBAction private func placeOrderTapped() {
        guard CartStore.shared.placeOrder() != nil else { return }

        // Go back to the start of this tab, then jump to the Orders tab.
        navigationController?.popToRootViewController(animated: false)
        tabBarController?.selectedIndex = MainTabBarController.ordersTab
    }

    // MARK: - Table view

    override func numberOfSections(in tableView: UITableView) -> Int {
        CartStore.shared.items.isEmpty ? 0 : 2
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == itemsSection ? CartStore.shared.restaurantName : nil
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == itemsSection ? CartStore.shared.items.count : 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cart = CartStore.shared

        if indexPath.section == itemsSection {
            let cell = tableView.dequeueReusableCell(withIdentifier: CartItemCell.reuseID, for: indexPath) as! CartItemCell
            let index = indexPath.row
            cell.configure(with: cart.items[index])
            cell.onDecrement = { [weak self] in self?.changeQuantity(at: index, by: -1) }
            cell.onIncrement = { [weak self] in self?.changeQuantity(at: index, by: 1) }
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: TotalCell.reuseID, for: indexPath) as! TotalCell
        cell.configure(subtotal: cart.subtotal, deliveryFee: CartStore.deliveryFee, total: cart.total)
        return cell
    }
}

// MARK: - Cart item cell

/// A row from the wireframe: name and price on top, "− 2 +" underneath on the right.
/// The prototype for this cell is in Main.storyboard.
final class CartItemCell: UITableViewCell {

    static let reuseID = "CartItemCell"

    var onDecrement: (() -> Void)?
    var onIncrement: (() -> Void)?

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var quantityLabel: UILabel!

    func configure(with cartItem: CartItem) {
        nameLabel.text = cartItem.item.name
        priceLabel.text = cartItem.lineTotal.asPrice
        quantityLabel.text = "\(cartItem.quantity)"
        quantityLabel.accessibilityLabel = "Quantity \(cartItem.quantity)"
    }

    @IBAction private func minusTapped() {
        onDecrement?()
    }

    @IBAction private func plusTapped() {
        onIncrement?()
    }
}

// MARK: - Total cell

/// "total: 6.28 + 3 delivery = 9.28" from the wireframe.
/// The prototype for this cell is in Main.storyboard.
final class TotalCell: UITableViewCell {

    static let reuseID = "TotalCell"

    @IBOutlet private weak var breakdownLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!

    func configure(subtotal: Double, deliveryFee: Double, total: Double) {
        breakdownLabel.text = "Total: \(subtotal.asPrice) + \(deliveryFee.asPrice) delivery"
        amountLabel.text = total.asPrice
    }
}
