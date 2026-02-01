import Foundation

struct SearchResult {
    let totalCount: Int
    let repositories: [Repository]
    let hasNextPage: Bool
}
