import Foundation

struct SearchResponseDTO: Decodable {
    let totalCount: Int
    let incompleteResults: Bool
    let items: [RepositoryDTO]

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
        case items
    }
}

struct RepositoryDTO: Decodable {
    let id: Int
    let name: String
    let fullName: String
    let owner: OwnerDTO
    let description: String?
    let htmlUrl: String
    let stargazersCount: Int
    let language: String?

    enum CodingKeys: String, CodingKey {
        case id, name, owner, description, language
        case fullName = "full_name"
        case htmlUrl = "html_url"
        case stargazersCount = "stargazers_count"
    }
}

struct OwnerDTO: Decodable {
    let login: String
    let avatarUrl: String

    enum CodingKeys: String, CodingKey {
        case login
        case avatarUrl = "avatar_url"
    }
}

// MARK: - Mapping to Entity

extension RepositoryDTO {
    func toEntity() -> Repository {
        Repository(
            id: id,
            name: name,
            ownerName: owner.login,
            avatarUrl: owner.avatarUrl,
            description: description,
            htmlUrl: htmlUrl,
            starCount: stargazersCount,
            language: language
        )
    }
}

extension SearchResponseDTO {
    func toEntity(currentPage: Int, perPage: Int) -> SearchResult {
        let hasNextPage = currentPage * perPage < totalCount
        return SearchResult(
            totalCount: totalCount,
            repositories: items.map { $0.toEntity() },
            hasNextPage: hasNextPage
        )
    }
}
