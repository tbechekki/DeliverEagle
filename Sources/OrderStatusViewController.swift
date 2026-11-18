//
//  OrderStatusViewController.swift
//  DeliverEagle
//
//  Orders tab: shows the current order moving through
//  Preparing -> On the way -> Delivered.
//

import UIKit

final class OrderStatusViewController: UIViewController {

    private let stackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Order Status"
        view.backgroundColor = .systemBackground

        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24)
        ])

        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: .orderDidChange, object: nil)
        refresh()
    }

    // MARK: - Building the screen

    @objc private func refresh() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        guard let order = CartStore.shared.currentOrder else {
            stackView.addArrangedSubview(makeLabel("No current order", style: .title2))
            stackView.addArrangedSubview(makeLabel("Place an order from your cart to track it here.", style: .body, color: .secondaryLabel))
            return
        }

        let heading = order.status == .delivered ? "Enjoy your food!" : "Order placed!"
        stackView.addArrangedSubview(makeLabel(heading, style: .title1))
        stackView.addArrangedSubview(makeLabel("Order #\(order.number) · \(order.restaurantName)", style: .headline))

        let itemSummary = order.items.map { "\($0.quantity)× \($0.item.name)" }.joined(separator: "\n")
        stackView.addArrangedSubview(makeLabel(itemSummary, style: .body, color: .secondaryLabel))
        stackView.addArrangedSubview(makeLabel("Total: \(order.total.asPrice)", style: .body))

        stackView.setCustomSpacing(28, after: stackView.arrangedSubviews.last!)

        for status in OrderStatus.allCases {
            stackView.addArrangedSubview(makeStatusRow(for: status, current: order.status))
        }

        if let lastRow = stackView.arrangedSubviews.last {
            stackView.setCustomSpacing(32, after: lastRow)
        }

        var config = UIButton.Configuration.filled()
        config.title = "Done"
        config.cornerStyle = .large
        config.baseBackgroundColor = .systemOrange
        let doneButton = UIButton(configuration: config)
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        doneButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        stackView.addArrangedSubview(doneButton)
    }

    private func makeStatusRow(for status: OrderStatus, current: OrderStatus) -> UIView {
        let reached = status.rawValue <= current.rawValue

        let icon = UIImageView(image: UIImage(systemName: reached ? "checkmark.circle.fill" : "circle"))
        icon.tintColor = reached ? .systemOrange : .tertiaryLabel
        icon.setContentHuggingPriority(.required, for: .horizontal)

        let label = makeLabel(status.title, style: .body, color: reached ? .label : .secondaryLabel)
        if status == current {
            label.font = .preferredFont(forTextStyle: .headline)
        }

        let row = UIStackView(arrangedSubviews: [icon, label])
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .center
        return row
    }

    private func makeLabel(_ text: String, style: UIFont.TextStyle, color: UIColor = .label) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: style)
        label.textColor = color
        label.numberOfLines = 0
        return label
    }

    // MARK: - Actions

    @objc private func doneTapped() {
        CartStore.shared.finishOrder()
        tabBarController?.selectedIndex = MainTabBarController.homeTab
    }
}
