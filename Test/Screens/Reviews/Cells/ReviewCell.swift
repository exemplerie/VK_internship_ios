import UIKit

/// Конфигурация ячейки. Содержит данные для отображения в ячейке.
struct ReviewCellConfig {

    /// Идентификатор для переиспользования ячейки.
    static let reuseId = String(describing: ReviewCellConfig.self)

    /// Идентификатор конфигурации. Можно использовать для поиска конфигурации в массиве.
    let id = UUID()
    /// Текст отзыва.
    let reviewText: NSAttributedString
    /// Максимальное отображаемое количество строк текста. По умолчанию 3.
    var maxLines = 3
    /// Время создания отзыва.
    let created: NSAttributedString
    /// Замыкание, вызываемое при нажатии на кнопку "Показать полностью...".
    let onTapShowMore: (UUID) -> Void
    /// Имя пользователя.
    let userName: NSAttributedString
    /// Изображение рейтинга.
    let ratingImage: UIImage
    /// Ссылка на изображение аватара.
    let avatarURL: String? // Новое свойство для URL аватара
    /// Ссылка на изображения в отзыве.
    let photoURLs: [String]?
    
    /// Объект, хранящий посчитанные фреймы для ячейки отзыва.
    fileprivate let layout = ReviewCellLayout()

}

// MARK: - TableCellConfig

extension ReviewCellConfig: TableCellConfig {
    /// Метод обновления ячейки.
    /// Вызывается из `cellForRowAt:` у `dataSource` таблицы.
    func update(cell: UITableViewCell) {
        guard let cell = cell as? ReviewCell else { return }
        cell.reviewTextLabel.attributedText = reviewText
        cell.reviewTextLabel.numberOfLines = maxLines
        cell.createdLabel.attributedText = created
        cell.config = self
        cell.userNameLabel.attributedText = userName
        cell.ratingImageView.image = ratingImage
        
        if let avatarURL = avatarURL {
            ImageLoader.shared.loadImage(from: avatarURL) { image in
                cell.avatarImageView.image = image ?? UIImage(named: "defaultAvatar")
            }
        } else {
            cell.avatarImageView.image = UIImage(named: "defaultAvatar")
        }
        
        cell.photosStackView.arrangedSubviews.forEach {
            cell.photosStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        if let photoURLs = photoURLs, !photoURLs.isEmpty {
            let urls = Array(photoURLs.prefix(5))
            for url in urls {
                let imageView = UIImageView()
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                ImageLoader.shared.loadImage(from: url) { image in
                    imageView.image = image ?? UIImage(named: "placeholderPhoto")
                }
                imageView.layer.cornerRadius = 8.0
                cell.photosStackView.addArrangedSubview(imageView)
            }
        }

    }

    /// Метод, возвращаюший высоту ячейки с данным ограничением по размеру.
    /// Вызывается из `heightForRowAt:` делегата таблицы.
    func height(with size: CGSize) -> CGFloat {
        layout.height(config: self, maxWidth: size.width)
    }

}

// MARK: - Private

private extension ReviewCellConfig {

    /// Текст кнопки "Показать полностью...".
    static let showMoreText = "Показать полностью..."
        .attributed(font: .showMore, color: .showMore)

}

struct ReviewCountCellConfig: TableCellConfig {
    
    let count: Int
    
    static var reuseId = String(describing: Self.self)
    
    func update(cell: UITableViewCell) {
        guard let cell = cell as? ReviewCountCell else { return }
        cell.configure(with: count)
    }
    
    func height(with size: CGSize) -> CGFloat {
        return 44.0
    }
}

/// Ячейка, которая показывает общее количество отзывов в конце ленты.
final class ReviewCountCell: UITableViewCell {
    
    private let countLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        contentView.addSubview(countLabel)
        
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            countLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            countLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        countLabel.textAlignment = .center
        countLabel.font = .reviewCount
        countLabel.textColor = .secondaryLabel
    }
    
    func configure(with count: Int) {
        countLabel.text = "\(count) отзывов"
    }
}


// MARK: - Cell

final class ReviewCell: UITableViewCell {

    fileprivate var config: Config?

    fileprivate let avatarImageView = UIImageView()
    fileprivate let reviewTextLabel = UILabel()
    fileprivate let createdLabel = UILabel()
    fileprivate let showMoreButton = UIButton()
    fileprivate let userNameLabel = UILabel()
    fileprivate let ratingImageView = UIImageView()
    fileprivate let photosStackView = UIStackView()
    fileprivate let photoURLs: [String] = []

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let layout = config?.layout else { return }
        avatarImageView.frame = layout.avatarFrame
        reviewTextLabel.frame = layout.reviewTextLabelFrame
        createdLabel.frame = layout.createdLabelFrame
        showMoreButton.frame = layout.showMoreButtonFrame
        userNameLabel.frame = layout.userNameFrame
        ratingImageView.frame = layout.ratingImageViewFrame
        photosStackView.frame = layout.photoStackFrame
    }

}

// MARK: - Private

private extension ReviewCell {

    func setupCell() {
        setupReviewTextLabel()
        setupCreatedLabel()
        setupShowMoreButton()
        setupAvatarImage()
        setupUserName()
        setupRetingImageView()
        setupPhotosStackView()
    }
    
    func setupPhotosStackView() {
        contentView.addSubview(photosStackView)
        photosStackView.axis = .horizontal
        photosStackView.distribution = .fillEqually
        photosStackView.spacing = 8.0
    }
    
    func setupAvatarImage() {
        contentView.addSubview(avatarImageView)
        avatarImageView.image = UIImage(named: "defaultAvatar")
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = ReviewCellLayout.avatarCornerRadius
        avatarImageView.clipsToBounds = true
    }
    
    func setupUserName() {
        contentView.addSubview(userNameLabel)
        userNameLabel.font = .username
    }
    
    func setupRetingImageView() {
        contentView.addSubview(ratingImageView)
    }
    
    func setupReviewTextLabel() {
        contentView.addSubview(reviewTextLabel)
        reviewTextLabel.lineBreakMode = .byWordWrapping
    }

    func setupCreatedLabel() {
        contentView.addSubview(createdLabel)
    }

    func setupShowMoreButton() {
        contentView.addSubview(showMoreButton)
        showMoreButton.contentVerticalAlignment = .fill
        showMoreButton.setAttributedTitle(Config.showMoreText, for: .normal)
        showMoreButton.addTarget(self, action: #selector(didTapShowMore), for: .touchUpInside)
    }
    
    @objc private func didTapShowMore() {
        guard let config = config else { return }
        config.onTapShowMore(config.id)
    }
    
}


// MARK: - Layout

/// Класс, в котором происходит расчёт фреймов для сабвью ячейки отзыва.
/// После расчётов возвращается актуальная высота ячейки.
private final class ReviewCellLayout {

    // MARK: - Размеры

    fileprivate static let avatarSize = CGSize(width: 36.0, height: 36.0)
    fileprivate static let avatarCornerRadius = 18.0
    fileprivate static let photoCornerRadius = 8.0
    fileprivate static let ratingImageSize = CGSize(width: 84.0, height: 16.0)
    fileprivate static let photoSize = CGSize(width: 55.0, height: 66.0)
    fileprivate static let showMoreButtonSize = Config.showMoreText.size()

    // MARK: - Фреймы

    private(set) var avatarFrame = CGRect.zero
    private(set) var userNameFrame = CGRect.zero
    private(set) var reviewTextLabelFrame = CGRect.zero
    private(set) var showMoreButtonFrame = CGRect.zero
    private(set) var createdLabelFrame = CGRect.zero
    private(set) var ratingImageViewFrame = CGRect.zero
    private(set) var photoStackFrame = CGRect.zero

    // MARK: - Отступы

    /// Отступы от краёв ячейки до её содержимого.
    private let insets = UIEdgeInsets(top: 9.0, left: 12.0, bottom: 9.0, right: 12.0)

    /// Горизонтальный отступ от аватара до имени пользователя.
    private let avatarToUsernameSpacing = 10.0
    /// Вертикальный отступ от имени пользователя до вью рейтинга.
    private let usernameToRatingSpacing = 6.0
    /// Вертикальный отступ от вью рейтинга до текста (если нет фото).
    private let ratingToTextSpacing = 6.0
    /// Вертикальный отступ от вью рейтинга до фото.
    private let ratingToPhotosSpacing = 10.0
    /// Горизонтальные отступы между фото.
    private let photosSpacing = 8.0
    /// Вертикальный отступ от фото (если они есть) до текста отзыва.
    private let photosToTextSpacing = 10.0
    /// Вертикальный отступ от текста отзыва до времени создания отзыва или кнопки "Показать полностью..." (если она есть).
    private let reviewTextToCreatedSpacing = 6.0
    /// Вертикальный отступ от кнопки "Показать полностью..." до времени создания отзыва.
    private let showMoreToCreatedSpacing = 6.0

    // MARK: - Расчёт фреймов и высоты ячейки

    /// Возвращает высоту ячейку с данной конфигурацией `config` и ограничением по ширине `maxWidth`.
    func height(config: Config, maxWidth: CGFloat) -> CGFloat {
        let width = maxWidth - insets.left - insets.right

        var maxY = insets.top
        var showShowMoreButton = false
        
        avatarFrame = CGRect(
            origin: CGPoint(x: insets.left, y: maxY),
            size: Self.avatarSize
        )
    
        userNameFrame = CGRect(origin: CGPoint(x: avatarFrame.maxX + avatarToUsernameSpacing, y: maxY), size: config.userName.boundingRect(width: width).size)
        maxY = userNameFrame.maxY + usernameToRatingSpacing
        
        ratingImageViewFrame = CGRect(
            origin: CGPoint(x: userNameFrame.origin.x, y: maxY),
                size: Self.ratingImageSize
            )
        maxY = ratingImageViewFrame.maxY
        
        if let photoURLs = config.photoURLs, !photoURLs.isEmpty {
            maxY += ratingToPhotosSpacing
            let photosCount = min(photoURLs.count, 5)
            let photosWidth = CGFloat(photosCount) * Self.photoSize.width + CGFloat(photosCount - 1) * photosSpacing
            photoStackFrame = CGRect(
                x: avatarFrame.maxX + insets.left,
                y: maxY,
                width: photosWidth,
                height: Self.photoSize.height
            )
            maxY = photoStackFrame.maxY + photosToTextSpacing
        } else {
            photoStackFrame = .zero
            maxY += ratingToTextSpacing
        }

        if !config.reviewText.isEmpty() {
            // Высота текста с текущим ограничением по количеству строк.
            let currentTextHeight = (config.reviewText.font()?.lineHeight ?? .zero) * CGFloat(config.maxLines)
            // Максимально возможная высота текста, если бы ограничения не было.
            let actualTextHeight = config.reviewText.boundingRect(width: width).size.height
            // Показываем кнопку "Показать полностью...", если максимально возможная высота текста больше текущей.
            showShowMoreButton = config.maxLines != .zero && actualTextHeight > currentTextHeight

            reviewTextLabelFrame = CGRect(
                origin: CGPoint(x: avatarFrame.maxX + insets.left, y: maxY),
                size: config.reviewText.boundingRect(width: width - avatarFrame.maxX, height: currentTextHeight).size
            )
            maxY = reviewTextLabelFrame.maxY + reviewTextToCreatedSpacing
        } else {
            reviewTextLabelFrame.size.height = avatarFrame.height
        }

        if showShowMoreButton {
            showMoreButtonFrame = CGRect(
                origin: CGPoint(x: avatarFrame.maxX + insets.left, y: maxY),
                size: Self.showMoreButtonSize
            )
            maxY = showMoreButtonFrame.maxY + showMoreToCreatedSpacing
        } else {
            showMoreButtonFrame = .zero
        }

        createdLabelFrame = CGRect(
            origin: CGPoint(x: avatarFrame.maxX + insets.left, y: maxY),
            size: config.created.boundingRect(width: width).size
        )

        return createdLabelFrame.maxY + insets.bottom
    }

}

// MARK: - Typealias

fileprivate typealias Config = ReviewCellConfig
fileprivate typealias Layout = ReviewCellLayout
