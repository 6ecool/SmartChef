import UIKit
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    private init() {}
    
    var context: NSManagedObjectContext {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    func saveUserRecipe(
        title: String,
        imagePath: String?,
        time: Int,
        servings: Int,
        calories: Double,
        protein: Double,
        fat: Double,
        carbs: Double,
        ingredients: [Ingredient],
        steps: [String]
    ) {
        let recipe = UserRecipe(context: context)
        
        let uniqueID = Int64(Date().timeIntervalSince1970) * -1
        recipe.id = uniqueID
        
        recipe.title = title
        recipe.imagePath = imagePath
        recipe.time = Int64(time)
        recipe.servings = Int64(servings)
        recipe.calories = calories
        recipe.protein = protein
        recipe.fat = fat
        recipe.carbs = carbs
        
        if let data = try? JSONEncoder().encode(ingredients) {
            recipe.ingredients = String(data: data, encoding: .utf8)
        }
        
        let stepObjects = steps.enumerated().map {
            Step(number: $0 + 1, step: $1)
        }
        let section = InstructionSection(steps: stepObjects)
        
        if let data = try? JSONEncoder().encode([section]) {
            recipe.instructions = String(data: data, encoding: .utf8)
        }
        
        saveContext()
    }
    
    func fetchUserRecipes() -> [Recipe] {
        let request: NSFetchRequest<UserRecipe> = UserRecipe.fetchRequest()
        
        guard let results = try? context.fetch(request) else { return [] }
        
        return results.map { item in
            let ingredients = item.ingredients
                .flatMap { $0.data(using: .utf8) }
                .flatMap { try? JSONDecoder().decode([Ingredient].self, from: $0) }
            
            let instructions = item.instructions
                .flatMap { $0.data(using: .utf8) }
                .flatMap { try? JSONDecoder().decode([InstructionSection].self, from: $0) }
            
            return Recipe(
                id: Int(item.id),
                title: item.title ?? "My Recipe",
                image: item.imagePath,
                readyInMinutes: Int(item.time),
                servings: Int(item.servings),
                nutrition: Nutrition(nutrients: [
                    Nutrient(name: "Calories", amount: item.calories, unit: "kcal"),
                    Nutrient(name: "Protein", amount: item.protein, unit: "g"),
                    Nutrient(name: "Fat", amount: item.fat, unit: "g"),
                    Nutrient(name: "Carbohydrates", amount: item.carbs, unit: "g")
                ]),
                extendedIngredients: ingredients,
                analyzedInstructions: instructions,
                summary: "My custom family recipe",
                instructions: nil
            )
        }
    }
    
    func fetchUserProfile() -> UserProfile {
        let req: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        
        if let profile = try? context.fetch(req).first {
            return profile
        }
        
        let profile = UserProfile(context: context)
        profile.calorieGoal = 2000
        profile.cookedCount = 0
        profile.dislikes = ""
        saveContext()
        return profile
    }
    
    func updateCalorieGoal(_ goal: Int) {
        let profile = fetchUserProfile()
        profile.calorieGoal = Int64(goal)
        saveContext()
    }
    
    func incrementCookedCount() {
        let profile = fetchUserProfile()
        profile.cookedCount += 1
        saveContext()
    }
    
    func getDislikes() -> [String] {
        let profile = fetchUserProfile()
        guard let str = profile.dislikes, !str.isEmpty else { return [] }
        return str.components(separatedBy: ",")
    }
    
    func toggleDislike(ingredient: String) {
        let profile = fetchUserProfile()
        var current = getDislikes()
        
        if let index = current.firstIndex(of: ingredient) {
            current.remove(at: index)
        } else {
            current.append(ingredient)
        }
        
        profile.dislikes = current.joined(separator: ",")
        saveContext()
    }
    
    func saveFavorite(recipe: Recipe) {
        let f = FavoriteRecipe(context: context)
        f.id = Int64(recipe.id)
        f.title = recipe.title
        f.image = recipe.image
        f.calories = Int64(recipe.calories)
        f.time = Int64(recipe.readyInMinutes ?? 0)
        f.servings = Int64(recipe.servings ?? 1)
        f.protein = recipe.protein
        f.fat = recipe.fat
        f.carbs = recipe.carbs
        
        if let i = recipe.extendedIngredients,
           let d = try? JSONEncoder().encode(i) {
            f.ingredients = String(data: d, encoding: .utf8)
        }
        
        if let s = recipe.analyzedInstructions,
           let d = try? JSONEncoder().encode(s) {
            f.instructions = String(data: d, encoding: .utf8)
        }
        
        saveContext()
    }
    
    
    
    func deleteFavorite(recipeID: Int) {
        let r: NSFetchRequest<FavoriteRecipe> = FavoriteRecipe.fetchRequest()
        r.predicate = NSPredicate(format: "id == %d", recipeID)
        
        if let o = try? context.fetch(r).first {
            context.delete(o)
            saveContext()
        }
    }
    
    func isFavorite(recipeID: Int) -> Bool {
        if recipeID < 0 { return true }
        let r: NSFetchRequest<FavoriteRecipe> = FavoriteRecipe.fetchRequest()
        r.predicate = NSPredicate(format: "id == %d", recipeID)
        return ((try? context.count(for: r)) ?? 0) > 0
    }
    
    func deleteUserRecipe(recipeID: Int) {
        let r: NSFetchRequest<UserRecipe> = UserRecipe.fetchRequest()
        r.predicate = NSPredicate(format: "id == %d", Int64(recipeID))
        
        if let o = try? context.fetch(r).first {
            context.delete(o)
            saveContext()
        }
    }
    
    func fetchFavorites() -> [Recipe] {
        let r: NSFetchRequest<FavoriteRecipe> = FavoriteRecipe.fetchRequest()
        guard let res = try? context.fetch(r) else { return [] }
        
        return res.map { item in
            let ingredients = item.ingredients
                .flatMap { $0.data(using: .utf8) }
                .flatMap { try? JSONDecoder().decode([Ingredient].self, from: $0) }
            
            let instructions = item.instructions
                .flatMap { $0.data(using: .utf8) }
                .flatMap { try? JSONDecoder().decode([InstructionSection].self, from: $0) }
            
            
            
            
            return Recipe(
                id: Int(item.id),
                title: item.title ?? "",
                
                image: item.image,
                readyInMinutes: Int(item.time),
                servings: Int(item.servings),
                nutrition: Nutrition(nutrients: [
                    Nutrient(name: "Calories", amount: Double(item.calories), unit: "kcal"),
                    Nutrient(name: "Protein", amount: Double(item.protein?.replacingOccurrences(of: "g", with: "") ?? "0") ?? 0, unit: "g"),
                    Nutrient(name: "Fat", amount: Double(item.fat?.replacingOccurrences(of: "g", with: "") ?? "0") ?? 0, unit: "g"),
                    Nutrient(name: "Carbohydrates", amount: Double(item.carbs?.replacingOccurrences(of: "g", with: "") ?? "0") ?? 0, unit: "g")
                ]),
                extendedIngredients: ingredients,
                analyzedInstructions: instructions,
                summary: nil,
                instructions: nil
            )
        }
        
        
        
    }
    
    
    
    
    
    func addToMealPlan(
        recipe: Recipe,
        date: Date,
        mealType: String,
        targetServings: Int,
        baseServings: Int
    ) {
        let m = MealPlanItem(context: context)
        m.id = Int64(recipe.id)
        m.title = recipe.title
        m.image = recipe.image
        m.time = Int64(recipe.readyInMinutes ?? 0)
        m.protein = recipe.protein
        m.fat = recipe.fat
        m.carbs = recipe.carbs
        
        let ratio = Double(targetServings) / Double(baseServings)
        m.calories = Int64(Double(recipe.calories) * ratio)
        
        m.date = date
        m.mealType = mealType
        m.servings = Int64(targetServings)
        m.originalServings = Int64(baseServings)
        
        if let i = recipe.extendedIngredients,
           let d = try? JSONEncoder().encode(i) {
            m.ingredients = String(data: d, encoding: .utf8)
        }
        
        if let s = recipe.analyzedInstructions,
           let d = try? JSONEncoder().encode(s) {
            m.instructions = String(data: d, encoding: .utf8)
        }
        saveContext()
    }
    
    
    
    
    
    
    func updateMealPlanItem(_ item: MealPlanItem, newServings: Int, baseCals: Double) {
        let baseServings = Double(item.originalServings > 0 ? item.originalServings : 1)
        item.servings = Int64(newServings)
        let ratio = Double(newServings) / baseServings
        item.calories = Int64(baseCals * ratio)
        saveContext()
    }
    
    func fetchMealPlan(for date: Date) -> [MealPlanItem] {
        let r: NSFetchRequest<MealPlanItem> = MealPlanItem.fetchRequest()
        let cal = Calendar.current
        let s = cal.startOfDay(for: date)
        let e = cal.date(byAdding: .day, value: 1, to: s)!
        
        r.predicate = NSPredicate(format: "date >= %@ AND date < %@", s as NSDate, e as NSDate)
        r.sortDescriptors = [NSSortDescriptor(key: "mealType", ascending: true)]
        
        return (try? context.fetch(r)) ?? []
    }
    
    func deleteFromMealPlan(item: MealPlanItem) {
        context.delete(item)
        saveContext()
    }
    
    private func saveContext() {
        if context.hasChanges {
            try? context.save()
        }
    }
}

