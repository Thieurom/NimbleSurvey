//
//  LoadingButton.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 14/05/2022.
//

import SnapKit
import UIKit

class LoadingButton: UIButton {

    private lazy var loadingIndicator = UIActivityIndicatorView().apply {
        $0.hidesWhenStopped = true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public APIs to control loading

    func showLoading() {
        showIndicator(true)
    }

    func hideLoading() {
        showIndicator(false)
    }
}

extension LoadingButton {
    private func setupView() {
        addSubview(loadingIndicator)

        loadingIndicator.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }

    private func showIndicator(_ isLoading: Bool) {
        if isLoading {
            titleLabel?.alpha = 0
            loadingIndicator.startAnimating()
        } else {
            titleLabel?.alpha = 1
            loadingIndicator.stopAnimating()
        }
    }
}
