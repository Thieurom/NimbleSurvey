//
//  LinearGradientView.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 07/05/2022.
//

import UIKit

class LinearGradientView: UIView {

    private let colors: [CGColor]
    private lazy var gradientLayer = CAGradientLayer()

    init(colors: [UIColor]) {
        self.colors = colors.map(\.cgColor)
        super.init(frame: .zero)

        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        gradientLayer.frame = bounds
    }
}

extension LinearGradientView {
    private func setupView() {
        gradientLayer.colors = colors
        gradientLayer.frame = bounds
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
