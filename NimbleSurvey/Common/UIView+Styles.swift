//
//  UIView+Styles.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 07/05/2022.
//

import UIKit

extension UIView {
    func roundingCorner(_ radius: CGFloat) {
        layer.cornerRadius = radius
    }
}

extension UITextField {
    func paddingLeft(_ view: UIView) {
        leftView = view
        leftViewMode = .always
    }

    func paddingRight(_ view: UIView) {
        rightView = view
        rightViewMode = .always
    }
}
