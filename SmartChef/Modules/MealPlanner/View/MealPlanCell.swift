import UIKit
import SnapKit

class MealPlanCell: UITableViewCell {
    
    static let identifier = "MealPlanCell"
    
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        contentView.addSubview(dishImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(caloriesLabel)
        
        dishImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(dishImageView)
            make.leading.equalTo(dishImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        caloriesLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(titleLabel)
        }
    }
    
    func configure(with item: MealPlanItem) {
        titleLabel.text = item.title
        caloriesLabel.text = "🔥 \(item.calories) kcal"
        if let url = item.image {
            dishImageView.loadImage(from: url)
        }
    }
}
