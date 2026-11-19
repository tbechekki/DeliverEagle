//
//  RestaurantListViewController.swift
//  DeliverEagle
//
//  Home tab: a location bar with search, then a list of restaurants.
//  Tapping one opens its menu. The layout lives in Main.storyboard.
//

import UIKit

final class RestaurantListViewController: UITableViewController {

    private let allRestaurants = MockData.restaurants
    private var restaurants = MockData.restaurants
    private let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        // The wireframe shows a plain "<" back button on the menu screen.
        navigationItem.backButtonDisplayMode = .minimal
        definesPresentationContext = true

        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search restaurants or cuisines"
    }

    // MARK: - Search and navigation

    /// The search bar stays hidden until the search button is tapped, like in the wireframe.
    @IBAction private func searchTapped() {
        navigationItem.searchController = searchController
        DispatchQueue.main.async {
            self.searchController.isActive = true
            self.searchController.searchBar.becomeFirstResponder()
        }
    }

    /// Called by the storyboard segue from a restaurant row, so the menu gets the restaurant that was tapped.
    @IBSegueAction func makeMenuViewController(_ coder: NSCoder, sender: Any?) -> MenuViewController? {
        guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) else { return nil }
        return MenuViewController(coder: coder, restaurant: restaurants[indexPath.row])
    }

    // MARK: - Table view

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        restaurants.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RestaurantCell.reuseID, for: indexPath) as! RestaurantCell
        cell.configure(with: restaurants[indexPath.row])
        return cell
    }
}

// MARK: - Searching

extension RestaurantListViewController: UISearchResultsUpdating, UISearchControllerDelegate {

    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text?.trimmingCharacters(in: .whitespaces) ?? ""
        if query.isEmpty {
            restaurants = allRestaurants
        } else {
            restaurants = allRestaurants.filter {
                $0.name.localizedCaseInsensitiveContains(query) || $0.cuisine.localizedCaseInsensitiveContains(query)
            }
        }
        tableView.reloadData()
    }

    func didDismissSearchController(_ searchController: UISearchController) {
        navigationItem.searchController = nil
    }
}

// MARK: - Restaurant cell

/// A row from the wireframe: boxed thumbnail on the left, name and "0.8 mi · 30 min" beside it.
/// The prototype for this cell is in Main.storyboard.
final class RestaurantCell: UITableViewCell {

    static let reuseID = "RestaurantCell"

    @IBOutlet private weak var thumbnailBox: UIView!
    @IBOutlet private weak var iconView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        thumbnailBox.layer.borderWidth = 1
        thumbnailBox.layer.cornerRadius = 8
        thumbnailBox.layer.borderColor = UIColor.separator.cgColor
        thumbnailBox.clipsToBounds = true   // keeps logos inside the rounded corners

        // CGColor doesn't update for dark mode by itself.
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (cell: RestaurantCell, _: UITraitCollection) in
            cell.thumbnailBox.layer.borderColor = UIColor.separator.cgColor
        }
    }

    func configure(with restaurant: Restaurant) {
        if let logo = restaurant.logo {
            // Logos fill the whole box.
            iconView.image = logo
            iconView.contentMode = .scaleAspectFill
        } else {
            // The SF Symbol placeholder stays small and centered.
            iconView.image = UIImage(systemName: restaurant.iconName, withConfiguration: UIImage.SymbolConfiguration(pointSize: 28))
            iconView.contentMode = .center
        }
        nameLabel.text = restaurant.name
        detailLabel.text = "\(String(format: "%.1f", restaurant.distanceMiles)) mi · \(restaurant.deliveryMinutes) min"
    }
}
