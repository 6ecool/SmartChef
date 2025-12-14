// Extensions/UIImageView+Ext.swift
import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    func loadImage(from urlString: String) {
        // 1. Сбрасываем текущую картинку (чтобы не было "мелькания" старых фото при переиспользовании ячейки)
        self.image = nil
        
        guard let url = URL(string: urlString) else { return }
        
        // 2. Проверяем кэш: если картинка уже скачана, берем её оттуда
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            self.image = cachedImage
            return
        }
        
        // 3. Если нет в кэше — качаем
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  let downloadedImage = UIImage(data: data) else { return }
            
            // 4. Сохраняем в кэш
            imageCache.setObject(downloadedImage, forKey: urlString as NSString)
            
            // 5. Обновляем UI на главном потоке
            DispatchQueue.main.async {
                self.image = downloadedImage
            }
        }
        task.resume()
    }
}
