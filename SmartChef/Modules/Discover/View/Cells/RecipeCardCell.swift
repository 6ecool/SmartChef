import UIKit
import SnapKit

class RecipeCardCell: UICollectionViewCell {
    static let identifier = "RecipeCardCell"
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .systemGray5
        return iv
    }()
    
    private let timeBadge: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "30 min"
        label.textColor = .white
        label.font = .systemFont(ofSize: 10, weight: .bold)
        return label
    }()
    private let warningBadge: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.systemRed.withAlphaComponent(0.9)
        v.layer.cornerRadius = 15
        v.isHidden = true
        return v
    }()
    
    private let warningIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "exclamationmark.triangle.fill")
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.numberOfLines = 2
        return label
    }()
    
    private let caloriesLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupShadow()
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 6
        layer.masksToBounds = false
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in make.edges.equalToSuperview() }
        
        containerView.addSubview(imageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(caloriesLabel)
        
        imageView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(120)
        }
        
        // Time Badge (слева)
        containerView.addSubview(timeBadge)
        timeBadge.addSubview(timeLabel)
        timeBadge.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(8)
            make.height.equalTo(20)
        }
        timeLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(6)
        }
        
        // Warning Badge (Справа, круглый)
        containerView.addSubview(warningBadge)
        warningBadge.addSubview(warningIcon)
        
        warningBadge.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(8)
            make.width.height.equalTo(30)
        }
        warningIcon.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(16)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(10)
        }
        
        caloriesLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    
    func configure(with recipe: Recipe) {
        titleLabel.text = recipe.title
        timeLabel.text = recipe.readyInMinutes != nil ? "\(recipe.readyInMinutes!) min" : "-- min"
        caloriesLabel.text = "🔥 \(recipe.calories) kcal"
        
        if let imageUrl = recipe.image {
            imageView.loadImage(from: imageUrl)
        } else {
            imageView.image = nil
        }
        
        checkBlacklist(for: recipe)
    }
    
    private func checkBlacklist(for recipe: Recipe) {
        let dislikes = CoreDataManager.shared.getDislikes()
        guard !dislikes.isEmpty else {
            warningBadge.isHidden = true
            return
        }
        
        var searchString = recipe.title.lowercased()
        if let ingredients = recipe.extendedIngredients {
            let ingNames = ingredients.compactMap { $0.name?.lowercased() }
            searchString += " " + ingNames.joined(separator: " ")
        }
        var hasRestrictedItem = false
        for item in dislikes {
            if searchString.contains(item.lowercased()) {
                hasRestrictedItem = true
                break
            }
        }
        
        warningBadge.isHidden = !hasRestrictedItem
    }
}
