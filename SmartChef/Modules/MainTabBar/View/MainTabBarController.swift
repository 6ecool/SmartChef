import UIKit
import SnapKit

class MainTabBarController: UITabBarController {
    private lazy var basketButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .systemGreen
        btn.setImage(UIImage(systemName: "cart.fill"), for: .normal)
        btn.tintColor = .white
        btn.layer.cornerRadius = 28
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOpacity = 0.3
        btn.layer.shadowOffset = CGSize(width: 0, height: 4)
        btn.layer.shadowRadius = 6
        btn.addTarget(self, action: #selector(didTapBasket), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarAppearance()
        setupNavBarAppearance()
        setupTabs()
        setupFloatingButton()
    }
    
    private func setupTabs() {
        let discoverVC = DiscoverViewController()
        let favoritesVC = FavoritesViewController()
        let addRecipeVC = AddRecipeViewController()
        let plannerVC = MealPlannerViewController()
        let profileVC = ProfileViewController()
        let navDiscover = UINavigationController(rootViewController: discoverVC)
        let navFavorites = UINavigationController(rootViewController: favoritesVC)
        let navAdd = UINavigationController(rootViewController: addRecipeVC)
        let navPlanner = UINavigationController(rootViewController: plannerVC)
        let navProfile = UINavigationController(rootViewController: profileVC)
        navDiscover.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), selectedImage: UIImage(systemName: "text.magnifyingglass"))
        navFavorites.tabBarItem = UITabBarItem(title: "Favorites", image: UIImage(systemName: "heart"), selectedImage: UIImage(systemName: "heart.fill"))
        navAdd.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "plus.circle"), selectedImage: UIImage(systemName: "plus.circle.fill"))
        navAdd.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        navPlanner.tabBarItem = UITabBarItem(title: "Plan", image: UIImage(systemName: "calendar"), selectedImage: UIImage(systemName: "calendar.badge.clock"))
        navProfile.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), selectedImage: UIImage(systemName: "person.fill"))
        setViewControllers([navDiscover, navFavorites, navAdd, navPlanner, navProfile], animated: true)
    }
    private func setupFloatingButton() {
        view.addSubview(basketButton)
        basketButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-60)
            make.width.height.equalTo(56)
        }
    }
    
    @objc private func didTapBasket() {
        UIView.animate(withDuration: 0.1, animations: {
            self.basketButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.basketButton.transform = .identity
            }
        }
        let shoppingVC = ShoppingListViewController()
        if let sheet = shoppingVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(shoppingVC, animated: true)
    }
    
    
    
    
    private func setupTabBarAppearance() {
        tabBar.tintColor = .systemGreen
        tabBar.unselectedItemTintColor = .systemGray
        tabBar.backgroundColor = .systemBackground
        
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = .systemBackground
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    private func setupNavBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = .systemGreen
    }
}
