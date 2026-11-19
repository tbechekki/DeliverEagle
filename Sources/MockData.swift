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
            logoName: "mcdonalds",
            menu: [
                MenuItem(name: "Cheeseburger", price: 2.99),
                MenuItem(name: "Quarter Pounder", price: 6.99),
                MenuItem(name: "Big Mac", price: 6.99),
                MenuItem(name: "McFlurry", price: 3.99),
                MenuItem(name: "Soft Drink", sizes: [
                    MenuSize(name: "S", price: 1.99),
                    MenuSize(name: "M", price: 2.69),
                    MenuSize(name: "L", price: 3.29)
                ]),
                MenuItem(name: "Fries", price: 2.79)
            ]
        ),
        Restaurant(
            name: "Whataburger",
            cuisine: "Burgers",
            distanceMiles: 1.4,
            deliveryMinutes: 45,
            iconName: "fork.knife",
            logoName: "whataburger",
            menu: [
                MenuItem(name: "Whataburger", price: 6.49),
                MenuItem(name: "Honey Butter Chicken Biscuit", price: 4.99),
                MenuItem(name: "Spicy Chicken Sandwich", price: 6.79),
                MenuItem(name: "Fries", price: 2.89),
                MenuItem(name: "Shake", price: 4.49)
            ]
        ),
        Restaurant(
            name: "Domino's",
            cuisine: "Pizza",
            distanceMiles: 2.1,
            deliveryMinutes: 35,
            iconName: "flame",
            logoName: "dominos",
            menu: [
                MenuItem(name: "Cheese Pizza", price: 11.99),
                MenuItem(name: "Pepperoni Pizza", price: 13.99),
                MenuItem(name: "ExtravaganZZa Pizza", price: 16.99),
                MenuItem(name: "Stuffed Cheesy Bread", price: 7.99),
                MenuItem(name: "Boneless Chicken (8)", price: 8.99),
                MenuItem(name: "Chocolate Lava Crunch Cake", price: 3.99)
            ]
        ),
        Restaurant(
            name: "Chipotle",
            cuisine: "Mexican",
            distanceMiles: 2.6,
            deliveryMinutes: 25,
            iconName: "leaf",
            logoName: "chipotle",
            menu: [
                MenuItem(name: "Chicken Burrito", price: 10.25),
                MenuItem(name: "Steak Burrito Bowl", price: 11.75),
                MenuItem(name: "Chicken Quesadilla", price: 11.45),
                MenuItem(name: "Tacos (3)", price: 10.25),
                MenuItem(name: "Chips & Guacamole", price: 5.45),
                MenuItem(name: "Fountain Drink", sizes: [
                    MenuSize(name: "S", price: 2.65),
                    MenuSize(name: "M", price: 2.95),
                    MenuSize(name: "L", price: 3.25)
                ])
            ]
        )
    ]
}
