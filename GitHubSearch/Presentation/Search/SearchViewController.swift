import UIKit
import SnapKit

final class SearchViewController: UIViewController {

    // MARK: - UI Components

    private let searchController = UISearchController(searchResultsController: nil)
    private let tableView = UITableView(frame: .zero, style: .plain)

    // MARK: - Properties

    private let viewModel: SearchViewModel

    // MARK: - Initialization

    init(viewModel: SearchViewModel = SearchViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSearchController()
        setupTableView()
        bindViewModel()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "GitHub Search"
        navigationController?.navigationBar.prefersLargeTitles = true

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search repositories..."
        searchController.searchBar.delegate = self

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "RecentSearchCell")
        tableView.keyboardDismissMode = .onDrag
    }

    private func bindViewModel() {
        viewModel.onSearchResult = { [weak self] result in
            self?.navigateToSearchResult(with: result)
        }

        viewModel.onError = { [weak self] error in
            self?.showErrorAlert(error)
        }
    }

    // MARK: - Navigation

    private func navigateToSearchResult(with query: String) {
        let alert = UIAlertController(
            title: "검색 실행",
            message: "'\(query)' 검색 결과 화면으로 이동합니다.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    private func showErrorAlert(_ error: Error) {
        let alert = UIAlertController(
            title: "오류",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UISearchResultsUpdating

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // Issue #9에서 자동완성 구현 예정
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text?.trimmingCharacters(in: .whitespaces),
              !query.isEmpty else { return }

        searchController.isActive = false
        viewModel.search(query: query)
    }
}

// MARK: - UITableViewDataSource

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0 // Issue #5에서 최근 검색어 구현 예정
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentSearchCell", for: indexPath)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Issue #5에서 최근 검색어 탭 처리 구현 예정
    }
}
