import UIKit
import SnapKit

final class RecentSearchCell: UITableViewCell {

    // MARK: - Constants

    static let reuseIdentifier = "RecentSearchCell"

    // MARK: - UI Components

    private let clockImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "clock")
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let queryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
        return label
    }()

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        return label
    }()

    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .tertiaryLabel
        return button
    }()

    // MARK: - Properties

    var onDelete: (() -> Void)?

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        contentView.addSubview(clockImageView)
        contentView.addSubview(queryLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(deleteButton)

        clockImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(20)
        }

        deleteButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.size.equalTo(44)
        }

        timeLabel.snp.makeConstraints { make in
            make.trailing.equalTo(deleteButton.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
        }
        timeLabel.setContentHuggingPriority(.required, for: .horizontal)
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        queryLabel.snp.makeConstraints { make in
            make.leading.equalTo(clockImageView.snp.trailing).offset(12)
            make.trailing.lessThanOrEqualTo(timeLabel.snp.leading).offset(-12)
            make.centerY.equalToSuperview()
        }
    }

    private func setupActions() {
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }

    // MARK: - Configuration

    func configure(with recentSearch: RecentSearch, showDeleteButton: Bool = true) {
        queryLabel.text = recentSearch.query
        timeLabel.text = recentSearch.searchedAt.relativeString
        deleteButton.isHidden = !showDeleteButton
    }

    // MARK: - Actions

    @objc private func deleteButtonTapped() {
        onDelete?()
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        queryLabel.text = nil
        timeLabel.text = nil
        onDelete = nil
        deleteButton.isHidden = false
    }
}
