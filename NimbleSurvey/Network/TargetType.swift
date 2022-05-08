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
    var parameters: Parameters? { get }
    var encoding: ParameterEncoding { get }
}

extension TargetType {
    var baseURL: URL {
        // TODO: Move to config
        URL(string: "https://survey-api.nimblehq.co/api/v1")!
    }

    var url: URL {
        if path.isEmpty {
            return baseURL
        } else {
            return baseURL.appendingPathComponent(path)
        }
    }
}
