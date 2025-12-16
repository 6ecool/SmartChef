import UIKit
import SnapKit

class MealPlannerViewController: UIViewController {
    
    private var breakfastItems: [MealPlanItem] = []
    private var lunchItems: [MealPlanItem] = []
    private var dinnerItems: [MealPlanItem] = []
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "Plan for:"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.tintColor = .systemGreen
        picker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        return picker
    }()
    
    
    
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.backgroundColor = .systemGray6
        tv.delegate = self
        tv.dataSource = self
        tv.register(MealPlanCell.self, forCellReuseIdentifier: MealPlanCell.identifier)
        return tv
    }()
    
    
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No meals planned.\nTap '+' on a recipe to add!"
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 2
        label.isHidden = true
        return label
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Meal Plan"
        navigationController?.navigationBar.prefersLargeTitles = true
        setupUI()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    private func setupUI() {
        view.addSubview(headerView)
        headerView.addSubview(dateLabel)
        headerView.addSubview(datePicker)
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(60)
        }
        dateLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        datePicker.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        emptyLabel.snp.makeConstraints { make in
            make.center.equalTo(tableView)
            make.leading.trailing.equalToSuperview().inset(40)
        }
    }
    
    @objc private func dateChanged() {
        loadData()
    }
    private func loadData() {
        let allItems = CoreDataManager.shared.fetchMealPlan(for: datePicker.date)
        breakfastItems = allItems.filter { $0.mealType == "Breakfast" }
        lunchItems = allItems.filter { $0.mealType == "Lunch" }
        dinnerItems = allItems.filter { $0.mealType == "Dinner" }
        tableView.reloadData()
        let isEmpty = breakfastItems.isEmpty && lunchItems.isEmpty && dinnerItems.isEmpty
        emptyLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
    private func deleteItem(at indexPath: IndexPath) {
        let item: MealPlanItem
        switch indexPath.section {
        case 0: item = breakfastItems[indexPath.row]
        case 1: item = lunchItems[indexPath.row]
        default: item = dinnerItems[indexPath.row]
        }
        CoreDataManager.shared.deleteFromMealPlan(item: item)
        loadData()
    }
    private func getMealData(for indexPath: IndexPath) -> (recipe: Recipe, item: MealPlanItem) {
        let item: MealPlanItem
        switch indexPath.section {
        case 0: item = breakfastItems[indexPath.row]
        case 1: item = lunchItems[indexPath.row]
        default: item = dinnerItems[indexPath.row]
        }
        var ingredients: [Ingredient]? = nil
        if let d = item.ingredients?.data(using: .utf8) {
            ingredients = try? JSONDecoder().decode([Ingredient].self, from: d)
        }
        var instructions: [InstructionSection]? = nil
        if let d = item.instructions?.data(using: .utf8) {
            instructions = try? JSONDecoder().decode([InstructionSection].self, from: d)
        }
        let baseServings = Int(item.originalServings > 0 ? item.originalServings : 1)
        let targetServings = Int(item.servings > 0 ? item.servings : 1)
        let ratio = Double(targetServings) / Double(baseServings)
        let baseCalories = Double(item.calories) / ratio
        
        
        
        
        let prot = Double(item.protein?.replacingOccurrences(of: "g", with: "") ?? "0") ?? 0
        let fat = Double(item.fat?.replacingOccurrences(of: "g", with: "") ?? "0") ?? 0
        let carb = Double(item.carbs?.replacingOccurrences(of: "g", with: "") ?? "0") ?? 0
        
        let recipe = Recipe(
            id: Int(item.id),
            title: item.title ?? "Unknown",
            image: item.image,
            readyInMinutes: Int(item.time),
            servings: baseServings,
            nutrition: Nutrition(nutrients: [
                Nutrient(name: "Calories", amount: baseCalories, unit: "kcal"),
                Nutrient(name: "Protein", amount: prot, unit: "g"),
                Nutrient(name: "Fat", amount: fat, unit: "g"),
                Nutrient(name: "Carbohydrates", amount: carb, unit: "g")
            ]),
            extendedIngredients: ingredients,
            analyzedInstructions: instructions,
            summary: nil,
            instructions: nil
        )
        
        return (recipe, item)
    }
}
extension MealPlannerViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { 3 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return breakfastItems.count
        case 1: return lunchItems.count
        case 2: return dinnerItems.count
        default: return 0
        }
    }
    
    
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return breakfastItems.isEmpty ? nil : "Breakfast"
        case 1: return lunchItems.isEmpty ? nil : "Lunch"
        case 2: return dinnerItems.isEmpty ? nil : "Dinner"
        default: return nil
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MealPlanCell.identifier, for: indexPath) as! MealPlanCell
        let item: MealPlanItem
        switch indexPath.section {
        case 0: item = breakfastItems[indexPath.row]
        case 1: item = lunchItems[indexPath.row]
        default: item = dinnerItems[indexPath.row]
        }
        cell.configure(with: item)
        
        cell.onDelete = { [weak self] in
            let alert = UIAlertController(title: "Delete Meal?", message: "Remove from plan?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                self?.deleteItem(at: indexPath)
            }))
            self?.present(alert, animated: true)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 80 }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let data = getMealData(for: indexPath)
        let detailVC = RecipeDetailViewController(
            recipe: data.recipe,
            initialServings: Int(data.item.servings)
        )
        detailVC.editingMealPlanItem = data.item
        detailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
