import UIKit
import SnapKit

class CookingViewController: UIViewController {
    
    private let steps: [Step]
    private var currentStepIndex = 0
    
    private lazy var closeButton: UIButton = {
        let btn = UIButton(type: .close)
        btn.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return btn
    }()
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = true
        sv.alwaysBounceVertical = true
        return sv
    }()
    
    private let contentView = UIView()
    
    private let progressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let stepLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()
    
    private lazy var previousButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Previous", for: .normal)
        btn.backgroundColor = .systemGray5
        btn.setTitleColor(.label, for: .normal)
        btn.layer.cornerRadius = 16
        btn.titleLabel?.font = .boldSystemFont(ofSize: 18)
        btn.addTarget(self, action: #selector(prevStep), for: .touchUpInside)
        btn.alpha = 0
        return btn
    }()
    
    private lazy var nextButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Next Step", for: .normal)
        btn.backgroundColor = .systemGreen
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 16
        btn.titleLabel?.font = .boldSystemFont(ofSize: 18)
        btn.addTarget(self, action: #selector(nextStep), for: .touchUpInside)
        return btn
    }()
    
    private let buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.distribution = .fillEqually
        return stack
    }()
    
    init(steps: [Step]) {
        self.steps = steps
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        showStep(at: 0)
    }
    
    private func setupUI() {
        view.addSubview(closeButton)
        view.addSubview(buttonsStack)
        view.addSubview(scrollView)
        
        buttonsStack.addArrangedSubview(previousButton)
        buttonsStack.addArrangedSubview(nextButton)
        
        scrollView.addSubview(contentView)
        contentView.addSubview(progressLabel)
        contentView.addSubview(stepLabel)
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(32)
        }
        
        buttonsStack.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(56)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(closeButton.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(buttonsStack.snp.top).offset(-20)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        progressLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.centerX.equalToSuperview()
        }
        
        stepLabel.snp.makeConstraints { make in
            make.top.equalTo(progressLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().offset(-60)
        }
    }
    
    private func showStep(at index: Int) {
        guard index >= 0 && index < steps.count else { return }
        let step = steps[index]
        
        progressLabel.text = "Step \(index + 1) of \(steps.count)"
        stepLabel.text = step.step
        
        scrollView.setContentOffset(.zero, animated: true)
        
        if index == 0 {
            UIView.animate(withDuration: 0.2) {
                self.previousButton.alpha = 0
                self.previousButton.isEnabled = false
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.previousButton.alpha = 1
                self.previousButton.isEnabled = true
            }
        }
        
        if index == steps.count - 1 {
            nextButton.setTitle("Finish! 🎉", for: .normal)
            nextButton.backgroundColor = .systemGreen
        } else {
            nextButton.setTitle("Next Step", for: .normal)
            nextButton.backgroundColor = .systemBlue
        }
    }
    
    @objc private func nextStep() {
        if currentStepIndex < steps.count - 1 {
            currentStepIndex += 1
            updateStepWithAnimation()
        } else {
            CoreDataManager.shared.incrementCookedCount()
            dismiss(animated: true)
        }
    }
    
    @objc private func prevStep() {
        if currentStepIndex > 0 {
            currentStepIndex -= 1
            updateStepWithAnimation()
        }
    }
    
    private func updateStepWithAnimation() {
        UIView.transition(
            with: stepLabel,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: {
                self.showStep(at: self.currentStepIndex)
            },
            completion: nil
        )
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}

