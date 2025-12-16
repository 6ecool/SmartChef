import UIKit
import SnapKit

class AddRecipeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private var selectedImagePath: String?
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.keyboardDismissMode = .onDrag
        return sv
    }()
    
    private let contentView = UIView()
    
    private lazy var imageButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .systemGray6
        btn.layer.cornerRadius = 16
        btn.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        btn.tintColor = .systemGray
        btn.imageView?.contentMode = .scaleAspectFill
        btn.clipsToBounds = true
        btn.addTarget(self, action: #selector(didTapImage), for: .touchUpInside)
        return btn
    }()
    
    
    
    
    
    
    private let titleField = createTextField(placeholder: "Recipe Title")
    private let timeField = createTextField(placeholder: "Min", keyboard: .numberPad)
    private let servingsField = createTextField(placeholder: "Pers", keyboard: .numberPad)
    private let calField = createTextField(placeholder: "Kcal", keyboard: .numberPad)
    private let protField = createTextField(placeholder: "Prot", keyboard: .numberPad)
    private let fatField = createTextField(placeholder: "Fat", keyboard: .numberPad)
    private let carbField = createTextField(placeholder: "Carb", keyboard: .numberPad)
    private let ingredientsTitleLabel = createLabel(text: "Ingredients")
    
    private let ingredientsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }()
    
    private lazy var addIngredientButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("+ Add Ingredient", for: .normal)
        btn.tintColor = .systemGreen
        btn.addTarget(self, action: #selector(addIngredientRow), for: .touchUpInside)
        return btn
    }()
    
    private let instructionsTitleLabel = createLabel(text: "Instructions")
    
    private let instructionsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }()
    
    
    
    
    
    
    
    private lazy var addInstructionButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("+ Add Step", for: .normal)
        btn.tintColor = .systemGreen
        btn.addTarget(self, action: #selector(addInstructionRow), for: .touchUpInside)
        return btn
    }()
    
    
    
    
    private lazy var saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Save Recipe", for: .normal)
        btn.backgroundColor = .systemGreen
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 18)
        btn.layer.cornerRadius = 12
        btn.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "New Recipe"
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        setupUI()
        addIngredientRow()
        addInstructionRow()
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
        }
        
        contentView.addSubview(imageButton)
        imageButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(120)
        }
        
        
        
        
        contentView.addSubview(titleField)
        titleField.snp.makeConstraints { make in
            make.top.equalTo(imageButton.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        
        
        
        let row1 = UIStackView(arrangedSubviews: [timeField, servingsField, calField])
        row1.spacing = 10
        row1.distribution = .fillEqually
        
        let row2 = UIStackView(arrangedSubviews: [protField, fatField, carbField])
        row2.spacing = 10
        row2.distribution = .fillEqually
        
        contentView.addSubview(row1)
        contentView.addSubview(row2)
        
        row1.snp.makeConstraints { make in
            make.top.equalTo(titleField.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        row2.snp.makeConstraints { make in
            make.top.equalTo(row1.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        contentView.addSubview(ingredientsTitleLabel)
        contentView.addSubview(ingredientsStackView)
        contentView.addSubview(addIngredientButton)
        
        ingredientsTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(row2.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(20)
        }
        ingredientsStackView.snp.makeConstraints { make in
            make.top.equalTo(ingredientsTitleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        addIngredientButton.snp.makeConstraints { make in
            make.top.equalTo(ingredientsStackView.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(20)
        }
        
        contentView.addSubview(instructionsTitleLabel)
        contentView.addSubview(instructionsStackView)
        contentView.addSubview(addInstructionButton)
        
        instructionsTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(addIngredientButton.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(20)
        }
        instructionsStackView.snp.makeConstraints { make in
            make.top.equalTo(instructionsTitleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        addInstructionButton.snp.makeConstraints { make in
            make.top.equalTo(instructionsStackView.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(20)
        }
        
        contentView.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(addInstructionButton.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(54)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    
    
    
    
    
    @objc private func addIngredientRow() {
        let row = UIView()
        
        let nameField = AddRecipeViewController.createTextField(placeholder: "Product (e.g. Eggs)")
        nameField.tag = 1
        
        let amountField = AddRecipeViewController.createTextField(placeholder: "Amt", keyboard: .default)
        amountField.tag = 2
        
        row.addSubview(nameField)
        row.addSubview(amountField)
        
        nameField.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.trailing.equalTo(amountField.snp.leading).offset(-10)
        }
        
        amountField.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.width.equalTo(80)
        }
        
        row.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        
        ingredientsStackView.addArrangedSubview(row)
        
        row.alpha = 0
        UIView.animate(withDuration: 0.3) { row.alpha = 1 }
    }
    
    @objc private func addInstructionRow() {
        let stepIndex = instructionsStackView.arrangedSubviews.count + 1
        let row = UIView()
        
        let numberLabel = UILabel()
        numberLabel.text = "\(stepIndex)."
        numberLabel.font = .boldSystemFont(ofSize: 16)
        numberLabel.textColor = .systemGreen
        numberLabel.widthAnchor.constraint(equalToConstant: 24).isActive = true
        
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.systemGray5.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.tag = 1
        textView.isScrollEnabled = false
        
        row.addSubview(numberLabel)
        row.addSubview(textView)
        
        numberLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(6)
        }
        
        textView.snp.makeConstraints { make in
            make.leading.equalTo(numberLabel.snp.trailing).offset(8)
            make.top.bottom.trailing.equalToSuperview()
            make.height.greaterThanOrEqualTo(44)
        }
        
        instructionsStackView.addArrangedSubview(row)
        
        row.alpha = 0
        UIView.animate(withDuration: 0.3) { row.alpha = 1 }
    }
    
    @objc private func didTapSave() {
        guard let title = titleField.text, !title.isEmpty else {
            shakeField(titleField)
            return
        }
        
        var ingredients: [Ingredient] = []
        for view in ingredientsStackView.arrangedSubviews {
            guard
                let nameField = view.viewWithTag(1) as? UITextField,
                let amountField = view.viewWithTag(2) as? UITextField,
                let name = nameField.text, !name.isEmpty
            else { continue }
            
            let amountText = amountField.text ?? "0"
            let amount = Double(amountText.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) ?? 1.0
            
            let ing = Ingredient(
                id: Int.random(in: 0...99999),
                name: name,
                original: "\(amountText) \(name)",
                amount: amount,
                unit: ""
            )
            ingredients.append(ing)
        }
        
        var steps: [String] = []
        for view in instructionsStackView.arrangedSubviews {
            guard
                let textView = view.viewWithTag(1) as? UITextView,
                let text = textView.text, !text.isEmpty
            else { continue }
            steps.append(text)
        }
        
        
        
        CoreDataManager.shared.saveUserRecipe(
            title: title,
            imagePath: selectedImagePath,
            time: Int(timeField.text ?? "") ?? 0,
            servings: Int(servingsField.text ?? "") ?? 1,
            calories: Double(calField.text ?? "") ?? 0,
            protein: Double(protField.text ?? "") ?? 0,
            fat: Double(fatField.text ?? "") ?? 0,
            carbs: Double(carbField.text ?? "") ?? 0,
            ingredients: ingredients,
            steps: steps
        )
        
        let gen = UINotificationFeedbackGenerator()
        gen.notificationOccurred(.success)
        
        let alert = UIAlertController(title: "Success", message: "Recipe saved!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.clearForm()
            self.tabBarController?.selectedIndex = 1
        })
        present(alert, animated: true)
    }
    
    private func extractAmountAndUnit(from text: String) -> (Double, String) {
        let cleanText = text.replacingOccurrences(of: ",", with: ".")
        let scanner = Scanner(string: cleanText)
        if let doubleVal = scanner.scanDouble() {
            let unitPart = cleanText
                .dropFirst(scanner.currentIndex.utf16Offset(in: cleanText))
                .trimmingCharacters(in: .whitespaces)
            return (doubleVal, unitPart)
        }
        return (1.0, "")
    }
    
    @objc private func didTapImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else { return }
        
        imageButton.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        
        if let data = image.jpegData(compressionQuality: 0.8) {
            let filename = UUID().uuidString + ".jpg"
            let path = getDocumentsDirectory().appendingPathComponent(filename)
            try? data.write(to: path)
            selectedImagePath = path.path
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func clearForm() {
        titleField.text = ""
        timeField.text = ""
        servingsField.text = ""
        calField.text = ""
        protField.text = ""
        fatField.text = ""
        carbField.text = ""
        ingredientsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        instructionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        addIngredientRow()
        addInstructionRow()
        imageButton.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        selectedImagePath = nil
    }
    
    private func shakeField(_ field: UIView) {
        let anim = CAKeyframeAnimation(keyPath: "transform.translation.x")
        anim.values = [-10, 10, -5, 5, 0]
        anim.duration = 0.4
        field.layer.add(anim, forKey: "shake")
    }
    
    private static func createTextField(
        placeholder: String,
        keyboard: UIKeyboardType = .default
    ) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.borderStyle = .roundedRect
        tf.keyboardType = keyboard
        tf.backgroundColor = .systemGray6
        return tf
    }
    
    private static func createLabel(text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .boldSystemFont(ofSize: 18)
        return l
    }
}

