import UIKit
import SnapKit

class CategoryCell: UICollectionViewCell {
    static let identifier = "CategoryCell"
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(12)
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // Метод для настройки (выбран или нет)
    func configure(text: String, isSelected: Bool) {
        label.text = text
        if isSelected {
            contentView.backgroundColor = .systemGreen
            label.textColor = .white
        } else {
            contentView.backgroundColor = .white
            label.textColor = .black
        }
    }
}
