import UIKit
import SnapKit

class RecipeDetailViewController: UIViewController {
    
    private let recipe: Recipe
    private var isFavorite: Bool = false
    
    // Логика порций
    private var originalServings: Int
    private var currentServings: Int
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()
    
    private let contentView = UIView()
    
    private let heroImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .systemGray5
        return iv
    }()
    
    // Buttons
    private lazy var backButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        btn.layer.cornerRadius = 20
        btn.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        return btn
    }()
    
    private lazy var likeButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "heart"), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        btn.layer.cornerRadius = 20
        btn.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        return btn
    }()
    
    private lazy var planButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "calendar.badge.plus"), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        btn.layer.cornerRadius = 20
        btn.addTarget(self, action: #selector(didTapPlan), for: .touchUpInside)
        return btn
    }()
    
    // White Container
    private let whiteContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 30
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: -4)
        view.layer.shadowRadius = 10
        return view
    }()
    
    // Labels
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()
    
    // --- STEPPER UI ---
    private let servingsContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 12
        return view
    }()
    
    private lazy var minusButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("−", for: .normal)
        btn.setTitleColor(.label, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        btn.addTarget(self, action: #selector(decreaseServings), for: .touchUpInside)
        return btn
    }()
    
    private lazy var plusButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("+", for: .normal)
        btn.setTitleColor(.label, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        btn.addTarget(self, action: #selector(increaseServings), for: .touchUpInside)
        return btn
    }()
    
    private let servingsLabel: UILabel = {
        let label = UILabel()
        label.text = "2 Servings"
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    // ------------------
    
    private let nutritionStack = UIStackView()
    private let ingredientsStack = UIStackView()
    private let instructionsStack = UIStackView()
    
    private lazy var ingredientsHeader = createHeaderLabel(text: "Ingredients")
    private lazy var instructionsHeader = createHeaderLabel(text: "Instructions")
    
    private func createHeaderLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }
    
    // Bottom Panel
    private let bottomButtonContainer: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemChromeMaterial)
        return UIVisualEffectView(effect: blur)
    }()
    
    private lazy var cookButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Start Cooking", for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 18)
        btn.backgroundColor = .systemGreen
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 16
        btn.addTarget(self, action: #selector(didTapStartCooking), for: .touchUpInside)
        return btn
    }()
    
    // MARK: - Init
    init(recipe: Recipe) {
        self.recipe = recipe
        self.originalServings = recipe.servings ?? 2
        self.currentServings = self.originalServings
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        configureData()
        
        isFavorite = CoreDataManager.shared.isFavorite(recipeID: recipe.id)
        updateLikeButtonState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-80)
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
        }
        
        contentView.addSubview(heroImageView)
        heroImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(320)
        }
        
        view.addSubview(backButton)
        view.addSubview(likeButton)
        view.addSubview(planButton)
        
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(40)
        }
        
        likeButton.snp.makeConstraints { make in
            make.top.equalTo(backButton)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(40)
        }
        
        planButton.snp.makeConstraints { make in
            make.top.equalTo(backButton)
            make.trailing.equalTo(likeButton.snp.leading).offset(-12)
            make.width.height.equalTo(40)
        }
        
        contentView.addSubview(whiteContainer)
        whiteContainer.snp.makeConstraints { make in
            make.top.equalTo(heroImageView.snp.bottom).offset(-40)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        // Добавляем элементы
        whiteContainer.addSubview(titleLabel)
        whiteContainer.addSubview(timeLabel)
        whiteContainer.addSubview(nutritionStack)
        
        // Stepper
        whiteContainer.addSubview(servingsContainer)
        servingsContainer.addSubview(minusButton)
        servingsContainer.addSubview(servingsLabel)
        servingsContainer.addSubview(plusButton)
        
        whiteContainer.addSubview(ingredientsHeader)
        whiteContainer.addSubview(ingredientsStack)
        whiteContainer.addSubview(instructionsHeader)
        whiteContainer.addSubview(instructionsStack)
        
        // Constraints
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        nutritionStack.axis = .horizontal
        nutritionStack.distribution = .fillEqually
        nutritionStack.spacing = 12
        nutritionStack.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(70)
        }
        
        // Stepper Constraints
        servingsContainer.snp.makeConstraints { make in
            make.top.equalTo(nutritionStack.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.width.equalTo(160)
            make.height.equalTo(40)
        }
        
        minusButton.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(40)
        }
        
        plusButton.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview()
            make.width.equalTo(40)
        }
        
        servingsLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        // Остальные элементы
        ingredientsHeader.snp.makeConstraints { make in
            make.top.equalTo(servingsContainer.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        ingredientsStack.axis = .vertical
        ingredientsStack.spacing = 12
        ingredientsStack.snp.makeConstraints { make in
            make.top.equalTo(ingredientsHeader.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        instructionsHeader.snp.makeConstraints { make in
            make.top.equalTo(ingredientsStack.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        instructionsStack.axis = .vertical
        instructionsStack.spacing = 16
        instructionsStack.snp.makeConstraints { make in
            make.top.equalTo(instructionsHeader.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().offset(-40)
        }
        
        // Bottom Button
        view.addSubview(bottomButtonContainer)
        bottomButtonContainer.contentView.addSubview(cookButton)
        bottomButtonContainer.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(100)
        }
        cookButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(54)
        }
    }
    
    // MARK: - Logic & Config
    
    private func configureData() {
        if let url = recipe.image { heroImageView.loadImage(from: url) }
        titleLabel.text = recipe.title
        timeLabel.text = "⏱ \(recipe.readyInMinutes ?? 0) min"
        
        // Вот здесь мы вызываем восстановленный метод
        setupNutrition()
        updateServingsUI()
        
        instructionsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if let steps = recipe.analyzedInstructions?.first?.steps, !steps.isEmpty {
            for step in steps {
                let row = createInstructionRow(number: step.number, text: step.step)
                instructionsStack.addArrangedSubview(row)
            }
        } else if let summary = recipe.summary {
            let clean = summary.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
            let label = UILabel()
            label.text = clean
            label.numberOfLines = 0
            label.font = .systemFont(ofSize: 16)
            instructionsStack.addArrangedSubview(label)
        }
    }
    
    private func updateServingsUI() {
        servingsLabel.text = "\(currentServings) Servings"
        ingredientsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        guard let ingredients = recipe.extendedIngredients else { return }
        
        for ing in ingredients {
            var text = ing.original ?? ing.name ?? ""
            if let amount = ing.amount, let unit = ing.unit, originalServings > 0 {
                let newAmount = (amount / Double(originalServings)) * Double(currentServings)
                let formattedAmount = String(format: "%.1f", newAmount)
                text = "\(formattedAmount) \(unit) \(ing.name ?? "")"
            }
            let row = createIngredientRow(text: text)
            ingredientsStack.addArrangedSubview(row)
        }
    }
    
    @objc private func increaseServings() {
        currentServings += 1
        updateServingsUI()
    }
    
    @objc private func decreaseServings() {
        if currentServings > 1 {
            currentServings -= 1
            updateServingsUI()
        }
    }
    
    // MARK: - Helper Views (ВОССТАНОВЛЕННЫЕ)
    
    private func setupNutrition() {
        let items = [
            ("Calories", "\(recipe.calories)"),
            ("Protein", recipe.protein),
            ("Fat", recipe.fat),
            ("Carbs", recipe.carbs)
        ]
        
        for item in items {
            let view = UIView()
            view.backgroundColor = .systemGray6
            view.layer.cornerRadius = 16
            
            let val = UILabel()
            val.text = item.1
            val.font = .systemFont(ofSize: 16, weight: .bold)
            val.textColor = .systemGreen
            
            let name = UILabel()
            name.text = item.0
            name.font = .systemFont(ofSize: 12, weight: .medium)
            name.textColor = .secondaryLabel
            
            let stack = UIStackView(arrangedSubviews: [val, name])
            stack.axis = .vertical
            stack.alignment = .center
            stack.spacing = 2
            
            view.addSubview(stack)
            stack.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
            nutritionStack.addArrangedSubview(view)
        }
    }
    
    private func createIngredientRow(text: String) -> UIView {
        let view = UIView()
        let dot = UIView()
        dot.backgroundColor = .clear; dot.layer.borderWidth = 2
        dot.layer.borderColor = UIColor.systemGreen.cgColor; dot.layer.cornerRadius = 6
        let label = UILabel(); label.text = text; label.numberOfLines = 0; label.font = .systemFont(ofSize: 16)
        
        view.addSubview(dot); view.addSubview(label)
        dot.snp.makeConstraints { make in make.leading.top.equalToSuperview().offset(4); make.width.height.equalTo(12) }
        label.snp.makeConstraints { make in make.leading.equalTo(dot.snp.trailing).offset(12); make.top.bottom.trailing.equalToSuperview() }
        return view
    }
    
    private func createInstructionRow(number: Int, text: String) -> UIView {
        let view = UIView()
        let numLabel = UILabel()
        numLabel.text = "\(number)"
        numLabel.font = .boldSystemFont(ofSize: 14)
        numLabel.textColor = .white
        numLabel.textAlignment = .center
        numLabel.backgroundColor = .systemGreen
        numLabel.layer.cornerRadius = 12
        numLabel.clipsToBounds = true
        
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16)
        
        view.addSubview(numLabel); view.addSubview(label)
        numLabel.snp.makeConstraints { make in make.leading.top.equalToSuperview(); make.width.height.equalTo(24) }
        label.snp.makeConstraints { make in make.leading.equalTo(numLabel.snp.trailing).offset(12); make.top.bottom.trailing.equalToSuperview() }
        return view
    }
    
    private func updateLikeButtonState() {
        let image = isFavorite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        let color: UIColor = isFavorite ? .systemRed : .white
        likeButton.setImage(image, for: .normal)
        likeButton.tintColor = color
    }
    
    // MARK: - Actions
    @objc private func didTapBack() { navigationController?.popViewController(animated: true) }
    
    @objc private func didTapPlan() {
        let vc = AddMealPlanViewController()
        vc.delegate = self
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
    }
    
    @objc private func didTapLike() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        UIView.animate(withDuration: 0.1, animations: { self.likeButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2) }) { _ in
            UIView.animate(withDuration: 0.1) { self.likeButton.transform = .identity }
        }
        
        if isFavorite {
            CoreDataManager.shared.deleteFavorite(recipeID: recipe.id)
            isFavorite = false
        } else {
            CoreDataManager.shared.saveFavorite(recipe: recipe)
            isFavorite = true
        }
        updateLikeButtonState()
    }
    
    @objc private func didTapStartCooking() {
        guard let steps = recipe.analyzedInstructions?.first?.steps, !steps.isEmpty else {
            let alert = UIAlertController(title: "Oops", message: "No step-by-step instructions.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        let cookingVC = CookingViewController(steps: steps)
        cookingVC.modalPresentationStyle = .fullScreen
        present(cookingVC, animated: true)
    }
}

// MARK: - Extension
extension RecipeDetailViewController: AddMealPlanDelegate {
    func didSaveMealPlan(date: Date, mealType: String) {
        CoreDataManager.shared.addToMealPlan(recipe: recipe, date: date, mealType: mealType)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        let dateString = formatter.string(from: date)
        
        let alert = UIAlertController(title: "Success", message: "Added to \(mealType) on \(dateString)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
