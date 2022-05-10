//
//  HeaderView.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 11/05/2022.
//

import SnapKit
import UIKit

class HeaderView: UIView {

    private struct Metrics {
        static let imageViewHeight: CGFloat = 36
    }

    lazy var subtitleLabel = UILabel().apply {
        $0.font = Theme.Font.subtitle
        $0.textColor = Theme.Color.primaryText
        $0.numberOfLines = 2
    }

    lazy var headlineLabel = UILabel().apply {
        $0.font = Theme.Font.headline
        $0.textColor = Theme.Color.primaryText
        $0.numberOfLines = 2
    }

    lazy var imageView = UIImageView().apply {
        $0.contentMode = .scaleAspectFill
        $0.roundingCorner(Metrics.imageViewHeight / 2)
        $0.clipsToBounds = true
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

extension HeaderView {
    private func setupView() {
        let stackView = UIStackView(arrangedSubviews: [
            headlineLabel, imageView
        ]).apply {
            $0.axis = .horizontal
            $0.spacing = 20
        }

        addSubviews(subtitleLabel, stackView)

        subtitleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(4)
            make.leading.trailing.equalTo(subtitleLabel)
            make.bottom.equalToSuperview()
        }

        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(Metrics.imageViewHeight)
        }

        headlineLabel.snp.contentHuggingVerticalPriority = UILayoutPriority.defaultLow.rawValue - 1
        headlineLabel.snp.contentCompressionResistanceHorizontalPriority = UILayoutPriority.defaultHigh.rawValue - 1
    }
}
