import UIKit
import SnapKit

final class SearchResultViewController: UIViewController {

    // MARK: - UI Components

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "검색 결과가 없습니다"
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .secondaryLabel
        return label
    }()

    private lazy var headerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
        view.backgroundColor = .systemBackground
        view.addSubview(headerLabel)
        headerLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        return view
    }()

    // MARK: - Properties

    private let viewModel: SearchResultViewModel
    private let query: String

    // MARK: - Initialization

    init(query: String, viewModel: SearchResultViewModel = SearchResultViewModel()) {
        self.query = query
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
        setupTableView()
        bindViewModel()
        viewModel.search(query: query)
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = query

        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        view.addSubview(emptyLabel)

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(32)
        }
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(RepositoryCell.self, forCellReuseIdentifier: RepositoryCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.keyboardDismissMode = .onDrag
    }

    private func bindViewModel() {
        viewModel.onStateChanged = { [weak self] state in
            self?.handleStateChange(state)
        }
    }

    // MARK: - State Handling

    private func handleStateChange(_ state: SearchResultViewModel.State) {
        switch state {
        case .idle:
            break

        case .loading:
            activityIndicator.startAnimating()
            tableView.isHidden = true
            emptyLabel.isHidden = true

        case .success(_, let totalCount):
            activityIndicator.stopAnimating()
            tableView.isHidden = false
            emptyLabel.isHidden = true
            updateHeader(totalCount: totalCount)
            tableView.reloadData()

        case .empty:
            activityIndicator.stopAnimating()
            tableView.isHidden = true
            emptyLabel.isHidden = false

        case .error(let message):
            activityIndicator.stopAnimating()
            tableView.isHidden = true
            emptyLabel.isHidden = true
            showErrorAlert(message: message)
        }
    }

    private func updateHeader(totalCount: Int) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formattedCount = formatter.string(from: NSNumber(value: totalCount)) ?? "\(totalCount)"
        headerLabel.text = "검색 결과 \(formattedCount)개"
        headerView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
        tableView.tableHeaderView = headerView
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "오류",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension SearchResultViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.repositories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: RepositoryCell.reuseIdentifier,
            for: indexPath
        ) as? RepositoryCell,
              let repository = viewModel.repository(at: indexPath.row) else {
            return UITableViewCell()
        }

        cell.configure(with: repository)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SearchResultViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Issue #7에서 WebViewController로 이동 구현 예정
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if viewModel.shouldLoadMore(currentIndex: indexPath.row) {
            viewModel.loadNextPage(query: query)
        }
    }
}
