import UIKit
import SnapKit

final class RepositoryCell: UITableViewCell {

    // MARK: - Constants

    static let reuseIdentifier = "RepositoryCell"

    // MARK: - UI Components

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.backgroundColor = .systemGray5
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        return label
    }()

    private let starImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "star.fill")
        imageView.tintColor = .systemYellow
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let starCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        return label
    }()

    private let languageColorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6
        view.backgroundColor = .systemBlue
        return view
    }()

    private let languageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        return label
    }()

    // MARK: - Properties

    private var imageLoadTask: Task<Void, Never>?

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        accessoryType = .disclosureIndicator

        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(starImageView)
        contentView.addSubview(starCountLabel)
        contentView.addSubview(languageColorView)
        contentView.addSubview(languageLabel)

        avatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(12)
            make.size.equalTo(40)
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(12)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
        }

        starImageView.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(8)
            make.size.equalTo(14)
            make.bottom.equalToSuperview().offset(-12)
        }

        starCountLabel.snp.makeConstraints { make in
            make.leading.equalTo(starImageView.snp.trailing).offset(4)
            make.centerY.equalTo(starImageView)
        }

        languageColorView.snp.makeConstraints { make in
            make.leading.equalTo(starCountLabel.snp.trailing).offset(16)
            make.centerY.equalTo(starImageView)
            make.size.equalTo(12)
        }

        languageLabel.snp.makeConstraints { make in
            make.leading.equalTo(languageColorView.snp.trailing).offset(4)
            make.centerY.equalTo(starImageView)
        }
    }

    // MARK: - Configuration

    func configure(with repository: Repository) {
        nameLabel.text = "\(repository.ownerName)/\(repository.name)"
        descriptionLabel.text = repository.description ?? "No description"
        starCountLabel.text = formatStarCount(repository.starCount)

        if let language = repository.language {
            languageColorView.isHidden = false
            languageLabel.isHidden = false
            languageLabel.text = language
            languageColorView.backgroundColor = languageColor(for: language)
        } else {
            languageColorView.isHidden = true
            languageLabel.isHidden = true
        }

        loadAvatar(from: repository.avatarUrl)
    }

    private func loadAvatar(from urlString: String) {
        avatarImageView.image = nil
        imageLoadTask?.cancel()

        guard let url = URL(string: urlString) else { return }

        imageLoadTask = Task {
            let image = await ImageCache.shared.image(for: url)
            guard !Task.isCancelled else { return }
            avatarImageView.image = image
        }
    }

    private func formatStarCount(_ count: Int) -> String {
        if count >= 1000 {
            let thousands = Double(count) / 1000.0
            return String(format: "%.1fk", thousands)
        }
        return "\(count)"
    }

    private func languageColor(for language: String) -> UIColor {
        switch language.lowercased() {
        case "swift": return UIColor(red: 1.0, green: 0.67, blue: 0.24, alpha: 1.0)
        case "javascript": return UIColor(red: 0.95, green: 0.87, blue: 0.36, alpha: 1.0)
        case "typescript": return UIColor(red: 0.19, green: 0.47, blue: 0.87, alpha: 1.0)
        case "python": return UIColor(red: 0.21, green: 0.45, blue: 0.65, alpha: 1.0)
        case "java": return UIColor(red: 0.69, green: 0.44, blue: 0.11, alpha: 1.0)
        case "kotlin": return UIColor(red: 0.66, green: 0.31, blue: 1.0, alpha: 1.0)
        case "go": return UIColor(red: 0.0, green: 0.68, blue: 0.84, alpha: 1.0)
        case "rust": return UIColor(red: 0.87, green: 0.42, blue: 0.22, alpha: 1.0)
        case "ruby": return UIColor(red: 0.44, green: 0.09, blue: 0.09, alpha: 1.0)
        case "c": return UIColor(red: 0.33, green: 0.33, blue: 0.33, alpha: 1.0)
        case "c++": return UIColor(red: 0.96, green: 0.29, blue: 0.55, alpha: 1.0)
        case "c#": return UIColor(red: 0.1, green: 0.55, blue: 0.0, alpha: 1.0)
        case "objective-c": return UIColor(red: 0.26, green: 0.54, blue: 1.0, alpha: 1.0)
        case "html": return UIColor(red: 0.89, green: 0.29, blue: 0.15, alpha: 1.0)
        case "css": return UIColor(red: 0.34, green: 0.24, blue: 0.54, alpha: 1.0)
        default: return .systemBlue
        }
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadTask?.cancel()
        imageLoadTask = nil
        avatarImageView.image = nil
        nameLabel.text = nil
        descriptionLabel.text = nil
        starCountLabel.text = nil
        languageLabel.text = nil
        languageColorView.isHidden = false
        languageLabel.isHidden = false
    }
}
