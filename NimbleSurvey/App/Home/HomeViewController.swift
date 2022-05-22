//
//  HomeViewController.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 10/05/2022.
//

import FlexiblePageControl
import Kingfisher
import RxDataSources
import RxSwift
import SkeletonView
import SnapKit
import Toast_Swift
import UIKit

class HomeViewController: UIViewController {

    // MARK: - Views

    lazy var headerView = HeaderView()

    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()

        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = .zero
        flowLayout.itemSize = CGSize(width: view.frame.width, height: view.frame.height)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)

        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = Theme.Color.primaryBackground
        collectionView.delegate = self

        return collectionView
    }()

    lazy var pageControl = FlexiblePageControl().apply {
        $0.pageIndicatorTintColor = .white.withAlphaComponent(0.5)
        $0.currentPageIndicatorTintColor = .white
        $0.hidesForSinglePage = true

        let config = FlexiblePageControl.Config(
            displayCount: 10,
            dotSize: 8,
            dotSpace: 8,
            smallDotSizeRatio: 0.5,
            mediumDotSizeRatio: 0.7
        )

        $0.setConfig(config)
    }

    lazy var errorLabel = UILabel().apply {
        $0.font = Theme.Font.body
        $0.textColor = Theme.Color.primaryText.withAlphaComponent(0.5)
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }

    lazy var retryButton = UIButton(type: .system).apply {
        $0.backgroundColor = Theme.Color.secondaryBackground
        $0.setTitleColor(Theme.Color.primaryBackground, for: .normal)
        $0.setTitle(R.string.localizable.retry_button().uppercased(), for: .normal)
        $0.titleLabel?.font = Theme.Font.title
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        $0.roundingCorner(20)
    }

    lazy var loadMoreButton = LoadingButton().apply {
        $0.setTitle(R.string.localizable.load_more_button(), for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = Theme.Font.title
        $0.indicatorStyle = .white
        $0.alpha = 0
    }

    private lazy var errorView = UIStackView(
        arrangedSubviews: [
            errorLabel,
            retryButton
        ]
    ).apply {
        $0.axis = .vertical
        $0.spacing = 16
        $0.alignment = .center
    }

    // MARK: - Properties

    private let viewModel: HomeViewModel
    private var dataSource: RxCollectionViewSectionedReloadDataSource<HomeViewModel.Section>!

    private let viewDidLoadTrigger = PublishSubject<Date>()
    private let disposeBag = DisposeBag()

    // MARK: - Initialization

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupDataSource()
        bindViewModel()
        viewDidLoadTrigger.onNext(Date())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: - Setups

extension HomeViewController {
    private func setupViews() {
        // Add views to hierarchy
        view.addSubviews(collectionView, headerView, pageControl, errorView, loadMoreButton)

        // Constraint
        headerView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            } else {
                make.top.equalTo(view.layoutMarginsGuide.snp.topMargin).offset(20)
            }

            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        collectionView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }

        collectionView.register(SurveyCell.self, forCellWithReuseIdentifier: SurveyCell.identifier)
        collectionView.register(PlaceholderSurveyCell.self, forCellWithReuseIdentifier: PlaceholderSurveyCell.identifier)

        pageControl.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualToSuperview().offset(20)
            make.centerX.equalToSuperview()

            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            } else {
                make.bottom.equalTo(view.layoutMarginsGuide.snp.bottomMargin).offset(-20)
            }
        }

        retryButton.snp.makeConstraints { make in
            make.height.equalTo(40)
        }

        errorView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.centerX.centerY.equalToSuperview()
        }

        loadMoreButton.snp.makeConstraints { make in
            make.centerY.equalTo(pageControl)
            make.centerX.equalTo(view.snp.trailing).offset(-48)
            make.leading.equalTo(pageControl.snp.trailing)
        }

        loadMoreButton.snp.contentHuggingHorizontalPriority = UILayoutPriority.defaultLow.rawValue + 1
        loadMoreButton.snp.contentCompressionResistanceHorizontalPriority = UILayoutPriority.defaultHigh.rawValue + 1

        automaticallyAdjustsScrollViewInsets = false
    }

    private func setupDataSource() {
        dataSource = RxCollectionViewSectionedReloadDataSource<HomeViewModel.Section>(configureCell: { _, collectionView, indexPath, item in
            switch item {
            case .placeholder:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaceholderSurveyCell.identifier, for: indexPath) as? PlaceholderSurveyCell else {
                    fatalError("Failed to dequeue cell PlaceholderSurveyCell")
                }

                cell.contentView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .darkGray), transition: .crossDissolve(0.5))

                return cell

            case .survey(let surveyViewModel):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SurveyCell.identifier, for: indexPath) as? SurveyCell else {
                    fatalError("Failed to dequeue cell SurveyCell")
                }

                cell.bindData(surveyViewModel: surveyViewModel)
                cell.selectButton.rx.tap
                    .subscribe(onNext: { [weak self] _ in
                        guard let self = self else {
                            return
                        }

                        Navigator.default.show(
                            scene: .survey,
                            sender: self,
                            transition: .navigation
                        )
                    })
                    .disposed(by: cell.disposeBag)

                return cell
            }
        })
    }
}

// MARK: - Bind view model

extension HomeViewController {
    private func bindViewModel() {
        let input = HomeViewModel.Input(
            viewDidLoadTrigger: viewDidLoadTrigger.asObservable(),
            loadMoreTrigger: loadMoreButton.rx.tap.asObservable(),
            retryTrigger: retryButton.rx.tap.asObservable()
        )

        let output = viewModel.transform(input: input)

        output.subtitle
            .drive(headerView.subtitleLabel.rx.text)
            .disposed(by: disposeBag)

        output.headline
            .drive(headerView.headlineLabel.rx.text)
            .disposed(by: disposeBag)

        output.avatarImage
            .drive(headerView.imageView.rx.image)
            .disposed(by: disposeBag)

        output.showingHeaderView
            .drive(headerView.rx.isHidden)
            .disposed(by: disposeBag)

        output.loadingMore
            .drive(onNext: { [weak self] isLoadingMore in
                self?.loadMoreButton.isUserInteractionEnabled = !isLoadingMore

                if isLoadingMore {
                    self?.loadMoreButton.showLoading()
                } else {
                    self?.loadMoreButton.hideLoading()
                    self?.showLoadMoreButton(false)
                }
            })
            .disposed(by: disposeBag)

        output.sections
            .drive(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        output.sections
            .compactMap(\.first)
            .map(\.items.count)
            .drive(pageControl.rx.numberOfPages)
            .disposed(by: disposeBag)

        output.enableRetry
            .drive(onNext: { [weak self] in
                self?.errorView.isHidden = !$0
                self?.errorView.isUserInteractionEnabled = $0
            })
            .disposed(by: disposeBag)

        output.error
            .drive(onNext: { [weak self] error in
                switch error {
                case .unAuthorized:
                    Navigator.default.show(
                        scene: .login,
                        sender: nil,
                        transition: .root
                    )
                case .failToRefresh:
                    self?.errorLabel.text = error.message
                case .failToLoadmore:
                    self?.view.makeToast(error.message)
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UICollectionViewDelegate

extension HomeViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // The trick here is using `round` method from Foundation.
        // This method uses the `.toNearestOrAwayFromZero` rounding rule (Apple docs).
        // (round(2.4) = 2, round(2.5) = 3)
        // So when collection view scrolls from one page to another just in the middle,
        // we immediately update the page control's selected dot.
        let index = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        pageControl.setCurrentPage(at: index, animated: true)
        showLoadMoreButton(index == pageControl.numberOfPages - 1)
    }
}

// MARK: - Helpers

extension HomeViewController {
    private func showLoadMoreButton(_ showing: Bool) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) { [weak self] in
            self?.loadMoreButton.alpha = showing ? 1 : 0
            self?.loadMoreButton.transform = showing ? .identity : .init(translationX: 68, y: 0)
        }
    }
}
