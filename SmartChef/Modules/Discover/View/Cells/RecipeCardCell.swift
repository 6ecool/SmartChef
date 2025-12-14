import UIKit
import SnapKit

class RecipeCardCell: UICollectionViewCell {
    static let identifier = "RecipeCardCell"
    
    // MARK: - UI Elements
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
        iv.backgroundColor = .systemGray5 // Заглушка
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
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupShadow()
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupShadow() {
        // Тень накладываем на саму ячейку (layer), не на contentView
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 6
        layer.masksToBounds = false
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.addSubview(imageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(caloriesLabel)
        
        imageView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(120) // Высота картинки
        }
        
        // Бейдж со временем поверх картинки
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
        
        // Время (если пришло nil, ставим прочерк)
        if let minutes = recipe.readyInMinutes {
            timeLabel.text = "\(minutes) min"
        } else {
            timeLabel.text = "-- min"
        }
        
        // Калории (используем наш хелпер)
        caloriesLabel.text = "🔥 \(recipe.calories) kcal"
        
        // Загрузка картинки
        if let imageUrl = recipe.image {
            imageView.loadImage(from: imageUrl) // Используем наш extension
        } else {
            imageView.image = nil // Или картинка-заглушка
        }
    }
}
