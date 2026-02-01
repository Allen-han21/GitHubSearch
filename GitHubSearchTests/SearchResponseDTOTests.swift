import XCTest
@testable import GitHubSearch

final class SearchResponseDTOTests: XCTestCase {

    // MARK: - JSON Decoding Tests

    func test_GitHub_API_응답_JSON을_정상적으로_디코딩한다() throws {
        let json = """
        {
            "total_count": 1000,
            "incomplete_results": false,
            "items": [
                {
                    "id": 1234,
                    "name": "swift",
                    "full_name": "apple/swift",
                    "owner": {
                        "login": "apple",
                        "avatar_url": "https://avatars.githubusercontent.com/u/10639145"
                    },
                    "description": "The Swift Programming Language",
                    "html_url": "https://github.com/apple/swift",
                    "stargazers_count": 67000,
                    "language": "C++"
                }
            ]
        }
        """
        let data = Data(json.utf8)
        let decoder = JSONDecoder()

        let response = try decoder.decode(SearchResponseDTO.self, from: data)

        XCTAssertEqual(response.totalCount, 1000)
        XCTAssertFalse(response.incompleteResults)
        XCTAssertEqual(response.items.count, 1)
    }

    func test_RepositoryDTO가_올바르게_디코딩된다() throws {
        let json = """
        {
            "id": 1234,
            "name": "swift",
            "full_name": "apple/swift",
            "owner": {
                "login": "apple",
                "avatar_url": "https://avatars.githubusercontent.com/u/10639145"
            },
            "description": "The Swift Programming Language",
            "html_url": "https://github.com/apple/swift",
            "stargazers_count": 67000,
            "language": "C++"
        }
        """
        let data = Data(json.utf8)
        let decoder = JSONDecoder()

        let repo = try decoder.decode(RepositoryDTO.self, from: data)

        XCTAssertEqual(repo.id, 1234)
        XCTAssertEqual(repo.name, "swift")
        XCTAssertEqual(repo.fullName, "apple/swift")
        XCTAssertEqual(repo.owner.login, "apple")
        XCTAssertEqual(repo.stargazersCount, 67000)
        XCTAssertEqual(repo.language, "C++")
    }

    func test_description이_null이면_nil로_디코딩된다() throws {
        let json = """
        {
            "id": 1234,
            "name": "test",
            "full_name": "owner/test",
            "owner": {
                "login": "owner",
                "avatar_url": "https://example.com/avatar.png"
            },
            "description": null,
            "html_url": "https://github.com/owner/test",
            "stargazers_count": 0,
            "language": null
        }
        """
        let data = Data(json.utf8)
        let decoder = JSONDecoder()

        let repo = try decoder.decode(RepositoryDTO.self, from: data)

        XCTAssertNil(repo.description)
        XCTAssertNil(repo.language)
    }

    // MARK: - Entity Mapping Tests

    func test_RepositoryDTO를_Repository_Entity로_변환한다() throws {
        let json = """
        {
            "id": 1234,
            "name": "swift",
            "full_name": "apple/swift",
            "owner": {
                "login": "apple",
                "avatar_url": "https://avatars.githubusercontent.com/u/10639145"
            },
            "description": "The Swift Programming Language",
            "html_url": "https://github.com/apple/swift",
            "stargazers_count": 67000,
            "language": "C++"
        }
        """
        let data = Data(json.utf8)
        let dto = try JSONDecoder().decode(RepositoryDTO.self, from: data)

        let entity = dto.toEntity()

        XCTAssertEqual(entity.id, 1234)
        XCTAssertEqual(entity.name, "swift")
        XCTAssertEqual(entity.ownerName, "apple")
        XCTAssertEqual(entity.avatarUrl, "https://avatars.githubusercontent.com/u/10639145")
        XCTAssertEqual(entity.description, "The Swift Programming Language")
        XCTAssertEqual(entity.htmlUrl, "https://github.com/apple/swift")
        XCTAssertEqual(entity.starCount, 67000)
        XCTAssertEqual(entity.language, "C++")
    }

    func test_SearchResponseDTO를_SearchResult_Entity로_변환한다() throws {
        let json = """
        {
            "total_count": 100,
            "incomplete_results": false,
            "items": [
                {
                    "id": 1,
                    "name": "repo1",
                    "full_name": "owner/repo1",
                    "owner": { "login": "owner", "avatar_url": "https://example.com/1.png" },
                    "description": "Desc 1",
                    "html_url": "https://github.com/owner/repo1",
                    "stargazers_count": 10,
                    "language": "Swift"
                }
            ]
        }
        """
        let data = Data(json.utf8)
        let dto = try JSONDecoder().decode(SearchResponseDTO.self, from: data)

        let entity = dto.toEntity(currentPage: 1, perPage: 30)

        XCTAssertEqual(entity.totalCount, 100)
        XCTAssertEqual(entity.repositories.count, 1)
        XCTAssertTrue(entity.hasNextPage)
    }

    func test_마지막_페이지면_hasNextPage가_false이다() throws {
        let json = """
        {
            "total_count": 25,
            "incomplete_results": false,
            "items": []
        }
        """
        let data = Data(json.utf8)
        let dto = try JSONDecoder().decode(SearchResponseDTO.self, from: data)

        let entity = dto.toEntity(currentPage: 1, perPage: 30)

        XCTAssertFalse(entity.hasNextPage)
    }

    func test_다음_페이지가_있으면_hasNextPage가_true이다() throws {
        let json = """
        {
            "total_count": 100,
            "incomplete_results": false,
            "items": []
        }
        """
        let data = Data(json.utf8)
        let dto = try JSONDecoder().decode(SearchResponseDTO.self, from: data)

        let entity = dto.toEntity(currentPage: 1, perPage: 30)

        XCTAssertTrue(entity.hasNextPage)
    }
}
