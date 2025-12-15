import Foundation
import UIKit

struct ShoppingItem {
    let name: String
    var amount: Double
    let unit: String
    var isChecked: Bool = false
}

class ShoppingListService {
    
    static let shared = ShoppingListService()
    private init() {}
    
    func getShoppingList(for date: Date) -> [ShoppingItem] {
        
        let meals = CoreDataManager.shared.fetchMealPlan(for: date)
        
        var tempDictionary: [String: ShoppingItem] = [:]
        
        for meal in meals {
            let baseServings = Double(meal.originalServings > 0 ? meal.originalServings : 1)
            let targetServings = Double(meal.servings > 0 ? meal.servings : 1)
            let ratio = targetServings / baseServings
            
            guard let dataStr = meal.ingredients,
                  let data = dataStr.data(using: .utf8),
                  let ingredients = try? JSONDecoder().decode([Ingredient].self, from: data)
            else { continue }
            
            for ing in ingredients {
                guard let name = ing.name, let amount = ing.amount else { continue }
                
                let finalAmount = amount * ratio
                let unit = ing.unit ?? ""
                
                let key = "\(name.lowercased())_\(unit.lowercased())"
                
                if var existingItem = tempDictionary[key] {
                    existingItem.amount += finalAmount
                    tempDictionary[key] = existingItem
                } else {
                    let newItem = ShoppingItem(name: name.capitalized, amount: finalAmount, unit: unit)
                    tempDictionary[key] = newItem
                }
            }
        }
        
        return Array(tempDictionary.values).sorted { $0.name < $1.name }
    }
}
