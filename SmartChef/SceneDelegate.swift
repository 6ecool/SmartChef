import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        // Временно ставим красный фон, чтобы проверить, что все работает
        let vc = UIViewController()
        vc.view.backgroundColor = .red
        
        // Позже здесь будет твой TabBarController
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }
}
