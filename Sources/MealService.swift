//
//  MealService.swift
//  DeliverEagle
//
//  Fetches real dishes from TheMealDB, a free public API (no key needed):
//  https://www.themealdb.com/api.php
//  Uses URLSession, Codable, an escaping closure, and a custom protocol.
//

import Foundation

// MARK: - Codable models for the API's JSON

struct MealResponse: Codable {
    let meals: [Meal]?
}

struct Meal: Codable {
    let idMeal: String
    let strMeal: String
    let strMealThumb: String?
}

enum MealServiceError: Error {
    case badURL
    case noData
}

// MARK: - Protocol

/// Anything that can fetch meals. The Home screen only knows about this protocol,
/// so a fake service could be swapped in for testing.
protocol MealServiceProtocol {
    func fetchMeals(category: String, completion: @escaping (Result<[Meal], Error>) -> Void)
}

// MARK: - Real network service

final class MealService: MealServiceProtocol {

    func fetchMeals(category: String, completion: @escaping (Result<[Meal], Error>) -> Void) {
        let encodedCategory = category.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? category
        guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/filter.php?c=\(encodedCategory)") else {
            completion(.failure(MealServiceError.badURL))
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            let result: Result<[Meal], Error>

            if let error = error {
                result = .failure(error)
            } else if let data = data {
                do {
                    let response = try JSONDecoder().decode(MealResponse.self, from: data)
                    result = .success(response.meals ?? [])
                } catch {
                    result = .failure(error)
                }
            } else {
                result = .failure(MealServiceError.noData)
            }

            // UI updates must happen on the main thread.
            DispatchQueue.main.async {
                completion(result)
            }
        }.resume()
    }
}
