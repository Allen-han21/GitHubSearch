import Foundation

struct RecentSearch: Codable, Equatable {
    let query: String
    let searchedAt: Date
}
