import Foundation

class DiscoverViewModel {
    
    let categories = ["Breakfast", "Lunch", "Dinner", "Vegan", "Dessert"]
    var selectedCategoryIndex = 0
    
    var recipes: [Recipe] = []
    var onDataUpdated: (() -> Void)?
    
    // MARK: - Fetch Logic
    
    // 1. Загрузка по Категории (как раньше)
    func fetchRecipes() {
        let categoryName = categories[selectedCategoryIndex].lowercased()
        performRequest(query: nil, type: categoryName)
    }
    
    // 2. Загрузка по Поиску (НОВОЕ)
    func searchRecipes(query: String) {
        // Сбрасываем категорию визуально, так как ищем по тексту
        performRequest(query: query, type: nil)
    }
    
    // Общая функция запроса
    private func performRequest(query: String?, type: String?) {
        var queryItems = [
            URLQueryItem(name: "number", value: "20"), // Один раз!
            
            // ВАЖНО: Эти параметры включают инструкции и ингредиенты
            URLQueryItem(name: "addRecipeInformation", value: "true"),
            URLQueryItem(name: "fillIngredients", value: "true"),
            URLQueryItem(name: "addRecipeNutrition", value: "true"),
            URLQueryItem(name: "instructionsRequired", value: "true")
        ]
        
        // Если ищем по тексту
        if let query = query, !query.isEmpty {
            queryItems.append(URLQueryItem(name: "query", value: query))
        }
        
        // Если ищем по категории
        if let type = type {
            queryItems.append(URLQueryItem(name: "type", value: type))
        }
        
        guard let url = NetworkManager.shared.createURL(
            for: "/recipes/complexSearch",
            queryItems: queryItems
        ) else { return }
        
        print("📡 Requesting: \(url.absoluteString)") // Смотри в консоль, чтобы проверить URL
        
        Task {
            do {
                let response: RecipeResponse = try await NetworkManager.shared.fetch(from: url)
                self.recipes = response.results
                
                // Проверка для отладки
                if let first = self.recipes.first {
                    print("✅ Loaded: \(first.title)")
                    print("   Steps count: \(first.analyzedInstructions?.first?.steps.count ?? 0)")
                }
                
                await MainActor.run {
                    self.onDataUpdated?()
                }
            } catch {
                print("❌ Error fetching recipes: \(error)")
            }
        }
    }
}
