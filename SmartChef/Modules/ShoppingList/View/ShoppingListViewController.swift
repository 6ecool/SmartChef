import UIKit
import SnapKit

class ShoppingListViewController: UIViewController {
    
    private var items: [ShoppingItem] = []
    
    // MARK: - UI Elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Grocery List 🛒"
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    // 👇 Добавили выбор даты
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact // Стиль кнопки
        picker.tintColor = .systemGreen
        // При изменении даты вызываем обновление
        picker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        return picker
    }()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tv.backgroundColor = .systemBackground
        return tv
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No meals planned for this date.\nAdd some recipes to your plan! 📅"
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        loadData()
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(datePicker)
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        
        // Заголовок
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().inset(16)
        }
        
        // Календарь (справа от заголовка или под ним, сделаем справа для компактности)
        datePicker.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().inset(16)
        }
        
        // Таблица
        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        // Пустой лейбл
        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(40)
        }
    }
    
    // MARK: - Logic
    
    @objc private func dateChanged() {
        // Когда пользователь сменил дату — обновляем список
        loadData()
    }
    
    private func loadData() {
        // Берем дату из пикера и запрашиваем продукты
        let selectedDate = datePicker.date
        items = ShoppingListService.shared.getShoppingList(for: selectedDate)
        
        emptyLabel.isHidden = !items.isEmpty
        tableView.isHidden = items.isEmpty
        tableView.reloadData()
        
        // Анимация обновления (опционально)
        if !items.isEmpty {
            tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
    }
}

// MARK: - TableView DataSource
extension ShoppingListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = items[indexPath.row]
        
        // Форматируем вес (без лишних нулей)
        let amountString = String(format: "%.1f", item.amount)
            .replacingOccurrences(of: ".0", with: "")
        
        cell.textLabel?.text = "\(item.name): \(amountString) \(item.unit)"
        cell.textLabel?.font = .systemFont(ofSize: 16)
        
        // Чекбокс
        let checkName = item.isChecked ? "checkmark.circle.fill" : "circle"
        cell.imageView?.image = UIImage(systemName: checkName)
        cell.imageView?.tintColor = .systemGreen
        
        // Зачеркивание
        if item.isChecked {
            let attributeString = NSMutableAttributedString(string: cell.textLabel?.text ?? "")
            attributeString.addAttribute(.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            cell.textLabel?.attributedText = attributeString
            cell.textLabel?.textColor = .lightGray
        } else {
            cell.textLabel?.attributedText = nil
            cell.textLabel?.text = "\(item.name): \(amountString) \(item.unit)"
            cell.textLabel?.textColor = .label
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Переключаем чекбокс
        items[indexPath.row].isChecked.toggle()
        
        // Обновляем ячейку
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}
