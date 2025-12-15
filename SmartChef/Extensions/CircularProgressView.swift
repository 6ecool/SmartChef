import UIKit

class CircularProgressView: UIView {
    
    private let progressLayer = CAShapeLayer()
    private let trackLayer = CAShapeLayer()
    
    var progressColor: UIColor = .systemGreen {
        didSet { progressLayer.strokeColor = progressColor.cgColor }
    }
    
    var trackColor: UIColor = .systemGray5 {
        didSet { trackLayer.strokeColor = trackColor.cgColor }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }
    
    private func setupLayers() {
        // Настраиваем слои один раз при инициализации
        
        // Track (фон)
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = 12
        trackLayer.lineCap = .round
        layer.addSublayer(trackLayer)
        
        // Progress (значение)
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = 12
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        layer.addSublayer(progressLayer)
    }
    
    // Обновляем только путь (геометрию), не пересоздавая слои
    private func updatePath() {
        let centerPoint = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let circleRadius = (min(bounds.width, bounds.height) - 12) / 2
        
        let circularPath = UIBezierPath(arcCenter: centerPoint, radius: circleRadius, startAngle: -CGFloat.pi / 2, endAngle: 1.5 * CGFloat.pi, clockwise: true)
        
        trackLayer.path = circularPath.cgPath
        progressLayer.path = circularPath.cgPath
    }
    
    func setProgress(to value: Float, animated: Bool = true) {
        let clampedValue = max(0.0, min(value, 1.0))
        
        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.duration = 0.5
            animation.fromValue = progressLayer.strokeEnd
            animation.toValue = clampedValue
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            progressLayer.strokeEnd = CGFloat(clampedValue)
            progressLayer.add(animation, forKey: "animateProgress")
        } else {
            progressLayer.strokeEnd = CGFloat(clampedValue)
        }
    }
    
    // Вызывается при изменении размеров (AutoLayout)
    override func layoutSubviews() {
        super.layoutSubviews()
        updatePath() // Просто обновляем путь
    }
}
