import UIKit
import SnapKit

class FavoritesViewController: UIViewController {
    
    // Массив любимых рецептов
    private var favorites: [Recipe] = []
    
    // MARK: - UI Elements
    private lazy var collectionView: UICollectionView = {
        let layout = createLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.delegate = self
        cv.dataSource = self
        // Переиспользуем ту же ячейку, что и на главном экране
        cv.register(RecipeCardCell.self, forCellWithReuseIdentifier: RecipeCardCell.identifier)
        return cv
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No favorites yet.\nGo add some tasty food! 🍕"
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 16)
        label.isHidden = true
        return label
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Favorites"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        setupUI()
    }
    
    // ВАЖНО: Обновляем список каждый раз, когда открываем экран
    // (вдруг мы удалили что-то на другом экране)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavorites()
    }
    
    private func loadFavorites() {
        // Загружаем из базы
        favorites = CoreDataManager.shared.fetchFavorites()
        collectionView.reloadData()
        
        // Показываем надпись "Пусто", если рецептов нет
        emptyLabel.isHidden = !favorites.isEmpty
        collectionView.isHidden = favorites.isEmpty
    }
    
    private func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(emptyLabel)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    // MARK: - Layout (Сетка 2 колонки)
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(240))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(240))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

// MARK: - DataSource & Delegate
extension FavoritesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favorites.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecipeCardCell.identifier, for: indexPath) as! RecipeCardCell
        let recipe = favorites[indexPath.row]
        
        // Конфигурируем ячейку данными из базы
        cell.configure(with: recipe)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // При нажатии открываем тот же экран деталей
        let recipe = favorites[indexPath.row]
        let detailVC = RecipeDetailViewController(recipe: recipe)
        detailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
