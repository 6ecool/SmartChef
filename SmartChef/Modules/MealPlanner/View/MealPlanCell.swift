import UIKit
import SnapKit

class MealPlanCell: UITableViewCell {
    
    static let identifier = "MealPlanCell"
    
    // Клоужер для обработки нажатия на корзину
    var onDelete: (() -> Void)?
    
    private let dishImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.backgroundColor = .systemGray5
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
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()
    
    // Кнопка удаления
    private lazy var deleteButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "trash"), for: .normal)
        btn.tintColor = .systemRed
        btn.addTarget(self, action: #selector(didTapDelete), for: .touchUpInside)
        return btn
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        selectionStyle = .none // Убираем серое выделение при нажатии
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        contentView.addSubview(dishImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(caloriesLabel)
        contentView.addSubview(deleteButton) // Добавляем кнопку
        
        dishImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        // Кнопка удаления справа
        deleteButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40) // Увеличенная зона нажатия
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(dishImageView)
            make.leading.equalTo(dishImageView.snp.trailing).offset(12)
            // Отступаем от кнопки удаления, а не от края экрана
            make.trailing.equalTo(deleteButton.snp.leading).offset(-8)
        }
        
        caloriesLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(titleLabel)
        }
    }
    
    func configure(with item: MealPlanItem) {
        titleLabel.text = item.title
        let servings = item.servings > 0 ? item.servings : 1
        caloriesLabel.text = "🔥 \(item.calories) kcal • 👤 \(servings) pers."
        if let url = item.image {
            dishImageView.loadImage(from: url)
        }
    }
    
    @objc private func didTapDelete() {
        // Вызываем действие удаления
        onDelete?()
    }
}
