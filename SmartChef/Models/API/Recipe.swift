import Foundation

struct RecipeResponse: Codable {
    let results: [Recipe]
}

struct Recipe: Codable {
    let id: Int
    let title: String
    let image: String?
    let readyInMinutes: Int?
    let servings: Int?
    let nutrition: Nutrition?
    let extendedIngredients: [Ingredient]?
    let analyzedInstructions: [InstructionSection]?
    let summary: String?
    let instructions: String?
    var calories: Int { getNutrient(name: "Calories") }
    var protein: String { "\(getNutrient(name: "Protein"))g" }
    var fat: String { "\(getNutrient(name: "Fat"))g" }
    var carbs: String { "\(getNutrient(name: "Carbohydrates"))g" }
    
    private func getNutrient(name: String) -> Int {
        guard let nutrients = nutrition?.nutrients else { return 0 }
        if let nut = nutrients.first(where: { $0.name == name }) {
            return Int(nut.amount)
        }
        return 0
    }
}
struct InstructionSection: Codable {
    let steps: [Step]
}
struct Step: Codable {
    let number: Int
    let step: String
}
struct Ingredient: Codable {
    let id: Int?
    let name: String?
    let original: String?
    let amount: Double?
    let unit: String?
}
struct Nutrition: Codable {
    let nutrients: [Nutrient]
}
struct Nutrient: Codable {
    let name: String
    let amount: Double
    let unit: String
}
