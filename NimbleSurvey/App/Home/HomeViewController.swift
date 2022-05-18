//
//  HomeViewController.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 10/05/2022.
//

import CHIPageControl
import Kingfisher
import RxDataSources
import RxSwift
import SkeletonView
import SnapKit
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

    lazy var pageControl = CHIPageControlAji().apply {
        $0.radius = 4
        $0.padding = 6
        $0.tintColor = .white.withAlphaComponent(0.2)
        $0.currentPageTintColor = .white
        $0.enableTouchEvents = true
        $0.delegate = self
    }

    // MARK: - Properties

    private let viewModel: HomeViewModel
    private var dataSource: RxCollectionViewSectionedReloadDataSource<HomeViewModel.Section>!

    private let viewDidLoadTrigger = PublishSubject<Void>()
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
        viewDidLoadTrigger.onNext(())
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
        view.addSubviews(collectionView, headerView, pageControl)

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
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.centerX.equalToSuperview()

            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            } else {
                make.bottom.equalTo(view.layoutMarginsGuide.snp.bottomMargin).offset(-20)
            }
        }

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
        let input = HomeViewModel.Input(viewDidLoadTrigger: viewDidLoadTrigger.asObservable())
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

        output.requestInFlight
            .drive(headerView.rx.isHidden)
            .disposed(by: disposeBag)

        output.sections
            .drive(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        output.sections
            .compactMap(\.first)
            .map(\.items.count)
            .drive(pageControl.rx.numberOfPages)
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
        let index = Int(round(scrollView.contentOffset.x / view.frame.width))
        pageControl.set(progress: index, animated: true)
    }
}

extension HomeViewController: CHIBasePageControlDelegate {
    func didTouch(pager: CHIBasePageControl, index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}
