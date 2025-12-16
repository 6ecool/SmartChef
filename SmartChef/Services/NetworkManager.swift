import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
}
class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    private let apiKey = "15c84443b5f5490d901456b7c16972f5"
    private let baseURL = "https://api.spoonacular.com"
    func createURL(for endpoint: String, queryItems: [URLQueryItem] = []) -> URL? {
        guard var components = URLComponents(string: baseURL + endpoint) else { return nil }
        var items = queryItems
        items.append(URLQueryItem(name: "apiKey", value: apiKey))
        components.queryItems = items
        return components.url
    }
    func fetch<T: Decodable>(from url: URL) async throws -> T {
        print("Fetching: \(url.absoluteString)")
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown Error"
            print("SERVER ERROR [\(httpResponse.statusCode)]: \(errorMessage)")
            throw NetworkError.serverError(errorMessage)
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            print("DECODING ERROR: \(error)")
            throw NetworkError.decodingError
        }
    }

    func getRecipeInformation(id: Int, completion: @escaping (Result<Recipe, Error>) -> Void) {
        let urlString = "https://api.spoonacular.com/recipes/\(id)/information?apiKey=\(apiKey)&includeNutrition=true"
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            
            guard let data = data else { return }
            do {
                let recipe = try JSONDecoder().decode(Recipe.self, from: data)
                completion(.success(recipe))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(error))
            }
            
        }.resume()
    }
}
