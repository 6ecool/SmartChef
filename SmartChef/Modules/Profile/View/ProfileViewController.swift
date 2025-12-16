import UIKit
import SnapKit

class ProfileViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    private let contentView = UIView()
    private let headerContainer: UIView = {
        let v = UIView()
        v.backgroundColor = .systemGreen
        v.layer.cornerRadius = 24
        v.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        v.layer.shadowColor = UIColor.systemGreen.cgColor
        v.layer.shadowOpacity = 0.3
        v.layer.shadowOffset = CGSize(width: 0, height: 10)
        v.layer.shadowRadius = 10
        return v
    }()
    
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.crop.circle.fill")
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.borderWidth = 3
        iv.layer.cornerRadius = 40
        iv.clipsToBounds = true
        return iv
    }()
    private let nameLabel: UILabel = {
        let l = UILabel()
        l.text = "Chef"
        l.font = .boldSystemFont(ofSize: 22)
        l.textColor = .white
        return l
    }()
    private let levelLabel: UILabel = {
        let l = UILabel()
        l.text = "Novice • Lvl 1"
        l.font = .systemFont(ofSize: 14, weight: .medium)
        l.textColor = UIColor.white.withAlphaComponent(0.9)
        return l
    }()
    
    
    
    
    private let levelProgress: UIProgressView = {
        let pv = UIProgressView(progressViewStyle: .bar)
        pv.trackTintColor = UIColor.white.withAlphaComponent(0.3)
        pv.progressTintColor = .white
        pv.layer.cornerRadius = 2
        pv.clipsToBounds = true
        return pv
    }()
    private let statsContainer = UIView()
    private let caloriesTitle: UILabel = {
        let l = UILabel()
        l.text = "Today's Nutrition"
        l.font = .boldSystemFont(ofSize: 18)
        return l
    }()
    private let circularProgress = CircularProgressView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
    private let caloriesCountLabel: UILabel = {
        let l = UILabel()
        l.text = "0"
        l.font = .boldSystemFont(ofSize: 28)
        l.textAlignment = .center
        return l
    }()
    private let caloriesGoalLabel: UILabel = {
        let l = UILabel()
        l.text = "/ 2000 kcal"
        l.font = .systemFont(ofSize: 14)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        return l
    }()
    private lazy var editGoalButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "pencil.circle.fill"), for: .normal)
        btn.tintColor = .systemGreen
        btn.addTarget(self, action: #selector(didTapEditGoal), for: .touchUpInside)
        return btn
    }()
    private lazy var cookedStatView = createStatBox(icon: "flame.fill", title: "Cooked", color: .systemOrange)
    private lazy var favStatView = createStatBox(icon: "heart.fill", title: "Favorites", color: .systemRed)
    private lazy var dislikesButton: UIButton = {
        let btn = UIButton(type: .system)
        var config = UIButton.Configuration.gray()
        config.title = "Manage Disliked Ingredients"
        config.subtitle = "These will be warned in recipes"
        config.image = UIImage(systemName: "hand.thumbsdown.fill")
        config.imagePadding = 10
        config.baseForegroundColor = .label
        config.baseBackgroundColor = .systemGray6
        config.cornerStyle = .large
        btn.configuration = config
        btn.contentHorizontalAlignment = .leading
        btn.addTarget(self, action: #selector(didTapDislikes), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateData()
    }
    
    private func updateData() {
        let profile = CoreDataManager.shared.fetchUserProfile()
        let favorites = CoreDataManager.shared.fetchFavorites()
        let todayMeals = CoreDataManager.shared.fetchMealPlan(for: Date())
        updateStatBox(cookedStatView, value: "\(profile.cookedCount)")
        updateStatBox(favStatView, value: "\(favorites.count)")
        let totalCooked = Int(profile.cookedCount)
        let currentLevel = (totalCooked / 5) + 1
        let progressToNext = Float(totalCooked % 5) / 5.0
        var rank = "Novice"
        if currentLevel > 5 { rank = "Sous Chef" }
        if currentLevel > 20 { rank = "Master Chef" }
        levelLabel.text = "\(rank) • Lvl \(currentLevel)"
        levelProgress.setProgress(progressToNext, animated: true)
        var consumedToday = 0
        
        
        
        for meal in todayMeals {
            let totalCals = Double(meal.calories)
            let servings = Double(meal.servings > 0 ? meal.servings : 1)
            let perPerson = totalCals / servings
            consumedToday += Int(perPerson)
        }
        let goal = Int(profile.calorieGoal)
        caloriesCountLabel.text = "\(consumedToday)"
        caloriesGoalLabel.text = "/ \(goal) kcal"
        let progress = Float(consumedToday) / Float(goal)
        circularProgress.setProgress(to: progress)
        if progress > 1.0 {
            circularProgress.progressColor = .systemRed
        } else if progress > 0.8 {
            circularProgress.progressColor = .systemOrange
        } else {
            circularProgress.progressColor = .systemGreen
        }
    }
    
    @objc private func didTapEditGoal() {
        let alert = UIAlertController(title: "Daily Goal", message: "Enter your target calories per day:", preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "e.g. 2000"
            tf.keyboardType = .numberPad
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ in
            if let text = alert.textFields?.first?.text, let newGoal = Int(text) {
                CoreDataManager.shared.updateCalorieGoal(newGoal)
                self?.updateData()
            }
        }))
        present(alert, animated: true)
    }
    
    @objc private func didTapDislikes() {
        let vc = DislikesViewController()
        present(vc, animated: true)
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.contentInsetAdjustmentBehavior = .never
        
        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        contentView.snp.makeConstraints { make in
        make.top.leading.trailing.equalToSuperview()
        make.width.equalToSuperview()
        make.bottom.equalToSuperview().offset(-20)
        }
        contentView.addSubview(headerContainer)
        headerContainer.addSubview(avatarImageView)
        headerContainer.addSubview(nameLabel)
        headerContainer.addSubview(levelLabel)
        headerContainer.addSubview(levelProgress)
        headerContainer.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(260)
        }
        avatarImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(80)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(80)
        }
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
        levelLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        levelProgress.snp.makeConstraints { make in
            make.top.equalTo(levelLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(4)
        }
        contentView.addSubview(caloriesTitle)
        contentView.addSubview(circularProgress)
        contentView.addSubview(editGoalButton)
        circularProgress.addSubview(caloriesCountLabel)
        circularProgress.addSubview(caloriesGoalLabel)
        caloriesTitle.snp.makeConstraints { make in
            make.top.equalTo(headerContainer.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(24)
        }
        editGoalButton.snp.makeConstraints { make in
            make.centerY.equalTo(caloriesTitle)
            make.trailing.equalToSuperview().offset(-24)
            make.width.height.equalTo(44)
        }
        circularProgress.snp.makeConstraints { make in
            make.top.equalTo(caloriesTitle.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(150)
        }
        caloriesCountLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-10)
            make.centerX.equalToSuperview()
        }
        caloriesGoalLabel.snp.makeConstraints { make in
            make.top.equalTo(caloriesCountLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
        let stack = UIStackView(arrangedSubviews: [cookedStatView, favStatView])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 16
        contentView.addSubview(stack)
        
        stack.snp.makeConstraints { make in
            make.top.equalTo(circularProgress.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(90)
        }
        contentView.addSubview(dislikesButton)
        dislikesButton.snp.makeConstraints { make in
            make.top.equalTo(stack.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(60)
            make.bottom.equalToSuperview().offset(-40)
        }
    }
    
    private func createStatBox(icon: String, title: String, color: UIColor) -> UIView {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 16
        // Тень
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.05
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 8
        
        let iconView = UIView()
        iconView.backgroundColor = color.withAlphaComponent(0.1)
        iconView.layer.cornerRadius = 10
        
        let iv = UIImageView(image: UIImage(systemName: icon))
        iv.tintColor = color
        iv.contentMode = .scaleAspectFit
        
        iconView.addSubview(iv)
        iv.snp.makeConstraints { $0.center.equalToSuperview(); $0.width.height.equalTo(18) }
        
        let val = UILabel()
        val.tag = 100
        val.text = "0"
        val.font = .boldSystemFont(ofSize: 22)
        
        let sub = UILabel()
        sub.text = title
        sub.font = .systemFont(ofSize: 13, weight: .medium)
        sub.textColor = .secondaryLabel
        v.addSubview(iconView)
        v.addSubview(val)
        v.addSubview(sub)
        iconView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(12)
            make.width.height.equalTo(32)
        }
        val.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.bottom.equalTo(sub.snp.top).offset(-2)
        }
        sub.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
        }
        return v
    }
    private func updateStatBox(_ view: UIView, value: String) {
        (view.viewWithTag(100) as? UILabel)?.text = value
    }
}
