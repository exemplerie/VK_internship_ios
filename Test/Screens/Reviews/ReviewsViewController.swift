import UIKit

final class ReviewsViewController: UIViewController {

    private lazy var reviewsView = makeReviewsView()
    private let viewModel: ReviewsViewModel
    private let refreshControl = UIRefreshControl()

    init(viewModel: ReviewsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = reviewsView
        title = "Отзывы"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupRefreshControl()
        viewModel.getReviews()
    }
    
    private func setupRefreshControl() {
        reviewsView.tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshReviews), for: .valueChanged)
    }

    @objc private func refreshReviews() {
        viewModel.refreshReviews { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }

}

// MARK: - Private

private extension ReviewsViewController {

    func makeReviewsView() -> ReviewsView {
        let reviewsView = ReviewsView()
        reviewsView.tableView.delegate = viewModel
        reviewsView.tableView.dataSource = viewModel
        return reviewsView
    }

    func setupViewModel() {
        viewModel.onStateChange = { [weak reviewsView] state in
            reviewsView?.tableView.reloadData()
            reviewsView?.updateLoadingState(isLoading: state.isLoading && state.items.isEmpty)
        }
    }

}
