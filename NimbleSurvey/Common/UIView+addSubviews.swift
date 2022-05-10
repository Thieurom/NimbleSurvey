//
//  UIView+addSubviews.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 11/05/2022.
//

import UIKit

extension UIView {

    func addSubviews(_ views: UIView...) {
        views.forEach(addSubview)
    }
}
