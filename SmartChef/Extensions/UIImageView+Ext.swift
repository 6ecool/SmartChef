
import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    func loadImage(from urlString: String) {
        self.image = nil
        if urlString.hasPrefix("file://") || urlString.contains("/Documents/") {
            if let image = UIImage(contentsOfFile: urlString.replacingOccurrences(of: "file://", with: "")) {
                self.image = image
                return
            } else if let url = URL(string: urlString), let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                self.image = image
                return
            }
        }
        
        guard let url = URL(string: urlString) else { return }
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            self.image = cachedImage
            return
        }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data, let downloadedImage = UIImage(data: data) else { return }
            imageCache.setObject(downloadedImage, forKey: urlString as NSString)
            DispatchQueue.main.async { self.image = downloadedImage }
        }
        task.resume()
    }
}
