import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(statusCode: Int)
    case networkError(Error)
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .serverError(let statusCode):
            return "Server error: \(statusCode)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
