// Modules/Discover/ViewModel/DiscoverViewModel.swift
import Foundation

class DiscoverViewModel {
    
    // Observable (наблюдаемые) данные.
    // Когда они обновятся, View узнает об этом.
    var recipes: [Recipe] = []
    
    // Замыкание (callback), которое мы вызовем, когда данные загрузятся
    var onDataUpdated: (() -> Void)?
    
    func fetchRecipes() {
        let urlString = "https://api.spoonacular.com/recipes/complexSearch?apiKey=YOUR_KEY&number=10"
        
        Task {
            do {
                let response: RecipeResponse = try await NetworkManager.shared.fetch(from: urlString)
                self.recipes = response.results
                
                // Возвращаемся в главный поток, чтобы обновить UI
                await MainActor.run {
                    self.onDataUpdated?()
                }
            } catch {
                print("Error fetching: \(error)")
            }
        }
    }
}
