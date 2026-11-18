//
//  MenuViewController.swift
//  DeliverEagle
//
//  Shows one restaurant's menu. Tap + (or the row) to add an item to the cart.
//

import UIKit

final class MenuViewController: UITableViewController {

    private let restaurant: Restaurant
    private let cellID = "MenuItemCell"

    init(restaurant: Restaurant) {
        self.restaurant = restaurant
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = restaurant.name
        navigationItem.largeTitleDisplayMode = .never
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.tableHeaderView = makeHeader()

        NotificationCenter.default.addObserver(self, selector: #selector(updateCartButton), name: .cartDidChange, object: nil)
        updateCartButton()
    }

    // MARK: - Header and cart button

    private func makeHeader() -> UIView {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 140))

        let imageView = UIImageView(image: UIImage(systemName: restaurant.iconName))
        imageView.tintColor = .systemOrange
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let infoLabel = UILabel()
        infoLabel.text = "\(restaurant.cuisine) · \(restaurant.deliveryMinutes) min delivery"
        infoLabel.font = .preferredFont(forTextStyle: .subheadline)
        infoLabel.textColor = .secondaryLabel
        infoLabel.translatesAutoresizingMaskIntoConstraints = false

        header.addSubview(imageView)
        header.addSubview(infoLabel)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: header.topAnchor, constant: 16),
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70),
            infoLabel.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            infoLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12)
        ])
        return header
    }

    @objc private func updateCartButton() {
        let count = CartStore.shared.itemCount
        let title = count > 0 ? "View Cart (\(count))" : "View Cart"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(viewCartTapped))
    }

    @objc private func viewCartTapped() {
        navigationController?.pushViewController(CartViewController(), animated: true)
    }

    // MARK: - Adding items

    @objc private func addButtonTapped(_ sender: UIButton) {
        addItem(at: sender.tag)
    }

    private func addItem(at index: Int) {
        let item = restaurant.menu[index]
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

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Menu"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let item = restaurant.menu[indexPath.row]

        var content = UIListContentConfiguration.subtitleCell()
        content.text = item.name
        content.secondaryText = item.price.asPrice
        content.secondaryTextProperties.color = .secondaryLabel
        cell.contentConfiguration = content

        let addButton = UIButton(type: .system)
        addButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        addButton.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        addButton.tag = indexPath.row
        addButton.addTarget(self, action: #selector(addButtonTapped(_:)), for: .touchUpInside)
        cell.accessoryView = addButton

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        addItem(at: indexPath.row)
    }
}
