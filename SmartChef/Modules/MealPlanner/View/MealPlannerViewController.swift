import UIKit
import SnapKit

class MealPlannerViewController: UIViewController {
    
    // Данные по секциям
    private var breakfastItems: [MealPlanItem] = []
    private var lunchItems: [MealPlanItem] = []
    private var dinnerItems: [MealPlanItem] = []
    
    // MARK: - UI Elements
    
    // Верхняя панель с датой
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
    
    // Календарь (Компактный стиль)
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact // Кнопка с датой
        picker.tintColor = .systemGreen
        // При изменении даты вызываем функцию
        picker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        return picker
    }()
    
    // Таблица
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped) // Красивый стиль с отступами
        tv.backgroundColor = .systemGray6
        tv.delegate = self
        tv.dataSource = self
        tv.register(MealPlanCell.self, forCellReuseIdentifier: MealPlanCell.identifier)
        return tv
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No meals planned for this day.\nTap '+' on a recipe to add one!"
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 2
        label.isHidden = true
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Meal Plan"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        setupUI()
        loadData()
    }
    
    // Обновляем данные каждый раз, когда заходим на экран
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(headerView)
        headerView.addSubview(dateLabel)
        headerView.addSubview(datePicker)
        
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        
        // Header Constraints
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
            // Ширина подбирается системой автоматически
        }
        
        // Table Constraints
        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        emptyLabel.snp.makeConstraints { make in
            make.center.equalTo(tableView)
            make.leading.trailing.equalToSuperview().inset(40)
        }
    }
    
    // MARK: - Data Logic
    
    @objc private func dateChanged() {
        // Когда сменили дату в календаре -> перезагружаем таблицу
        loadData()
    }
    
    private func loadData() {
        let selectedDate = datePicker.date
        let allItems = CoreDataManager.shared.fetchMealPlan(for: selectedDate)
        
        // Фильтруем по типу (Breakfast, Lunch, Dinner)
        breakfastItems = allItems.filter { $0.mealType == "Breakfast" }
        lunchItems = allItems.filter { $0.mealType == "Lunch" }
        dinnerItems = allItems.filter { $0.mealType == "Dinner" }
        
        tableView.reloadData()
        
        // Показываем "Пусто", если вообще ничего нет
        let isEmpty = breakfastItems.isEmpty && lunchItems.isEmpty && dinnerItems.isEmpty
        emptyLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
}

// MARK: - TableView DataSource & Delegate

extension MealPlannerViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3 // Breakfast, Lunch, Dinner
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return breakfastItems.count
        case 1: return lunchItems.count
        case 2: return dinnerItems.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // Показываем заголовок секции только если там есть еда
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
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    // Удаление свайпом
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let itemToDelete: MealPlanItem
            
            // Находим и удаляем из массива
            switch indexPath.section {
            case 0:
                itemToDelete = breakfastItems[indexPath.row]
                breakfastItems.remove(at: indexPath.row)
            case 1:
                itemToDelete = lunchItems[indexPath.row]
                lunchItems.remove(at: indexPath.row)
            default:
                itemToDelete = dinnerItems[indexPath.row]
                dinnerItems.remove(at: indexPath.row)
            }
            
            // Удаляем из базы
            CoreDataManager.shared.deleteFromMealPlan(item: itemToDelete)
            
            // Удаляем из таблицы с анимацией
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // Если все удалили, покажем Empty Label
            if breakfastItems.isEmpty && lunchItems.isEmpty && dinnerItems.isEmpty {
                loadData()
            }
        }
    }
    
    // Нажатие на ячейку (переход к деталям)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Тут можно реализовать открытие деталей рецепта
        // Для этого нужно будет сконвертировать MealPlanItem обратно в Recipe, как мы делали в Favorites
    }
}
