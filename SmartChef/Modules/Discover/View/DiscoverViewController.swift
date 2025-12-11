// Modules/Discover/View/DiscoverViewController.swift
import UIKit
import SnapKit

class DiscoverViewController: UIViewController {
    
    private let viewModel = DiscoverViewModel()
    
    // UI Elements
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.fetchRecipes() // Просим ViewModel загрузить данные
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    // Связь: Как только ViewModel скажет "готово", мы обновляем таблицу
    private func setupBindings() {
        viewModel.onDataUpdated = { [weak self] in
            self?.tableView.reloadData()
        }
    }
}

// Extension для чистоты кода
extension DiscoverViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let recipe = viewModel.recipes[indexPath.row]
        cell.textLabel?.text = recipe.title // Тут позже будет кастомная ячейка
        return cell
    }
}
