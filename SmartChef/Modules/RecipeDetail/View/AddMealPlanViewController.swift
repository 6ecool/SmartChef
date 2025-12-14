import UIKit
import SnapKit

protocol AddMealPlanDelegate: AnyObject {
    func didSaveMealPlan(date: Date, mealType: String)
}

class AddMealPlanViewController: UIViewController {
    
    weak var delegate: AddMealPlanDelegate?
    
    // Выбранная дата (по умолчанию сегодня)
    private var selectedDate = Date()
    
    // MARK: - UI Elements
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 24
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 10
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Add to Meal Plan"
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()
    
    // 1. Поле даты
    private lazy var dateTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Select date"
        tf.borderStyle = .roundedRect
        tf.textAlignment = .center // По центру красивее
        tf.font = .systemFont(ofSize: 16, weight: .medium)
        tf.textColor = .systemGreen
        
        // Вместо клавиатуры показываем DatePicker
        tf.inputView = datePicker
        
        // Добавляем тулбар с кнопкой "Done"
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(didTapDoneDate))
        doneBtn.tintColor = .systemGreen
        toolbar.setItems([flexSpace, doneBtn], animated: true)
        tf.inputAccessoryView = toolbar
        
        return tf
    }()
    
    // Иконка календаря (теперь просто для красоты, нажимать можно и на поле)
    private lazy var calendarButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "calendar"), for: .normal)
        btn.tintColor = .systemGreen
        btn.addTarget(self, action: #selector(didTapCalendarIcon), for: .touchUpInside)
        return btn
    }()
    
    // 👇 ИСПРАВЛЕННЫЙ DATE PICKER (Стиль Календаря)
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        
        // Используем современный стиль календаря (iOS 14+)
        if #available(iOS 14.0, *) {
            picker.preferredDatePickerStyle = .inline
        } else {
            picker.preferredDatePickerStyle = .wheels
        }
        
        picker.tintColor = .systemGreen
        picker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        // Если хочешь разрешить выбирать прошедшие даты (чтобы месяц переключался назад),
        // закомментируй строку ниже:
        picker.minimumDate = Date()
        
        return picker
    }()
    
    // 2. Выбор типа (Breakfast, Lunch, Dinner)
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.text = "Choose meal type:"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let typeSegmentedControl: UISegmentedControl = {
        let items = ["Breakfast", "Lunch", "Dinner"]
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 1 // Lunch по умолчанию
        sc.selectedSegmentTintColor = .systemGreen
        
        // Делаем текст белым при выборе
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        sc.setTitleTextAttributes(titleTextAttributes, for: .selected)
        return sc
    }()
    
    // 3. Кнопки (Cancel / Choose)
    private lazy var cancelButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Cancel", for: .normal)
        btn.setTitleColor(.systemRed, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.backgroundColor = .systemGray6
        btn.layer.cornerRadius = 12
        btn.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        return btn
    }()
    
    private lazy var chooseButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Add to Plan", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 16)
        btn.backgroundColor = .systemGreen
        btn.layer.cornerRadius = 12
        btn.addTarget(self, action: #selector(didTapChoose), for: .touchUpInside)
        return btn
    }()
    
    // Форматтер для отображения даты
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "EEE, dd MMM yyyy" // Более красивый формат (Tue, 14 Dec 2024)
        return df
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Делаем фон затемненным
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        setupUI()
        
        // Устанавливаем текущую дату в поле
        dateTextField.text = dateFormatter.string(from: Date())
    }
    
    private func setupUI() {
        view.addSubview(containerView)
        
        // Центрируем контейнер (поднимаем чуть выше центра для клавиатуры)
        containerView.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-50)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(dateTextField)
        containerView.addSubview(calendarButton)
        containerView.addSubview(typeLabel)
        containerView.addSubview(typeSegmentedControl)
        containerView.addSubview(cancelButton)
        containerView.addSubview(chooseButton)
        
        // Констрейнты
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        // Поле даты
        dateTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalTo(calendarButton.snp.leading).offset(-12)
            make.height.equalTo(44)
        }
        
        calendarButton.snp.makeConstraints { make in
            make.centerY.equalTo(dateTextField)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(30)
        }
        
        // Тип еды
        typeLabel.snp.makeConstraints { make in
            make.top.equalTo(dateTextField.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(20)
        }
        
        typeSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(typeLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        // Кнопки внизу
        let buttonStack = UIStackView(arrangedSubviews: [cancelButton, chooseButton])
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 16
        
        containerView.addSubview(buttonStack)
        buttonStack.snp.makeConstraints { make in
            make.top.equalTo(typeSegmentedControl.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-24)
            make.height.equalTo(50)
        }
    }
    
    // MARK: - Actions
    
    @objc private func didTapCalendarIcon() {
        // При нажатии на иконку открываем ввод даты
        dateTextField.becomeFirstResponder()
    }
    
    @objc private func dateChanged() {
        selectedDate = datePicker.date
        dateTextField.text = dateFormatter.string(from: selectedDate)
        // Не скрываем календарь сразу, чтобы пользователь мог передумать
    }
    
    @objc private func didTapDoneDate() {
        dateTextField.resignFirstResponder()
    }
    
    @objc private func didTapCancel() {
        dismiss(animated: true)
    }
    
    @objc private func didTapChoose() {
        // Получаем тип еды
        let index = typeSegmentedControl.selectedSegmentIndex
        let mealType = typeSegmentedControl.titleForSegment(at: index) ?? "Lunch"
        
        // Отправляем данные делегату
        delegate?.didSaveMealPlan(date: selectedDate, mealType: mealType)
        
        dismiss(animated: true)
    }
}
