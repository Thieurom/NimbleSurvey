//
//  SurveyDetailViewController.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 14/05/2022.
//

import RxSwift
import SnapKit
import UIKit

class SurveyDetailViewController: UIViewController {

    // MARK: - Views

    lazy var startSurveyButton = UIButton(type: .system).apply {
        $0.backgroundColor = Theme.Color.secondaryBackground
        $0.setTitleColor(Theme.Color.primaryBackground, for: .normal)
        $0.titleLabel?.font = Theme.Font.title
        $0.contentEdgeInsets = .init(top: 16, left: 16, bottom: 16, right: 16)
        $0.roundingCorner(10)
    }

    private lazy var overlayView = LinearGradientView(
        colors: [
            Theme.Color.primaryBackground.withAlphaComponent(0.5),
            Theme.Color.primaryBackground.withAlphaComponent(1)
        ]
    )

    // MARK: - Properties

    private let disposeBag = DisposeBag()
    private let viewModel: SurveyDetailViewModel

    // MARK: - Initialization

    init(viewModel: SurveyDetailViewModel) {
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
        bindViewModel()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: - Setup views

extension SurveyDetailViewController {
    private func setupViews() {
        // Styling
        view.backgroundColor = Theme.Color.secondaryBackground

        // Add views to hierarchy
        view.addSubviews(overlayView, startSurveyButton)

        // Constraint
        overlayView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        
        startSurveyButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)

            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            } else {
                make.bottom.equalTo(view.layoutMarginsGuide.snp.bottomMargin).offset(-20)
            }

        }
    }
}

// MARK: - Bind view model

extension SurveyDetailViewController {
    private func bindViewModel() {
        let input = SurveyDetailViewModel.Input()
        let output = viewModel.transform(input: input)

        output.startButtonTitle
            .drive(startSurveyButton.rx.title())
            .disposed(by: disposeBag)
    }
}
