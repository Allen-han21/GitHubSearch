import UIKit

actor ImageCache {
    static let shared = ImageCache()

    private let cache = NSCache<NSString, UIImage>()
    private let session: URLSession
    private var inFlightRequests: [URL: Task<UIImage?, Never>] = [:]

    private init() {
        cache.countLimit = 100
        session = URLSession.shared
    }

    func image(for url: URL) async -> UIImage? {
        let key = url.absoluteString as NSString

        // 캐시 체크
        if let cachedImage = cache.object(forKey: key) {
            return cachedImage
        }

        // 진행 중인 요청 확인
        if let existingTask = inFlightRequests[url] {
            return await existingTask.value
        }

        // 새 Task 생성
        let task = Task<UIImage?, Never> {
            do {
                let (data, _) = try await session.data(from: url)
                guard let image = UIImage(data: data) else { return nil }
                return image
            } catch {
                return nil
            }
        }

        inFlightRequests[url] = task

        let result = await task.value

        // 캐시에 저장 및 정리
        if let image = result {
            cache.setObject(image, forKey: key)
        }
        inFlightRequests.removeValue(forKey: url)

        return result
    }

    func clearCache() {
        cache.removeAllObjects()
    }
}
