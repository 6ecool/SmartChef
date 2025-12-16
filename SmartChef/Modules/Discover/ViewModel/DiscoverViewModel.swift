import Foundation

class DiscoverViewModel {
    
    let categories = ["Breakfast", "Lunch", "Dinner", "Vegan", "Dessert"]
    var selectedCategoryIndex = 0
    var recipes: [Recipe] = []
    var onDataUpdated: (() -> Void)?
    func fetchRecipes() {
        let categoryName = categories[selectedCategoryIndex].lowercased()
        performRequest(query: nil, type: categoryName)
    }
    
    
    
    
    
    func searchRecipes(query: String) {
        performRequest(query: query, type: nil)
    }
    
    private func performRequest(query: String?, type: String?) {
        var queryItems = [
            URLQueryItem(name: "number", value: "20"),
            URLQueryItem(name: "addRecipeInformation", value: "true"),
            URLQueryItem(name: "fillIngredients", value: "true"),
            URLQueryItem(name: "addRecipeNutrition", value: "true"),
            URLQueryItem(name: "instructionsRequired", value: "true")
        ]
        if let query = query, !query.isEmpty {
            queryItems.append(URLQueryItem(name: "query", value: query))
        }
        if let type = type {
            queryItems.append(URLQueryItem(name: "type", value: type))
        }
        guard let url = NetworkManager.shared.createURL(
            for: "/recipes/complexSearch",
            queryItems: queryItems
        ) else { return }
        
        print(" Requesting: \(url.absoluteString)")
        
        Task {
            do {
                let response: RecipeResponse = try await NetworkManager.shared.fetch(from: url)
                self.recipes = response.results
                if let first = self.recipes.first {
                    print("Loaded: \(first.title)")
                    print("Steps count: \(first.analyzedInstructions?.first?.steps.count ?? 0)")
                }
                
                await MainActor.run {
                    self.onDataUpdated?()
                }
            } catch {
                print("Error fetching recipes: \(error)")
            }
        }
    }
}
