import UIKit
import WebKit
import SnapKit

final class WebViewController: UIViewController {

    // MARK: - UI Components

    private let webView = WKWebView()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    // MARK: - Properties

    private let url: URL
    private let repoName: String

    // MARK: - Initialization

    init(url: URL, repoName: String) {
        self.url = url
        self.repoName = repoName
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupWebView()
        loadURL()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = repoName

        view.addSubview(webView)
        view.addSubview(activityIndicator)

        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        activityIndicator.hidesWhenStopped = true
    }

    private func setupWebView() {
        webView.navigationDelegate = self
    }

    private func loadURL() {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

// MARK: - WKNavigationDelegate

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        showErrorAlert(message: error.localizedDescription)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        showErrorAlert(message: error.localizedDescription)
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "로드 실패",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}
