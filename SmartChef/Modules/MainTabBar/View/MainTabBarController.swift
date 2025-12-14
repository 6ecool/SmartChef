import UIKit

class MainTabBarController: UITabBarController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Сначала настраиваем внешний вид (цвета, фоны)
        setupTabBarAppearance()
        setupNavBarAppearance()
        
        // 2. Потом создаем и добавляем сами вкладки
        setupTabs()
    }
    
    // MARK: - Tab Setup
    
    private func setupTabs() {
        // Инициализация контроллеров
        let discoverVC = DiscoverViewController()
        let favoritesVC = FavoritesViewController()
        let addRecipeVC = AddRecipeViewController()
        let plannerVC = MealPlannerViewController()
        let profileVC = ProfileViewController()
        
        // Оборачиваем их в NavigationController
        let navDiscover = UINavigationController(rootViewController: discoverVC)
        let navFavorites = UINavigationController(rootViewController: favoritesVC)
        let navAdd = UINavigationController(rootViewController: addRecipeVC)
        let navPlanner = UINavigationController(rootViewController: plannerVC)
        let navProfile = UINavigationController(rootViewController: profileVC)
        
        // --- Настройка иконок и названий ---
        
        // 1. Search (Discover)
        navDiscover.tabBarItem = UITabBarItem(
            title: "Search",
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: UIImage(systemName: "text.magnifyingglass")
        )
        
        // 2. Favorites
        navFavorites.tabBarItem = UITabBarItem(
            title: "Favorites",
            image: UIImage(systemName: "heart"),
            selectedImage: UIImage(systemName: "heart.fill")
        )
        
        // 3. Add Recipe (Центральная кнопка)
        navAdd.tabBarItem = UITabBarItem(
            title: nil, // Без текста
            image: UIImage(systemName: "plus.circle"),
            selectedImage: UIImage(systemName: "plus.circle.fill")
        )
        // Сдвигаем иконку чуть ниже, чтобы она была по центру (так как нет текста)
        navAdd.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        
        // 4. Meal Plan
        navPlanner.tabBarItem = UITabBarItem(
            title: "Plan",
            image: UIImage(systemName: "calendar"),
            selectedImage: UIImage(systemName: "calendar.badge.clock")
        )
        
        // 5. Profile
        navProfile.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )
        
        // Добавляем в контроллер
        setViewControllers([navDiscover, navFavorites, navAdd, navPlanner, navProfile], animated: true)
    }
    
    // MARK: - Appearance Setup
    
    // Настройка нижнего меню (ТабБар)
    private func setupTabBarAppearance() {
        tabBar.tintColor = .systemGreen // Цвет активной иконки
        tabBar.unselectedItemTintColor = .systemGray // Цвет неактивной
        tabBar.backgroundColor = .systemBackground
        
        // Исправление прозрачности для iOS 15+
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground() // Делаем фон матовым/белым
            appearance.backgroundColor = .systemBackground
            
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    // Настройка верхнего меню (Навигейшн Бар)
    private func setupNavBarAppearance() {
        // Создаем объект настроек
        let appearance = UINavigationBarAppearance()
        
        // ГЛАВНОЕ: Делаем фон непрозрачным (Opaque)
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground // Белый фон
        appearance.shadowColor = .clear // Убираем тонкую полоску-разделитель (по желанию)
        
        // Настраиваем цвет текста заголовков
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        
        // Применяем настройки ко всем состояниям навбара во всем приложении
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Красим кнопки "Назад" и прочие элементы в зеленый
        UINavigationBar.appearance().tintColor = .systemGreen
    }
}
