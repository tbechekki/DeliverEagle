//
//  SceneDelegate.swift
//  DeliverEagle
//
//  The window and the tab bar (Home, Cart, Orders) come from Main.storyboard,
//  which Info.plist sets as the scene's storyboard.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // UIKit has already created the window from Main.storyboard by this point.
        window?.tintColor = .systemOrange
    }
}

/// The storyboard's initial view controller. Its three tabs are set up in Main.storyboard.
final class MainTabBarController: UITabBarController {

    static let homeTab = 0
    static let cartTab = 1
    static let ordersTab = 2

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(updateCartBadge), name: .cartDidChange, object: nil)
        updateCartBadge()
    }

    /// Shows the number of items in the cart on the Cart tab.
    @objc private func updateCartBadge() {
        let count = CartStore.shared.itemCount
        viewControllers?[MainTabBarController.cartTab].tabBarItem.badgeValue = count > 0 ? "\(count)" : nil
    }
}
