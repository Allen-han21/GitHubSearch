import UIKit

final class ImageCache {
    static let shared = ImageCache()

    private let cache = NSCache<NSString, UIImage>()
    private let session: URLSession

    private init() {
        cache.countLimit = 100
        session = URLSession.shared
    }

    func image(for url: URL) async -> UIImage? {
        let key = url.absoluteString as NSString

        if let cachedImage = cache.object(forKey: key) {
            return cachedImage
        }

        do {
            let (data, _) = try await session.data(from: url)
            guard let image = UIImage(data: data) else { return nil }
            cache.setObject(image, forKey: key)
            return image
        } catch {
            return nil
        }
    }

    func clearCache() {
        cache.removeAllObjects()
    }
}
