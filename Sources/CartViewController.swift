//
//  CartViewController.swift
//  DeliverEagle
//
//  Cart tab (also opened from a menu's "View Cart" button).
//  Change quantities with the steppers, see the total, and place the order.
//

import UIKit

final class CartViewController: UITableViewController {

    private let cellID = "CartCell"
    private let itemsSection = 0
    private let totalsSection = 1

    private let placeOrderButton = UIButton(type: .system)
    private let emptyLabel = UILabel()

    init() {
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cart"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setUpFooter()
        setUpEmptyState()

        NotificationCenter.default.addObserver(self, selector: #selector(cartChanged), name: .cartDidChange, object: nil)
        cartChanged()
    }

    // MARK: - Setup

    private func setUpFooter() {
        var config = UIButton.Configuration.filled()
        config.title = "Place Order"
        config.cornerStyle = .large
        config.baseBackgroundColor = .systemOrange
        placeOrderButton.configuration = config
        placeOrderButton.addTarget(self, action: #selector(placeOrderTapped), for: .touchUpInside)
        placeOrderButton.translatesAutoresizingMaskIntoConstraints = false

        let footer = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 80))
        footer.addSubview(placeOrderButton)
        NSLayoutConstraint.activate([
            placeOrderButton.leadingAnchor.constraint(equalTo: footer.leadingAnchor, constant: 20),
            placeOrderButton.trailingAnchor.constraint(equalTo: footer.trailingAnchor, constant: -20),
            placeOrderButton.centerYAnchor.constraint(equalTo: footer.centerYAnchor),
            placeOrderButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        tableView.tableFooterView = footer
    }

    private func setUpEmptyState() {
        emptyLabel.text = "Your cart is empty.\nAdd something from a restaurant's menu."
        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.font = .preferredFont(forTextStyle: .body)
    }

    // MARK: - Updates

    @objc private func cartChanged() {
        let isEmpty = CartStore.shared.items.isEmpty
        tableView.backgroundView = isEmpty ? emptyLabel : nil
        tableView.tableFooterView?.isHidden = isEmpty
        tableView.reloadData()
    }

    @objc private func stepperChanged(_ sender: UIStepper) {
        CartStore.shared.setQuantity(Int(sender.value), at: sender.tag)
    }

    @objc private func placeOrderTapped() {
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
        section == itemsSection ? CartStore.shared.restaurantName : "Summary"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == itemsSection ? CartStore.shared.items.count : 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        cell.selectionStyle = .none
        let cart = CartStore.shared

        if indexPath.section == itemsSection {
            let cartItem = cart.items[indexPath.row]

            var content = UIListContentConfiguration.subtitleCell()
            content.text = "\(cartItem.quantity)× \(cartItem.item.name)"
            content.secondaryText = cartItem.lineTotal.asPrice
            content.secondaryTextProperties.color = .secondaryLabel
            cell.contentConfiguration = content

            let stepper = UIStepper()
            stepper.minimumValue = 0
            stepper.maximumValue = 20
            stepper.value = Double(cartItem.quantity)
            stepper.tag = indexPath.row
            stepper.addTarget(self, action: #selector(stepperChanged(_:)), for: .valueChanged)
            cell.accessoryView = stepper
        } else {
            var content = UIListContentConfiguration.valueCell()
            switch indexPath.row {
            case 0:
                content.text = "Subtotal"
                content.secondaryText = cart.subtotal.asPrice
            case 1:
                content.text = "Delivery fee"
                content.secondaryText = CartStore.deliveryFee.asPrice
            default:
                content.text = "Total"
                content.secondaryText = cart.total.asPrice
                content.textProperties.font = .preferredFont(forTextStyle: .headline)
                content.secondaryTextProperties.font = .preferredFont(forTextStyle: .headline)
            }
            cell.contentConfiguration = content
            cell.accessoryView = nil
        }
        return cell
    }
}
