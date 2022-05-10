//
//  TargetType.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 09/05/2022.
//

import Alamofire
import Foundation

// Borrow idea from Moya
public protocol TargetType {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders? { get }
    var parameters: Parameters? { get }
    var encoding: ParameterEncoding { get }
}

extension TargetType {
    var url: URL {
        if path.isEmpty {
            return baseURL
        } else {
            return baseURL.appendingPathComponent(path)
        }
    }
}
