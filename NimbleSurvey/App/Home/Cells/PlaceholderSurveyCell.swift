//
//  PlaceholderSurveyCell.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 11/05/2022.
//

import SkeletonView
import SnapKit
import UIKit

class PlaceholderSurveyCell: UICollectionViewCell {

    static let identifier = "PlaceholderSurveyCell"

    // MARK: - Views

    lazy var headerView = HeaderView()
    lazy var descriptionView = DescriptionView()

    private lazy var overlayView = LinearGradientView()

    // MARK: - Initializations

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private

extension PlaceholderSurveyCell {
    private func setupView() {
        contentView.addSubviews(overlayView, headerView, descriptionView)

        overlayView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }

        headerView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(contentView.safeAreaLayoutGuide.snp.top).offset(20)
            } else {
                make.top.equalTo(contentView.layoutMarginsGuide.snp.topMargin).offset(20)
            }

            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        descriptionView.snp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview().offset(50)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-100)

            if #available(iOS 11.0, *) {
                make.bottom.equalTo(contentView.safeAreaLayoutGuide.snp.bottom).offset(-80)
            } else {
                make.bottom.equalTo(contentView.layoutMarginsGuide.snp.bottomMargin).offset(-80)
            }
        }

        backgroundColor = .black

        // Config for skeleton

        [contentView, headerView, headerView.subtitleLabel, headerView.headlineLabel, headerView.imageView, descriptionView, descriptionView.subtitleLabel, descriptionView.titleLabel]
            .forEach { $0.isSkeletonable = true }

        // Hack alert!
        if let superview = headerView.imageView.superview {
            superview.isSkeletonable = true
        }

        headerView.subtitleLabel.linesCornerRadius = 8
        headerView.headlineLabel.linesCornerRadius = 8
        headerView.subtitleLabel.skeletonTextNumberOfLines = 1
        headerView.headlineLabel.skeletonTextNumberOfLines = 1

        descriptionView.subtitleLabel.linesCornerRadius = 8
        descriptionView.titleLabel.linesCornerRadius = 8
        descriptionView.subtitleLabel.skeletonTextNumberOfLines = 2
        descriptionView.titleLabel.skeletonTextNumberOfLines = 2
    }
}
