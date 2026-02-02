import UIKit
import SnapKit

final class SearchViewController: UIViewController {

    // MARK: - UI Components

    private let searchController = UISearchController(searchResultsController: nil)
    private let tableView = UITableView(frame: .zero, style: .plain)

    private lazy var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground

        let titleLabel = UILabel()
        titleLabel.text = "최근 검색"
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .label

        let clearButton = UIButton(type: .system)
        clearButton.setTitle("전체 삭제", for: .normal)
        clearButton.titleLabel?.font = .systemFont(ofSize: 14)
        clearButton.addTarget(self, action: #selector(clearAllButtonTapped), for: .touchUpInside)

        view.addSubview(titleLabel)
        view.addSubview(clearButton)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }

        clearButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }

        return view
    }()

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
        viewModel.loadRecentSearches()
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
        tableView.register(RecentSearchCell.self, forCellReuseIdentifier: RecentSearchCell.reuseIdentifier)
        tableView.keyboardDismissMode = .onDrag
        tableView.rowHeight = 52
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 48, bottom: 0, right: 0)
    }

    private func bindViewModel() {
        viewModel.onSearchResult = { [weak self] result in
            self?.navigateToSearchResult(with: result)
        }

        viewModel.onError = { [weak self] error in
            self?.showErrorAlert(error)
        }

        viewModel.onRecentSearchesUpdated = { [weak self] in
            self?.updateTableView()
        }
    }

    // MARK: - UI Updates

    private func updateTableView() {
        tableView.reloadData()
        updateHeaderVisibility()
    }

    private func updateHeaderVisibility() {
        if viewModel.isSearching || viewModel.recentSearches.isEmpty {
            tableView.tableHeaderView = nil
        } else {
            headerView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
            tableView.tableHeaderView = headerView
        }
    }

    // MARK: - Actions

    @objc private func clearAllButtonTapped() {
        let alert = UIAlertController(
            title: "전체 삭제",
            message: "최근 검색어를 모두 삭제하시겠습니까?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteAllRecentSearches()
        })
        present(alert, animated: true)
    }

    // MARK: - Navigation

    private func navigateToSearchResult(with query: String) {
        let searchResultVC = SearchResultViewController(query: query)
        navigationController?.pushViewController(searchResultVC, animated: true)
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
        let query = searchController.searchBar.text ?? ""
        viewModel.updateAutocomplete(query: query, isActive: searchController.isActive)
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text?.trimmingCharacters(in: .whitespaces),
              !query.isEmpty else { return }

        viewModel.search(query: query)
        searchController.isActive = false
    }
}

// MARK: - UITableViewDataSource

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.isSearching
            ? viewModel.autocompleteSuggestions.count
            : viewModel.recentSearches.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: RecentSearchCell.reuseIdentifier,
            for: indexPath
        ) as? RecentSearchCell else {
            return UITableViewCell()
        }

        if viewModel.isSearching {
            guard let suggestion = viewModel.autocompleteSuggestion(at: indexPath.row) else {
                return UITableViewCell()
            }
            cell.configure(with: suggestion, showDeleteButton: false)
        } else {
            guard let recentSearch = viewModel.recentSearch(at: indexPath.row) else {
                return UITableViewCell()
            }
            cell.configure(with: recentSearch)
            cell.onDelete = { [weak self] in
                self?.viewModel.deleteRecentSearch(at: indexPath.row)
            }
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let query: String?
        if viewModel.isSearching {
            query = viewModel.autocompleteSuggestion(at: indexPath.row)?.query
        } else {
            query = viewModel.recentSearch(at: indexPath.row)?.query
        }

        guard let query else { return }
        searchController.isActive = false
        viewModel.search(query: query)
    }
}
