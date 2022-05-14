//
//  DescriptionView.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 11/05/2022.
//

import SnapKit
import UIKit

class DescriptionView: UIView {

    lazy var titleLabel = UILabel().apply {
        $0.font = Theme.Font.caption
        $0.textColor = Theme.Color.primaryText
        $0.numberOfLines = 2
    }

    lazy var subtitleLabel = UILabel().apply {
        $0.font = Theme.Font.body
        $0.textColor = Theme.Color.primaryText.withAlphaComponent(0.7)
        $0.numberOfLines = 2
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DescriptionView {
    private func setupView() {
        addSubviews(titleLabel, subtitleLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalTo(titleLabel)
            make.bottom.equalToSuperview()
        }

        titleLabel.snp.contentHuggingVerticalPriority = UILayoutPriority.defaultLow.rawValue + 1
        titleLabel.snp.contentCompressionResistanceHorizontalPriority = UILayoutPriority.defaultHigh.rawValue + 1
    }
}
