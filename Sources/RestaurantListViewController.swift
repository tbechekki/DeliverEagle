//
//  RestaurantListViewController.swift
//  DeliverEagle
//
//  Home tab: a list of restaurants. Tapping one opens its menu.
//

import UIKit

final class RestaurantListViewController: UITableViewController {

    private let restaurants = MockData.restaurants
    private let cellID = "RestaurantCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Restaurants"
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.rowHeight = 72
    }

    // MARK: - Table view

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        restaurants.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let restaurant = restaurants[indexPath.row]

        var content = UIListContentConfiguration.subtitleCell()
        content.text = restaurant.name
        content.textProperties.font = .preferredFont(forTextStyle: .headline)
        content.secondaryText = "\(restaurant.cuisine) · \(String(format: "%.1f", restaurant.distanceMiles)) mi · \(restaurant.deliveryMinutes) min"
        content.secondaryTextProperties.color = .secondaryLabel
        content.image = UIImage(systemName: restaurant.iconName)
        content.imageProperties.tintColor = .systemOrange
        content.imageProperties.maximumSize = CGSize(width: 40, height: 40)

        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let menuVC = MenuViewController(restaurant: restaurants[indexPath.row])
        navigationController?.pushViewController(menuVC, animated: true)
    }
}
