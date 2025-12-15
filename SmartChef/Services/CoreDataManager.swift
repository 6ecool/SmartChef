//import UIKit
//import CoreData
//
//class CoreDataManager {
//    
//    static let shared = CoreDataManager()
//    private init() {}
//    
//    var context: NSManagedObjectContext {
//        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//    }
//    
//    // MARK: - Favorites
//    func saveFavorite(recipe: Recipe) {
//        let favorite = FavoriteRecipe(context: context)
//        favorite.id = Int64(recipe.id)
//        favorite.title = recipe.title
//        favorite.image = recipe.image
//        favorite.calories = Int64(recipe.calories)
//        favorite.time = Int64(recipe.readyInMinutes ?? 0)
//        favorite.servings = Int64(recipe.servings ?? 1)
//        favorite.protein = recipe.protein
//        favorite.fat = recipe.fat
//        favorite.carbs = recipe.carbs
//        
//        if let ingredients = recipe.extendedIngredients,
//           let data = try? JSONEncoder().encode(ingredients) {
//            favorite.ingredients = String(data: data, encoding: .utf8)
//        }
//        
//        if let instructions = recipe.analyzedInstructions,
//           let data = try? JSONEncoder().encode(instructions) {
//            favorite.instructions = String(data: data, encoding: .utf8)
//        }
//        
//        saveContext()
//    }
//    
//    func deleteFavorite(recipeID: Int) {
//        let req: NSFetchRequest<FavoriteRecipe> = FavoriteRecipe.fetchRequest()
//        req.predicate = NSPredicate(format: "id == %d", recipeID)
//        if let res = try? context.fetch(req), let obj = res.first {
//            context.delete(obj)
//            saveContext()
//        }
//    }
//    
//    func isFavorite(recipeID: Int) -> Bool {
//        let req: NSFetchRequest<FavoriteRecipe> = FavoriteRecipe.fetchRequest()
//        req.predicate = NSPredicate(format: "id == %d", recipeID)
//        return (try? context.count(for: req)) ?? 0 > 0
//    }
//    
//    func fetchFavorites() -> [Recipe] {
//        let req: NSFetchRequest<FavoriteRecipe> = FavoriteRecipe.fetchRequest()
//        do {
//            let saved = try context.fetch(req)
//            return saved.map { item in
//                var ings: [Ingredient]?
//                if let d = item.ingredients?.data(using: .utf8) { ings = try? JSONDecoder().decode([Ingredient].self, from: d) }
//                
//                var inst: [InstructionSection]?
//                if let d = item.instructions?.data(using: .utf8) { inst = try? JSONDecoder().decode([InstructionSection].self, from: d) }
//                
//                return Recipe(
//                    id: Int(item.id),
//                    title: item.title ?? "",
//                    image: item.image,
//                    readyInMinutes: Int(item.time),
//                    servings: Int(item.servings),
//                    nutrition: Nutrition(nutrients: [
//                        Nutrient(name: "Calories", amount: Double(item.calories), unit: "kcal"),
//                        Nutrient(name: "Protein", amount: Double(item.protein?.replacingOccurrences(of: "g", with: "") ?? "0") ?? 0, unit: "g"),
//                        Nutrient(name: "Fat", amount: Double(item.fat?.replacingOccurrences(of: "g", with: "") ?? "0") ?? 0, unit: "g"),
//                        Nutrient(name: "Carbohydrates", amount: Double(item.carbs?.replacingOccurrences(of: "g", with: "") ?? "0") ?? 0, unit: "g")
//                    ]),
//                    extendedIngredients: ings,
//                    analyzedInstructions: inst,
//                    summary: nil,
//                    instructions: nil
//                )
//            }
//        } catch { return [] }
//    }
//    
//    // MARK: - Meal Planner
//    
//    func addToMealPlan(recipe: Recipe, date: Date, mealType: String, targetServings: Int, baseServings: Int) {
//        let meal = MealPlanItem(context: context)
//        
//        meal.id = Int64(recipe.id)
//        meal.title = recipe.title
//        meal.image = recipe.image
//        meal.time = Int64(recipe.readyInMinutes ?? 0)
//        
//        meal.protein = recipe.protein
//        meal.fat = recipe.fat
//        meal.carbs = recipe.carbs
//        
//        let baseCals = Double(recipe.calories)
//        let ratio = Double(targetServings) / Double(baseServings)
//        meal.calories = Int64(baseCals * ratio)
//        
//        meal.date = date
//        meal.mealType = mealType
//        meal.servings = Int64(targetServings)
//        meal.originalServings = Int64(baseServings)
//        
//        if let ingredients = recipe.extendedIngredients,
//           let data = try? JSONEncoder().encode(ingredients) {
//            meal.ingredients = String(data: data, encoding: .utf8)
//        }
//        
//        if let instructions = recipe.analyzedInstructions,
//           let data = try? JSONEncoder().encode(instructions) {
//            meal.instructions = String(data: data, encoding: .utf8)
//        }
//        
//        saveContext()
//    }
//    
//    func updateMealPlanItem(_ item: MealPlanItem, newServings: Int, baseCals: Double) {
//        let oldServings = Double(item.servings)
//        let baseServings = Double(item.originalServings > 0 ? item.originalServings : 1)
//        
//        item.servings = Int64(newServings)
//        
//        let ratio = Double(newServings) / baseServings
//        item.calories = Int64(baseCals * ratio)
//        
//        saveContext()
//        print("Updated servings to \(newServings), recalulated calories.")
//    }
//    
//    func fetchMealPlan(for date: Date) -> [MealPlanItem] {
//        let request: NSFetchRequest<MealPlanItem> = MealPlanItem.fetchRequest()
//        let calendar = Calendar.current
//        let startDate = calendar.startOfDay(for: date)
//        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
//        
//        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startDate as NSDate, endDate as NSDate)
//        request.sortDescriptors = [NSSortDescriptor(key: "mealType", ascending: true)]
//        
//        do {
//            return try context.fetch(request)
//        } catch {
//            return []
//        }
//    }
//    
//    func deleteFromMealPlan(item: MealPlanItem) {
//        context.delete(item)
//        saveContext()
//    }
//    
//    private func saveContext() {
//        if context.hasChanges { try? context.save() }
//    }
//}

import UIKit
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    private init() {}
    
    var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    // ===========================
    // MARK: - USER PROFILE LOGIC
    // ===========================
    
    // Получить профиль (или создать, если нет)
    func fetchUserProfile() -> UserProfile {
        let req: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        
        if let results = try? context.fetch(req), let profile = results.first {
            return profile
        } else {
            // Создаем новый, если не найден
            let newProfile = UserProfile(context: context)
            newProfile.calorieGoal = 2000
            newProfile.cookedCount = 0
            newProfile.dislikes = "" // Пустая строка
            saveContext()
            return newProfile
        }
    }
    
    // Обновить цель калорий
    func updateCalorieGoal(_ goal: Int) {
        let profile = fetchUserProfile()
        profile.calorieGoal = Int64(goal)
        saveContext()
    }
    
    // Увеличить счетчик готовки
    func incrementCookedCount() {
        let profile = fetchUserProfile()
        profile.cookedCount += 1
        saveContext()
    }
    
    // Управление черным списком
    func getDislikes() -> [String] {
        let profile = fetchUserProfile()
        guard let str = profile.dislikes, !str.isEmpty else { return [] }
        // Разделяем строку "Onion,Garlic" обратно в массив
        return str.components(separatedBy: ",")
    }
    
    func toggleDislike(ingredient: String) {
        let profile = fetchUserProfile()
        var current = getDislikes()
        
        if let index = current.firstIndex(of: ingredient) {
            current.remove(at: index) // Удалить
        } else {
            current.append(ingredient) // Добавить
        }
        
        // Сохраняем обратно как строку через запятую
        profile.dislikes = current.joined(separator: ",")
        saveContext()
    }
    
    // ===========================
    // MARK: - EXISTING LOGIC (Favorites & MealPlan)
    // ===========================
    // (Оставляем твой старый код без изменений, я его просто свернул для краткости ответа)
    
    func saveFavorite(recipe: Recipe) {
        let f = FavoriteRecipe(context: context)
        f.id = Int64(recipe.id); f.title = recipe.title; f.image = recipe.image; f.calories = Int64(recipe.calories); f.time = Int64(recipe.readyInMinutes ?? 0); f.servings = Int64(recipe.servings ?? 1); f.protein = recipe.protein; f.fat = recipe.fat; f.carbs = recipe.carbs
        if let i = recipe.extendedIngredients, let d = try? JSONEncoder().encode(i) { f.ingredients = String(data: d, encoding: .utf8) }
        if let s = recipe.analyzedInstructions, let d = try? JSONEncoder().encode(s) { f.instructions = String(data: d, encoding: .utf8) }
        saveContext()
    }
    
    func deleteFavorite(recipeID: Int) {
        let r: NSFetchRequest<FavoriteRecipe> = FavoriteRecipe.fetchRequest()
        r.predicate = NSPredicate(format: "id == %d", recipeID)
        if let res = try? context.fetch(r), let o = res.first { context.delete(o); saveContext() }
    }
    
    func isFavorite(recipeID: Int) -> Bool {
        let r: NSFetchRequest<FavoriteRecipe> = FavoriteRecipe.fetchRequest()
        r.predicate = NSPredicate(format: "id == %d", recipeID)
        return (try? context.count(for: r)) ?? 0 > 0
    }
    
    func fetchFavorites() -> [Recipe] {
        let r: NSFetchRequest<FavoriteRecipe> = FavoriteRecipe.fetchRequest()
        guard let res = try? context.fetch(r) else { return [] }
        return res.map { item in
            var i: [Ingredient]?; if let d = item.ingredients?.data(using: .utf8) { i = try? JSONDecoder().decode([Ingredient].self, from: d) }
            var s: [InstructionSection]?; if let d = item.instructions?.data(using: .utf8) { s = try? JSONDecoder().decode([InstructionSection].self, from: d) }
            return Recipe(id: Int(item.id), title: item.title ?? "", image: item.image, readyInMinutes: Int(item.time), servings: Int(item.servings), nutrition: Nutrition(nutrients: [
                Nutrient(name: "Calories", amount: Double(item.calories), unit: "kcal"), Nutrient(name: "Protein", amount: Double(item.protein?.replacingOccurrences(of: "g", with: "") ?? "0") ?? 0, unit: "g"), Nutrient(name: "Fat", amount: Double(item.fat?.replacingOccurrences(of: "g", with: "") ?? "0") ?? 0, unit: "g"), Nutrient(name: "Carbohydrates", amount: Double(item.carbs?.replacingOccurrences(of: "g", with: "") ?? "0") ?? 0, unit: "g")
            ]), extendedIngredients: i, analyzedInstructions: s, summary: nil, instructions: nil)
        }
    }
    
    func addToMealPlan(recipe: Recipe, date: Date, mealType: String, targetServings: Int, baseServings: Int) {
        let m = MealPlanItem(context: context)
        m.id = Int64(recipe.id); m.title = recipe.title; m.image = recipe.image; m.time = Int64(recipe.readyInMinutes ?? 0); m.protein = recipe.protein; m.fat = recipe.fat; m.carbs = recipe.carbs
        let ratio = Double(targetServings) / Double(baseServings)
        m.calories = Int64(Double(recipe.calories) * ratio)
        m.date = date; m.mealType = mealType; m.servings = Int64(targetServings); m.originalServings = Int64(baseServings)
        if let i = recipe.extendedIngredients, let d = try? JSONEncoder().encode(i) { m.ingredients = String(data: d, encoding: .utf8) }
        if let s = recipe.analyzedInstructions, let d = try? JSONEncoder().encode(s) { m.instructions = String(data: d, encoding: .utf8) }
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
        let cal = Calendar.current; let s = cal.startOfDay(for: date); let e = cal.date(byAdding: .day, value: 1, to: s)!
        r.predicate = NSPredicate(format: "date >= %@ AND date < %@", s as NSDate, e as NSDate)
        r.sortDescriptors = [NSSortDescriptor(key: "mealType", ascending: true)]
        return (try? context.fetch(r)) ?? []
    }
    
    func deleteFromMealPlan(item: MealPlanItem) { context.delete(item); saveContext() }
    
    private func saveContext() { if context.hasChanges { try? context.save() } }
}
