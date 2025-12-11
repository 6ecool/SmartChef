// Models/API/Recipe.swift
struct RecipeResponse: Decodable {
    let results: [Recipe]
}

struct Recipe: Decodable {
    let id: Int
    let title: String
    let image: String
}
