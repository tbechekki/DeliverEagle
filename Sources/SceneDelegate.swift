//
//  SceneDelegate.swift
//  DeliverEagle
//
//  Replaces the SceneDelegate.swift that Xcode creates.
//  Builds the app in code: a tab bar with Home, Cart, and Orders.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = MainTabBarController()
        window.tintColor = .systemOrange
        window.makeKeyAndVisible()
        self.window = window
    }
}

final class MainTabBarController: UITabBarController {

    static let homeTab = 0
    static let cartTab = 1
    static let ordersTab = 2

    override func viewDidLoad() {
        super.viewDidLoad()

        let home = UINavigationController(rootViewController: RestaurantListViewController())
        home.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: MainTabBarController.homeTab)

        let cart = UINavigationController(rootViewController: CartViewController())
        cart.tabBarItem = UITabBarItem(title: "Cart", image: UIImage(systemName: "cart"), tag: MainTabBarController.cartTab)

        let orders = UINavigationController(rootViewController: OrderStatusViewController())
        orders.tabBarItem = UITabBarItem(title: "Orders", image: UIImage(systemName: "bag"), tag: MainTabBarController.ordersTab)

        viewControllers = [home, cart, orders]

        NotificationCenter.default.addObserver(self, selector: #selector(updateCartBadge), name: .cartDidChange, object: nil)
        updateCartBadge()
    }

    /// Shows the number of items in the cart on the Cart tab.
    @objc private func updateCartBadge() {
        let count = CartStore.shared.itemCount
        viewControllers?[MainTabBarController.cartTab].tabBarItem.badgeValue = count > 0 ? "\(count)" : nil
    }
}
