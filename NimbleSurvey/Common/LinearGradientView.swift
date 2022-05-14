//
//  LinearGradientView.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 07/05/2022.
//

import UIKit

class LinearGradientView: UIView {

    // Subclasses can override
    class var defaultColors: [UIColor] {
        return [
            UIColor.black.withAlphaComponent(0),
            UIColor.black
        ]
    }

    private let colors: [CGColor]
    private lazy var gradientLayer = CAGradientLayer()

    init(colors: [UIColor]? = nil) {
        self.colors = (colors ?? Self.defaultColors).map(\.cgColor)
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
