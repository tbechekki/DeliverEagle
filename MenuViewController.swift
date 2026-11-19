//
//  MenuViewController.swift
//  DeliverEagle
//
//  Shows one restaurant's menu under a restaurant image banner.
//  Tap + (or the row) to add an item to the cart. Items with sizes show S / M / L choices.
//  The layout lives in Main.storyboard.
//

import UIKit

final class MenuViewController: UITableViewController {

    private let restaurant: Restaurant

    /// The size picked for each menu row that has sizes, keyed by row index.
    private var selectedSizes: [Int: Int] = [:]

    /// One MenuItem per size (e.g. "Soft Drink (M)"), created once so each size keeps a stable
    /// id and adding the same size twice increases its quantity in the cart.
    private lazy var sizedItems: [Int: [MenuItem]] = {
        var result: [Int: [MenuItem]] = [:]
        for (index, item) in restaurant.menu.enumerated() where !item.sizes.isEmpty {
            result[index] = item.sizes.map { MenuItem(name: "\(item.name) (\($0.name))", price: $0.price) }
        }
        return result
    }()

    @IBOutlet private weak var bannerImageView: UIImageView!
    @IBOutlet private weak var bannerInfoLabel: UILabel!
    @IBOutlet private weak var cartButton: UIBarButtonItem!

    /// Created by the storyboard segue in RestaurantListViewController.
    init?(coder: NSCoder, restaurant: Restaurant) {
        self.restaurant = restaurant
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("Use init(coder:restaurant:) so the menu knows which restaurant to show")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = restaurant.name
        navigationItem.backButtonDisplayMode = .minimal

        // The "restaurant image" banner: the logo, or the SF Symbol as a placeholder.
        if let logo = restaurant.logo {
            bannerImageView.image = logo
            bannerImageView.contentMode = .scaleAspectFill
            bannerImageView.layer.cornerRadius = 16
        } else {
            bannerImageView.image = UIImage(systemName: restaurant.iconName)
        }
        bannerImageView.accessibilityLabel = "\(restaurant.name) image"
        bannerInfoLabel.text = "\(restaurant.cuisine) · \(String(format: "%.1f", restaurant.distanceMiles)) mi · \(restaurant.deliveryMinutes) min"

        NotificationCenter.default.addObserver(self, selector: #selector(updateCartButton), name: .cartDidChange, object: nil)
        updateCartButton()
    }

    // MARK: - Cart button

    /// The button itself opens the cart through a storyboard segue.
    @objc private func updateCartButton() {
        let count = CartStore.shared.itemCount
        cartButton.title = count > 0 ? "View Cart (\(count))" : "View Cart"
    }

    // MARK: - Adding items

    /// The item that goes in the cart for a row, including the picked size if it has sizes.
    private func cartItem(at index: Int) -> MenuItem {
        if let sizes = sizedItems[index] {
            return sizes[selectedSizes[index] ?? 0]
        }
        return restaurant.menu[index]
    }

    private func addItem(at index: Int) {
        let item = cartItem(at: index)
        let cart = CartStore.shared

        if cart.canAdd(from: restaurant) {
            cart.add(item, from: restaurant)
            return
        }

        // The cart already has food from a different restaurant.
        let alert = UIAlertController(
            title: "Start a new cart?",
            message: "Your cart has items from \(cart.restaurantName ?? "another restaurant"). Adding this item will clear them.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "New Cart", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            cart.add(item, from: self.restaurant)
        })
        present(alert, animated: true)
    }

    // MARK: - Table view

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        restaurant.menu.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MenuItemCell.reuseID, for: indexPath) as! MenuItemCell
        let index = indexPath.row

        cell.configure(with: restaurant.menu[index], selectedSize: selectedSizes[index] ?? 0)
        cell.onAdd = { [weak self] in
            self?.addItem(at: index)
        }
        cell.onSizeChange = { [weak self] sizeIndex in
            self?.selectedSizes[index] = sizeIndex
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        addItem(at: indexPath.row)
    }
}

// MARK: - Menu item cell

/// A row from the wireframe: name on the left, price and a + button on the right,
/// with size choices underneath for items that have them.
/// The prototype for this cell is in Main.storyboard.
final class MenuItemCell: UITableViewCell {

    static let reuseID = "MenuItemCell"

    var onAdd: (() -> Void)?
    var onSizeChange: ((Int) -> Void)?

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var sizeControl: UISegmentedControl!

    override func awakeFromNib() {
        super.awakeFromNib()
        addButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(textStyle: .title2), forImageIn: .normal)
    }

    private var item: MenuItem?

    func configure(with item: MenuItem, selectedSize: Int) {
        self.item = item
        nameLabel.text = item.name
        addButton.accessibilityLabel = "Add \(item.name)"

        // The storyboard shows placeholder S / M / L segments; rebuild them from the item.
        sizeControl.removeAllSegments()
        for (index, size) in item.sizes.enumerated() {
            sizeControl.insertSegment(withTitle: size.name, at: index, animated: false)
        }
        sizeControl.isHidden = item.sizes.isEmpty
        if !item.sizes.isEmpty {
            sizeControl.selectedSegmentIndex = selectedSize
        }
        updatePrice()
    }

    /// Shows the price of the picked size, or the item's price if it has no sizes.
    private func updatePrice() {
        guard let item else { return }
        let index = sizeControl.selectedSegmentIndex
        let price = item.sizes.indices.contains(index) ? item.sizes[index].price : item.price
        priceLabel.text = price.asPrice
    }

    @IBAction private func addTapped() {
        onAdd?()
    }

    @IBAction private func sizeChanged() {
        updatePrice()
        onSizeChange?(sizeControl.selectedSegmentIndex)
    }
}
