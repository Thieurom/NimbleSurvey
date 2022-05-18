//
//  SurveyCell.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 11/05/2022.
//

import RxSwift
import SnapKit
import UIKit

class SurveyCell: UICollectionViewCell {

    static let identifier = "SurveyCell"

    private struct Metrics {
        static let selectButtonSize: CGFloat = 56
    }

    // MARK: - Views
    
    lazy var descriptionView = DescriptionView()

    lazy var selectButton = UIButton(type: .system).apply {
        $0.backgroundColor = Theme.Color.primaryText
        $0.tintColor = Theme.Color.primaryBackground
        $0.setImage(R.image.ic_right_arrow(), for: .normal)
        $0.roundingCorner(Metrics.selectButtonSize / 2)
    }

    lazy var backgroundImageView = UIImageView().apply {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }

    private lazy var overlayView = LinearGradientView().apply {
        $0.alpha = 0.6
    }

    // MARK: - Internals

    private(set) var disposeBag = DisposeBag()

    // MARK: - Initializations

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        disposeBag = DisposeBag()
    }

    func bindData(surveyViewModel: SurveyViewModel) {
        descriptionView.titleLabel.text = surveyViewModel.title
        descriptionView.subtitleLabel.text = surveyViewModel.description
        backgroundImageView.kf.setImage(with: surveyViewModel.coverImageUrl)
    }
}

// MARK: - Private

extension SurveyCell {
    private func setupView() {
        contentView.addSubviews(backgroundImageView, overlayView, descriptionView, selectButton)

        [backgroundImageView, overlayView]
            .forEach {
                $0.snp.makeConstraints { make in
                    make.top.leading.trailing.bottom.equalToSuperview()
                }
            }
        
        selectButton.snp.makeConstraints { make in
            make.width.height.equalTo(Metrics.selectButtonSize)
            make.trailing.equalToSuperview().offset(-20)

            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-50)
            } else {
                make.bottom.equalTo(layoutMarginsGuide.snp.bottomMargin).offset(-50)
            }
        }

        descriptionView.snp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview().offset(50)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalTo(selectButton.snp.leading).offset(-20)
            make.bottom.equalTo(selectButton)
        }
    }
}
