//
//  OrderStatusViewController.swift
//  DeliverEagle
//
//  Orders tab (the "Confirmation" wireframe): "Order Placed!" and a vertical
//  timeline showing the order moving through Making -> Out for delivery -> Delivered.
//  The layout lives in Main.storyboard.
//

import UIKit

final class OrderStatusViewController: UIViewController {

    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var headingLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!
    @IBOutlet private weak var timelineView: UIStackView!
    @IBOutlet private weak var okButtonRow: UIView!

    // Storyboard outlet collections don't keep their order, so these are sorted by tag in viewDidLoad.
    /// One dot per OrderStatus, tagged 0, 1, 2.
    @IBOutlet private var dotViews: [UIView]!
    /// One label per OrderStatus, tagged 0, 1, 2.
    @IBOutlet private var stepLabels: [UILabel]!
    /// The lines leading into steps 1 and 2, tagged 1 and 2.
    @IBOutlet private var lineViews: [UIView]!

    /// Matches the dot size set in the storyboard.
    private let dotSize: CGFloat = 22

    override func viewDidLoad() {
        super.viewDidLoad()
        dotViews = dotViews.sorted { $0.tag < $1.tag }
        stepLabels = stepLabels.sorted { $0.tag < $1.tag }

        for dot in dotViews {
            dot.layer.cornerRadius = dotSize / 2
            dot.layer.borderWidth = 2
        }

        stackView.setCustomSpacing(40, after: detailLabel)
        stackView.setCustomSpacing(48, after: timelineView)

        // Re-apply the dot border colors, since CGColor doesn't update for dark mode by itself.
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (controller: OrderStatusViewController, _: UITraitCollection) in
            controller.refresh()
        }

        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: .orderDidChange, object: nil)
        refresh()
    }

    // MARK: - Updating the screen

    @objc private func refresh() {
        guard let order = CartStore.shared.currentOrder else {
            headingLabel.text = "No current order"
            detailLabel.text = "Place an order from your cart to track it here."
            timelineView.isHidden = true
            okButtonRow.isHidden = true
            return
        }

        headingLabel.text = order.status == .delivered ? "Enjoy your food!" : "Order Placed!"
        detailLabel.text = "Order #\(order.number) · \(order.restaurantName) · \(order.total.asPrice)"
        timelineView.isHidden = false
        okButtonRow.isHidden = false

        // Steps the order has reached are filled in orange; later steps are hollow and gray.
        for status in OrderStatus.allCases {
            let reached = status.rawValue <= order.status.rawValue
            let isCurrent = status == order.status

            let dot = dotViews[status.rawValue]
            dot.backgroundColor = reached ? .systemOrange : .clear
            dot.layer.borderColor = (reached ? UIColor.systemOrange : UIColor.tertiaryLabel).cgColor

            let label = stepLabels[status.rawValue]
            label.text = status.title
            label.font = .preferredFont(forTextStyle: isCurrent ? .headline : .body)
            label.textColor = reached ? .label : .secondaryLabel
            label.accessibilityValue = isCurrent ? "Current step" : (reached ? "Done" : "Not yet")
        }

        for line in lineViews {
            line.backgroundColor = line.tag <= order.status.rawValue ? .systemOrange : .tertiaryLabel
        }
    }

    // MARK: - Actions

    @IBAction private func okTapped() {
        CartStore.shared.finishOrder()
        tabBarController?.selectedIndex = MainTabBarController.homeTab
    }
}
