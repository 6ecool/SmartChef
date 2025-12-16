import UIKit
import SnapKit
import Kingfisher

class RecipeDetailViewController: UIViewController {
    
    var recipe: Recipe
    private var isFavorite: Bool = false
    
    private var originalServings: Int
    private var currentServings: Int
    
    var editingMealPlanItem: MealPlanItem?
    
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
    
    private let whiteContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 30
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
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
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let nutritionStack = UIStackView()
    private let ingredientsStack = UIStackView()
    private let instructionsStack = UIStackView()
    
    private lazy var ingredientsHeader = createHeaderLabel(text: "Ingredients")
    private lazy var instructionsHeader = createHeaderLabel(text: "Instructions")
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
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
    
    private func createHeaderLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }
    
    init(recipe: Recipe, initialServings: Int? = nil) {
        self.recipe = recipe
        self.originalServings = recipe.servings ?? 1
        self.currentServings = initialServings ?? self.originalServings
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        
        isFavorite = CoreDataManager.shared.isFavorite(recipeID: recipe.id)
        updateLikeButtonState()
        configureData()
        if editingMealPlanItem == nil {
            if (recipe.extendedIngredients?.isEmpty ?? true) || recipe.readyInMinutes == 0 {
                fetchFullRecipeDetails()
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func fetchFullRecipeDetails() {
        loadingIndicator.startAnimating()
        NetworkManager.shared.getRecipeInformation(id: recipe.id) { [weak self] result in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
                switch result {
                case .success(let fullRecipe):
                    self?.recipe = fullRecipe
                    if self?.editingMealPlanItem == nil {
                        self?.originalServings = fullRecipe.servings ?? 1
                        self?.currentServings = self?.originalServings ?? 1
                    }
                    self?.configureData()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    private func configureData() {
        if let imageString = recipe.image {
            if imageString.contains("/Documents/") {
                if let image = UIImage(contentsOfFile: imageString) {
                    heroImageView.image = image
                }
            }
            else if let url = URL(string: imageString) {
                heroImageView.kf.setImage(with: url)
            }
        } else {
            heroImageView.image = nil 
        }
        
        titleLabel.text = recipe.title
        timeLabel.text = "⏱ \(recipe.readyInMinutes ?? 0) min"
        
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
        } else {
            let label = UILabel()
            label.text = "Fetching instructions..."
            label.textColor = .secondaryLabel
            instructionsStack.addArrangedSubview(label)
        }
    }
    
    private func updateServingsUI() {
        servingsLabel.text = "\(currentServings) Servings"
        ingredientsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let calculatedIngredients = getCalculatedIngredients()
        
        if calculatedIngredients.isEmpty {
            let label = UILabel()
            label.text = "Ingredients loading..."
            label.textColor = .secondaryLabel
            ingredientsStack.addArrangedSubview(label)
            return
        }
        
        for ing in calculatedIngredients {
            let amount = ing.amount ?? 0
            let formattedAmount = amount.truncatingRemainder(dividingBy: 1) == 0
                ? String(format: "%.0f", amount)
                : String(format: "%.1f", amount)
            
            let text = "\(formattedAmount) \(ing.unit ?? "") \(ing.name ?? "")"
            let row = createIngredientRow(text: text)
            ingredientsStack.addArrangedSubview(row)
        }
    }
    
    private func getCalculatedIngredients() -> [Ingredient] {
        guard let baseIngredients = recipe.extendedIngredients else { return [] }
        
        let ratio = Double(currentServings) / Double(originalServings > 0 ? originalServings : 1)
        
        return baseIngredients.map { ing in
            var newAmount = ing.amount
            if let amount = ing.amount {
                newAmount = amount * ratio
            }
            return Ingredient(id: ing.id, name: ing.name, original: ing.original, amount: newAmount, unit: ing.unit)
        }
    }
    
    private func autoSaveIfEditing() {
        if let item = editingMealPlanItem {
            let nutrients = recipe.nutrition?.nutrients ?? []
            let baseCals = nutrients.first(where: { $0.name == "Calories" })?.amount ?? Double(recipe.calories)
            
            CoreDataManager.shared.updateMealPlanItem(item, newServings: currentServings, baseCals: baseCals)
            
            let gen = UISelectionFeedbackGenerator()
            gen.selectionChanged()
        }
    }
    
    @objc private func increaseServings() {
        currentServings += 1
        updateServingsUI()
        setupNutrition()
        autoSaveIfEditing()
    }
    
    @objc private func decreaseServings() {
        if currentServings > 1 {
            currentServings -= 1
            updateServingsUI()
            setupNutrition()
            autoSaveIfEditing()
        }
    }
    
    @objc private func didTapBack() { navigationController?.popViewController(animated: true) }
    
    @objc private func didTapPlan() {
        let vc = AddMealPlanViewController()
        vc.delegate = self
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
    }
    @objc private func didTapStartCooking() {
        guard let steps = recipe.analyzedInstructions?.first?.steps, !steps.isEmpty else {
            let alert = UIAlertController(title: "Oops", message: "No steps available.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        let cookingVC = CookingViewController(steps: steps)
        cookingVC.modalPresentationStyle = .fullScreen
        present(cookingVC, animated: true)
    }
    
    private func setupNutrition() {
        nutritionStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let nutrients = recipe.nutrition?.nutrients ?? []
        
        let ratio = Double(currentServings) / Double(originalServings > 0 ? originalServings : 1)
        
        let cal = (nutrients.first(where: { $0.name == "Calories" })?.amount ?? Double(recipe.calories)) * ratio
        let pro = (nutrients.first(where: { $0.name == "Protein" })?.amount ?? 0) * ratio
        let fat = (nutrients.first(where: { $0.name == "Fat" })?.amount ?? 0) * ratio
        let carb = (nutrients.first(where: { $0.name == "Carbohydrates" })?.amount ?? 0) * ratio
        
        let items = [
            ("Calories", "\(Int(cal))"),
            ("Protein", "\(Int(pro))g"),
            ("Fat", "\(Int(fat))g"),
            ("Carbs", "\(Int(carb))g")
        ]
        
        for item in items {
            let v = UIView()
            v.backgroundColor = .systemGray6; v.layer.cornerRadius = 16
            let val = UILabel(); val.text = item.1; val.font = .boldSystemFont(ofSize: 16); val.textColor = .systemGreen
            let name = UILabel(); name.text = item.0; name.font = .systemFont(ofSize: 12); name.textColor = .secondaryLabel
            let s = UIStackView(arrangedSubviews: [val, name]); s.axis = .vertical; s.alignment = .center; s.spacing = 2
            v.addSubview(s); s.snp.makeConstraints { $0.center.equalToSuperview() }
            nutritionStack.addArrangedSubview(v)
        }
    }
    
    private func createIngredientRow(text: String) -> UIView {
        let v = UIView()
        let d = UIView(); d.backgroundColor = .clear; d.layer.borderWidth = 2; d.layer.borderColor = UIColor.systemGreen.cgColor; d.layer.cornerRadius = 6
        let l = UILabel(); l.text = text; l.numberOfLines = 0; l.font = .systemFont(ofSize: 16)
        v.addSubview(d); v.addSubview(l)
        d.snp.makeConstraints { $0.leading.top.equalToSuperview().offset(4); $0.width.height.equalTo(12) }
        l.snp.makeConstraints { $0.leading.equalTo(d.snp.trailing).offset(12); $0.top.bottom.trailing.equalToSuperview() }
        return v
    }
    
    @objc private func didTapLike() {
        let gen = UIImpactFeedbackGenerator(style: .medium); gen.impactOccurred()
        UIView.animate(withDuration: 0.1, animations: { self.likeButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2) }) { _ in
                UIView.animate(withDuration: 0.1) { self.likeButton.transform = .identity }
        }
        if recipe.id < 0 {
            showDeleteConfirmation()
        } else {
            if isFavorite {
                CoreDataManager.shared.deleteFavorite(recipeID: recipe.id)
                isFavorite = false
            } else {
                CoreDataManager.shared.saveFavorite(recipe: recipe)
                isFavorite = true
            }
            updateLikeButtonState()
        }
    }
        
        private func showDeleteConfirmation() {
            let alert = UIAlertController(
                title: "Delete Recipe?",
                message: "This is your custom recipe. Unliking it will permanently delete it.",
                preferredStyle: .actionSheet
            )
            
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
                guard let self = self else { return }
                CoreDataManager.shared.deleteUserRecipe(recipeID: self.recipe.id)
                self.navigationController?.popViewController(animated: true)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            present(alert, animated: true)
        }
    
    private func createInstructionRow(number: Int, text: String) -> UIView {
        let v = UIView()
        let n = UILabel(); n.text = "\(number)"; n.font = .boldSystemFont(ofSize: 14); n.textColor = .white; n.textAlignment = .center; n.backgroundColor = .systemGreen; n.layer.cornerRadius = 12; n.clipsToBounds = true
        let l = UILabel(); l.text = text; l.numberOfLines = 0; l.font = .systemFont(ofSize: 16)
        v.addSubview(n); v.addSubview(l)
        n.snp.makeConstraints { $0.leading.top.equalToSuperview(); $0.width.height.equalTo(24) }
        l.snp.makeConstraints { $0.leading.equalTo(n.snp.trailing).offset(12); $0.top.bottom.trailing.equalToSuperview() }
        return v
    }
    
    private func updateLikeButtonState() {
        let img = isFavorite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        likeButton.setImage(img, for: .normal)
        likeButton.tintColor = isFavorite ? .systemRed : .white
    }
    private func setupUI() {
        view.addSubview(scrollView); scrollView.snp.makeConstraints { $0.top.leading.trailing.equalToSuperview(); $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-80) }
        scrollView.addSubview(contentView); contentView.snp.makeConstraints { $0.edges.width.equalToSuperview() }
        contentView.addSubview(heroImageView); heroImageView.snp.makeConstraints { $0.top.leading.trailing.equalToSuperview(); $0.height.equalTo(320) }
        
        view.addSubview(backButton); backButton.snp.makeConstraints { $0.top.equalTo(view.safeAreaLayoutGuide).offset(10); $0.leading.equalToSuperview().offset(16); $0.width.height.equalTo(40) }
        view.addSubview(likeButton); likeButton.snp.makeConstraints { $0.top.equalTo(backButton); $0.trailing.equalToSuperview().offset(-16); $0.width.height.equalTo(40) }
        view.addSubview(planButton); planButton.snp.makeConstraints { $0.top.equalTo(backButton); $0.trailing.equalTo(likeButton.snp.leading).offset(-12); $0.width.height.equalTo(40) }
        
        contentView.addSubview(whiteContainer); whiteContainer.snp.makeConstraints { $0.top.equalTo(heroImageView.snp.bottom).offset(-40); $0.leading.trailing.bottom.equalToSuperview() }
        
        whiteContainer.addSubview(loadingIndicator); loadingIndicator.snp.makeConstraints { $0.top.equalTo(whiteContainer).offset(20); $0.centerX.equalToSuperview() }
        
        whiteContainer.addSubview(titleLabel); titleLabel.snp.makeConstraints { $0.top.equalToSuperview().offset(30); $0.leading.trailing.equalToSuperview().inset(24) }
        whiteContainer.addSubview(timeLabel); timeLabel.snp.makeConstraints { $0.top.equalTo(titleLabel.snp.bottom).offset(8); $0.leading.trailing.equalToSuperview().inset(24) }
        
        whiteContainer.addSubview(nutritionStack); nutritionStack.axis = .horizontal; nutritionStack.distribution = .fillEqually; nutritionStack.spacing = 12
        nutritionStack.snp.makeConstraints { $0.top.equalTo(timeLabel.snp.bottom).offset(24); $0.leading.trailing.equalToSuperview().inset(24); $0.height.equalTo(70) }
        
        whiteContainer.addSubview(servingsContainer)
        servingsContainer.snp.makeConstraints { $0.top.equalTo(nutritionStack.snp.bottom).offset(24); $0.centerX.equalToSuperview(); $0.width.equalTo(160); $0.height.equalTo(40) }
        servingsContainer.addSubview(minusButton); minusButton.snp.makeConstraints { $0.leading.top.bottom.equalToSuperview(); $0.width.equalTo(40) }
        servingsContainer.addSubview(plusButton); plusButton.snp.makeConstraints { $0.trailing.top.bottom.equalToSuperview(); $0.width.equalTo(40) }
        servingsContainer.addSubview(servingsLabel); servingsLabel.snp.makeConstraints { $0.center.equalToSuperview() }
        
        whiteContainer.addSubview(ingredientsHeader); ingredientsHeader.snp.makeConstraints { $0.top.equalTo(servingsContainer.snp.bottom).offset(32); $0.leading.trailing.equalToSuperview().inset(24) }
        whiteContainer.addSubview(ingredientsStack); ingredientsStack.axis = .vertical; ingredientsStack.spacing = 12
        ingredientsStack.snp.makeConstraints { $0.top.equalTo(ingredientsHeader.snp.bottom).offset(16); $0.leading.trailing.equalToSuperview().inset(24) }
        
        whiteContainer.addSubview(instructionsHeader); instructionsHeader.snp.makeConstraints { $0.top.equalTo(ingredientsStack.snp.bottom).offset(32); $0.leading.trailing.equalToSuperview().inset(24) }
        whiteContainer.addSubview(instructionsStack); instructionsStack.axis = .vertical; instructionsStack.spacing = 16
        instructionsStack.snp.makeConstraints { $0.top.equalTo(instructionsHeader.snp.bottom).offset(16); $0.leading.trailing.equalToSuperview().inset(24); $0.bottom.equalToSuperview().offset(-40) }
        
        view.addSubview(bottomButtonContainer); bottomButtonContainer.contentView.addSubview(cookButton)
        bottomButtonContainer.snp.makeConstraints { $0.leading.trailing.bottom.equalToSuperview(); $0.height.equalTo(100) }
        cookButton.snp.makeConstraints { $0.top.equalToSuperview().offset(16); $0.leading.trailing.equalToSuperview().inset(20); $0.height.equalTo(54) }
    }
}

extension RecipeDetailViewController: AddMealPlanDelegate {
    func didSaveMealPlan(date: Date, mealType: String) {
        CoreDataManager.shared.addToMealPlan(
            recipe: recipe,
            date: date,
            mealType: mealType,
            targetServings: currentServings,
            baseServings: originalServings
        )
        
        let gen = UINotificationFeedbackGenerator(); gen.notificationOccurred(.success)
        let alert = UIAlertController(title: "Saved!", message: "Plan added.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
