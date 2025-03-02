import UIKit

struct RatingRendererConfig {

    let ratingRange: ClosedRange<Int>
    let starImage: UIImage
    let tintColor: UIColor
    let fadeColor: UIColor
    let spacing: CGFloat

}

// MARK: - Internal

extension RatingRendererConfig {

    static func `default`() -> Self {
        let starSize = CGSize(width: 16.0, height: 16.0)
        let starImage = UIGraphicsImageRenderer(size: starSize).image {
            UIImage(systemName: "star.fill")?.draw(in: $0.cgContext.boundingBoxOfClipPath)
        }
        return RatingRendererConfig(
            ratingRange: 1...5,
            starImage: starImage,
            tintColor: .systemOrange,
            fadeColor: .systemGray4,
            spacing: 1.0
        )
    }

}

// MARK: - Renderer

/// Класс рисует изображение рейтинга (звёзды) и кэширует его.
final class RatingRenderer {

    private let config: RatingRendererConfig
    private let imageRenderer: UIGraphicsImageRenderer
    private let cache = NSCache<NSNumber, UIImage>()

    init(
        config: RatingRendererConfig,
        images: [Int: UIImage],
        imageRenderer: UIGraphicsImageRenderer
    ) {
        self.config = config
        self.imageRenderer = imageRenderer
    }

}

// MARK: - Internal

extension RatingRenderer {

    convenience init(config: RatingRendererConfig = .default()) {
        let size = CGSize(
            width: (config.starImage.size.width + config.spacing) * CGFloat(config.ratingRange.upperBound) - config.spacing,
            height: config.starImage.size.height
        )
        self.init(config: config, images: [:], imageRenderer: UIGraphicsImageRenderer(size: size))
    }

    func ratingImage(_ rating: Int) -> UIImage {
        if let cached = cache.object(forKey: NSNumber(value: rating)) {
            return cached
        }
        let newImage = drawRatingImage(rating)
        cache.setObject(newImage, forKey: NSNumber(value: rating))
        return newImage
    }

}

// MARK: - Private

private extension RatingRenderer {

    func drawRatingImageAndCache(_ rating: Int) -> UIImage {
        let ratingImage = drawRatingImage(rating)
        return ratingImage
    }

    func drawRatingImage(_ rating: Int) -> UIImage {
        let tintedStarImage = config.starImage.withTintColor(config.tintColor)
        let fadedStarImage = config.starImage.withTintColor(config.fadeColor)
        let renderedImage = imageRenderer.image { _ in
            var origin = CGPoint.zero
            config.ratingRange.forEach {
                ($0 <= rating ? tintedStarImage : fadedStarImage).draw(at: origin)
                origin.x += config.starImage.size.width + config.spacing
            }
        }
        return renderedImage
    }

}
