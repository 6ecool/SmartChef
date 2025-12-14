import UIKit
import SnapKit

class DiscoverViewController: UIViewController {
    
    // ViewModel
    private let viewModel = DiscoverViewModel()
    
    // MARK: - UI Elements
    
    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search recipes..."
        sb.backgroundImage = UIImage() // Убираем серую линию
        sb.searchBarStyle = .minimal
        return sb
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = createLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        
        // Подписываемся на делегаты
        cv.delegate = self
        cv.dataSource = self
        
        // Регистрируем ячейки
        cv.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.identifier)
        cv.register(RecipeCardCell.self, forCellWithReuseIdentifier: RecipeCardCell.identifier)
        cv.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderView.identifier)
        
        return cv
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        
        setupUI()
        setupBindings()
        
        // Первая загрузка данных
        viewModel.fetchRecipes()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        // 1. Search Bar
        view.addSubview(searchBar)
        searchBar.delegate = self // <--- ВАЖНО: Подключаем делегат поиска
        
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview().inset(8)
            make.height.equalTo(50)
        }
        
        // 2. Collection View
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupBindings() {
        // Когда ViewModel получает данные, мы обновляем таблицу
        viewModel.onDataUpdated = { [weak self] in
            self?.collectionView.reloadData()
        }
    }
    
    // MARK: - Compositional Layout
    
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, _) -> NSCollectionLayoutSection? in
            if sectionIndex == 0 {
                // Секция 1: Категории (Горизонтальная)
                let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(100), heightDimension: .absolute(40))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(100), heightDimension: .absolute(40))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 20, trailing: 16)
                return section
            } else {
                // Секция 2: Рецепты (Сетка 2 колонки)
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(240))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 6, bottom: 12, trailing: 6)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(240))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 10)
                
                // Header "Popular Recipes"
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                section.boundarySupplementaryItems = [header]
                
                return section
            }
        }
    }
}

// MARK: - Search Bar Delegate (Логика Поиска)
extension DiscoverViewController: UISearchBarDelegate {
    
    // Нажали кнопку "Search" на клавиатуре
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty else { return }
        
        // 1. Скрываем клавиатуру
        searchBar.resignFirstResponder()
        
        // 2. Ищем рецепты через ViewModel
        viewModel.searchRecipes(query: text)
    }
    
    // Нажали "крестик" или стерли текст
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            // Возвращаем список по категориям
            viewModel.fetchRecipes()
            
            // Скрываем клавиатуру с небольшой задержкой
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                searchBar.resignFirstResponder()
            }
        }
    }
}

// MARK: - CollectionView DataSource & Delegate

extension DiscoverViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2 // 0: Категории, 1: Рецепты
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return viewModel.categories.count
        } else {
            return viewModel.recipes.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            // КАТЕГОРИИ
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.identifier, for: indexPath) as! CategoryCell
            let category = viewModel.categories[indexPath.row]
            let isSelected = indexPath.row == viewModel.selectedCategoryIndex
            cell.configure(text: category, isSelected: isSelected)
            return cell
        } else {
            // РЕЦЕПТЫ
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecipeCardCell.identifier, for: indexPath) as! RecipeCardCell
            
            if indexPath.row < viewModel.recipes.count {
                let recipe = viewModel.recipes[indexPath.row]
                cell.configure(with: recipe)
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader && indexPath.section == 1 {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeaderView.identifier, for: indexPath) as! SectionHeaderView
            
            // Меняем заголовок в зависимости от режима (Поиск или Категории)
            if let searchText = searchBar.text, !searchText.isEmpty {
                header.configure(title: "Search Results")
            } else {
                header.configure(title: "Popular Recipes")
            }
            return header
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            // НАЖАТИЕ НА КАТЕГОРИЮ
            viewModel.selectedCategoryIndex = indexPath.row
            
            // Сбрасываем поиск, если был
            searchBar.text = ""
            searchBar.resignFirstResponder()
            
            // Обновляем визуально
            collectionView.reloadSections(IndexSet(integer: 0))
            
            // Загружаем
            viewModel.fetchRecipes()
            
        } else {
            // НАЖАТИЕ НА РЕЦЕПТ
            if indexPath.row < viewModel.recipes.count {
                let selectedRecipe = viewModel.recipes[indexPath.row]
                
                // Открываем экран деталей
                let detailVC = RecipeDetailViewController(recipe: selectedRecipe)
                detailVC.hidesBottomBarWhenPushed = true // Прячем таббар
                navigationController?.pushViewController(detailVC, animated: true)
            }
        }
    }
    
    // Скрываем клавиатуру при скролле
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
}
