//
//  NetworkAPIProtocol.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 08/05/2022.
//

import Alamofire
import RxSwift

protocol NetworkAPIProtocol {
    associatedtype Target: TargetType
    var session: Session { get }
    var jsonDecoder: JSONDecoder { get }

    func request<M: Decodable>(for target: Target, type: M.Type) -> Single<M>
}
