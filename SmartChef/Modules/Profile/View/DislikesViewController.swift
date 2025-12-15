
import UIKit
import SnapKit

class DislikesViewController: UIViewController {
    
    private let allIngredients = [
        "Onion", "Garlic", "Dairy", "Gluten", "Peanuts", "Eggs", "Soy",
        "Fish", "Shellfish", "Pork", "Beef", "Chicken", "Lamb",
        "Cilantro", "Mushrooms", "Tomato", "Eggplant", "Bell Pepper",
        "Corn", "Wheat", "Sugar", "Alcohol", "Caffeine", "Mustard",
        "Sesame", "Tree Nuts", "Avocado", "Coconut", "Strawberry", "Chocolate"
    ].sorted()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Disliked Ingredients"
        
        // Кнопка закрыть (для модалки)
        if let sheet = sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in make.edges.equalToSuperview() }
    }
}

extension DislikesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allIngredients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = allIngredients[indexPath.row]
        cell.textLabel?.text = item
        
        let dislikes = CoreDataManager.shared.getDislikes()
        cell.accessoryType = dislikes.contains(item) ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = allIngredients[indexPath.row]
        CoreDataManager.shared.toggleDislike(ingredient: item)
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        let gen = UISelectionFeedbackGenerator()
        gen.selectionChanged()
    }
}
