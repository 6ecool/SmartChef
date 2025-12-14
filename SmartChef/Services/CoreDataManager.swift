import UIKit
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    private init() {}
    
    // Доступ к контексту базы данных
    var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    // MARK: - 1. Сохранение (Create)
    func saveFavorite(recipe: Recipe) {
        // Создаем объект в базе
        let favorite = FavoriteRecipe(context: context)
        
        // Заполняем простые поля
        favorite.id = Int64(recipe.id)
        favorite.title = recipe.title
        favorite.image = recipe.image
        favorite.calories = Int64(recipe.calories)
        favorite.time = Int64(recipe.readyInMinutes ?? 0)
        favorite.servings = Int64(recipe.servings ?? 2)
        
        // Заполняем БЖУ (просто строками)
        favorite.protein = recipe.protein
        favorite.fat = recipe.fat
        favorite.carbs = recipe.carbs
        
        // МАГИЯ: Сохраняем сложные массивы как JSON-строки
        if let ingredients = recipe.extendedIngredients,
           let data = try? JSONEncoder().encode(ingredients) {
            favorite.ingredients = String(data: data, encoding: .utf8)
        }
        
        if let instructions = recipe.analyzedInstructions,
           let data = try? JSONEncoder().encode(instructions) {
            favorite.instructions = String(data: data, encoding: .utf8)
        }
        
        saveContext()
    }
    
    // MARK: - 2. Удаление (Delete)
    func deleteFavorite(recipeID: Int) {
        let fetchRequest: NSFetchRequest<FavoriteRecipe> = FavoriteRecipe.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", recipeID)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let objectToDelete = results.first {
                context.delete(objectToDelete)
                saveContext()
            }
        } catch {
            print("Error deleting: \(error)")
        }
    }
    
    // MARK: - 3. Проверка лайка (Read Status)
    func isFavorite(recipeID: Int) -> Bool {
        let fetchRequest: NSFetchRequest<FavoriteRecipe> = FavoriteRecipe.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", recipeID)
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            return false
        }
    }
    
    // MARK: - 4. Получение всех избранных (Read All)
    func fetchFavorites() -> [Recipe] {
        let request: NSFetchRequest<FavoriteRecipe> = FavoriteRecipe.fetchRequest()
        
        do {
            let savedRecipes = try context.fetch(request)
            
            // Превращаем данные базы обратно в Recipe, чтобы показать на экране
            return savedRecipes.map { saved in
                
                // Распаковываем JSON ингредиентов обратно в массив
                var ingredients: [Ingredient]? = nil
                if let dataStr = saved.ingredients, let data = dataStr.data(using: .utf8) {
                    ingredients = try? JSONDecoder().decode([Ingredient].self, from: data)
                }
                
                // Распаковываем JSON инструкций
                var instructions: [InstructionSection]? = nil
                if let dataStr = saved.instructions, let data = dataStr.data(using: .utf8) {
                    instructions = try? JSONDecoder().decode([InstructionSection].self, from: data)
                }
                
                return Recipe(
                    id: Int(saved.id),
                    title: saved.title ?? "",
                    image: saved.image,
                    readyInMinutes: Int(saved.time),
                    servings: Int(saved.servings),
                    nutrition: Nutrition(nutrients: [
                        Nutrient(name: "Calories", amount: Double(saved.calories), unit: "kcal"),
                        Nutrient(name: "Protein", amount: Double(saved.protein?.replacingOccurrences(of: "g", with: "") ?? "0") ?? 0, unit: "g"),
                        Nutrient(name: "Fat", amount: Double(saved.fat?.replacingOccurrences(of: "g", with: "") ?? "0") ?? 0, unit: "g"),
                        Nutrient(name: "Carbohydrates", amount: Double(saved.carbs?.replacingOccurrences(of: "g", with: "") ?? "0") ?? 0, unit: "g")
                    ]),
                    extendedIngredients: ingredients,
                    analyzedInstructions: instructions,
                    summary: nil,
                    instructions: nil // <--- ВОТ ТУТ МЫ ИСПРАВИЛИ ОШИБКУ (добавили nil)
                )
            }
        } catch {
            return []
        }
    }
    
    private func saveContext() {
        if context.hasChanges {
            try? context.save()
        }
    }
    
    // ... внутри CoreDataManager ...

        // MARK: - Meal Planner Logic

        // Сохранить рецепт на конкретный день
        func addToMealPlan(recipe: Recipe, date: Date) {
            let meal = MealPlanItem(context: context)
            
            // Заполняем данными рецепта
            meal.id = Int64(recipe.id)
            meal.title = recipe.title
            meal.image = recipe.image
            meal.calories = Int64(recipe.calories)
            
            // Самое важное: День недели
            meal.date = date
            
            // Кодируем детали (чтобы потом показать список покупок)
            if let ingredients = recipe.extendedIngredients,
               let data = try? JSONEncoder().encode(ingredients) {
                meal.ingredients = String(data: data, encoding: .utf8)
            }
            
            saveContext()
            print("📅 Added \(recipe.title) to \(date)")
        }
        
        // Получить рецепты для конкретного дня (понадобится позже для экрана Plan)
    // ... внутри CoreDataManager ...

        // Получить план на конкретную дату
        func fetchMealPlan(for date: Date) -> [MealPlanItem] {
            let request: NSFetchRequest<MealPlanItem> = MealPlanItem.fetchRequest()
            
            // Настраиваем начало и конец дня
            let calendar = Calendar.current
            let startDate = calendar.startOfDay(for: date) // 00:00:00
            let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)! // 00:00:00 следующего дня
            
            // Фильтр: дата >= startDate И дата < endDate
            request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startDate as NSDate, endDate as NSDate)
            
            // Сортируем (опционально)
            request.sortDescriptors = [NSSortDescriptor(key: "mealType", ascending: true)]
            
            do {
                return try context.fetch(request)
            } catch {
                print("Error fetching plan: \(error)")
                return []
            }
        }
        
        // Удалить из плана
        func deleteFromMealPlan(item: MealPlanItem) {
            context.delete(item)
            saveContext()
        }
    // ... внутри CoreDataManager ...

        // Обновленная функция сохранения
        func addToMealPlan(recipe: Recipe, date: Date, mealType: String) {
            let meal = MealPlanItem(context: context)
            
            meal.id = Int64(recipe.id)
            meal.title = recipe.title
            meal.image = recipe.image
            meal.calories = Int64(recipe.calories)
            
            // Сохраняем дату и тип
            meal.date = date         // <-- Нужно добавить поле date (Type: Date) в .xcdatamodeld
            meal.mealType = mealType // <-- Нужно добавить поле mealType (Type: String) в .xcdatamodeld
            
            // Кодируем ингредиенты (для списка покупок)
            if let ingredients = recipe.extendedIngredients,
               let data = try? JSONEncoder().encode(ingredients) {
                meal.ingredients = String(data: data, encoding: .utf8)
            }
            
            saveContext()
            print("📅 Added \(recipe.title) to \(date) for \(mealType)")
        }
}
