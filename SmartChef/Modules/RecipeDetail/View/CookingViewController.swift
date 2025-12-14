import UIKit
import SnapKit

class CookingViewController: UIViewController {
    
    private let steps: [Step]
    private var currentStepIndex = 0
    
    // MARK: - UI Elements
    private let progressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let stepLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold) // Очень крупно
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var nextButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Next Step", for: .normal)
        btn.backgroundColor = .systemGreen
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 12
        btn.titleLabel?.font = .boldSystemFont(ofSize: 18)
        btn.addTarget(self, action: #selector(nextStep), for: .touchUpInside)
        return btn
    }()
    
    private lazy var closeButton: UIButton = {
        let btn = UIButton(type: .close)
        btn.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return btn
    }()
    
    // MARK: - Init
    init(steps: [Step]) {
        self.steps = steps
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        showStep(at: 0)
    }
    
    private func setupUI() {
        view.addSubview(closeButton)
        view.addSubview(progressLabel)
        view.addSubview(stepLabel)
        view.addSubview(nextButton)
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        progressLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.centerX.equalToSuperview()
        }
        
        stepLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        nextButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-30)
            make.leading.trailing.equalToSuperview().inset(40)
            make.height.equalTo(50)
        }
    }
    
    private func showStep(at index: Int) {
        guard index < steps.count else { return }
        let step = steps[index]
        
        progressLabel.text = "Step \(index + 1) of \(steps.count)"
        stepLabel.text = step.step
        
        // Меняем текст кнопки на последнем шаге
        if index == steps.count - 1 {
            nextButton.setTitle("Finish Cooking! 🎉", for: .normal)
            nextButton.backgroundColor = .systemGreen
        } else {
            nextButton.setTitle("Next Step", for: .normal)
            nextButton.backgroundColor = .systemBlue
        }
    }
    
    @objc private func nextStep() {
        if currentStepIndex < steps.count - 1 {
            currentStepIndex += 1
            
            // Анимация перехода
            UIView.transition(with: stepLabel, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.showStep(at: self.currentStepIndex)
            }, completion: nil)
            
        } else {
            // Конец готовки
            dismiss(animated: true)
        }
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}

