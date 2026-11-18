//
//  MockData.swift
//  DeliverEagle
//
//  Fake restaurants and menus so the app works without a server or API.
//

import Foundation

enum MockData {
    static let restaurants: [Restaurant] = [
        Restaurant(
            name: "McDonald's",
            cuisine: "Burgers",
            distanceMiles: 0.8,
            deliveryMinutes: 30,
            iconName: "takeoutbag.and.cup.and.straw",
            menu: [
                MenuItem(name: "Cheeseburger", price: 2.99),
                MenuItem(name: "Quarter Pounder", price: 6.99),
                MenuItem(name: "Big Mac", price: 6.99),
                MenuItem(name: "McFlurry", price: 3.99),
                MenuItem(name: "Soft Drink", price: 3.29),
                MenuItem(name: "Fries", price: 2.79)
            ]
        ),
        Restaurant(
            name: "Whataburger",
            cuisine: "Burgers",
            distanceMiles: 1.4,
            deliveryMinutes: 45,
            iconName: "fork.knife",
            menu: [
                MenuItem(name: "Whataburger", price: 6.49),
                MenuItem(name: "Honey Butter Chicken Biscuit", price: 4.99),
                MenuItem(name: "Spicy Chicken Sandwich", price: 6.79),
                MenuItem(name: "Fries", price: 2.89),
                MenuItem(name: "Shake", price: 4.49)
            ]
        ),
        Restaurant(
            name: "Niner Pizza",
            cuisine: "Pizza",
            distanceMiles: 2.1,
            deliveryMinutes: 35,
            iconName: "flame",
            menu: [
                MenuItem(name: "Cheese Pizza", price: 11.99),
                MenuItem(name: "Pepperoni Pizza", price: 13.49),
                MenuItem(name: "Garlic Knots", price: 4.99),
                MenuItem(name: "Wings (8)", price: 9.99)
            ]
        ),
        Restaurant(
            name: "Green Bowl",
            cuisine: "Salads & Bowls",
            distanceMiles: 2.6,
            deliveryMinutes: 25,
            iconName: "leaf",
            menu: [
                MenuItem(name: "Chicken Caesar Bowl", price: 10.49),
                MenuItem(name: "Teriyaki Rice Bowl", price: 11.29),
                MenuItem(name: "Greek Salad", price: 9.49),
                MenuItem(name: "Lemonade", price: 2.99)
            ]
        )
    ]
}
