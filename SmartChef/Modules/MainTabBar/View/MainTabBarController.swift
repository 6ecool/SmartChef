// Modules/MainTabBar/MainTabBarController.swift
import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        tabBar.tintColor = .systemGreen // Цвет активной иконки
        tabBar.backgroundColor = .systemBackground
    }
    
    private func setupTabs() {
        let discoverVC = DiscoverViewController() // Пока пустые
        let plannerVC = MealPlannerViewController()
        let profileVC = ProfileViewController()
        
        // Оборачиваем в NavigationController, чтобы работал push (переходы)
        let nav1 = UINavigationController(rootViewController: discoverVC)
        let nav2 = UINavigationController(rootViewController: plannerVC)
        let nav3 = UINavigationController(rootViewController: profileVC)
        
        nav1.tabBarItem = UITabBarItem(title: "Discover", image: UIImage(systemName: "magnifyingglass"), tag: 0)
        nav2.tabBarItem = UITabBarItem(title: "Meal Plan", image: UIImage(systemName: "list.bullet.clipboard"), tag: 1)
        nav3.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 2)
        
        setViewControllers([nav1, nav2, nav3], animated: true)
    }
}
