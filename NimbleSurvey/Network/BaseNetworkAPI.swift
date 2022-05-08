//
//  NetworkService.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 08/05/2022.
//

import Alamofire
import Foundation
import RxAlamofire
import RxSwift

enum APIError: Error {
    case network
    case parsing
    case unknown
}

open class BaseNetworkAPI<T: TargetType>: NetworkAPIProtocol {
    let session: Session

    open lazy var jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    init(session: Session = .default) {
        self.session = session
    }

    func request<M: Decodable>(for target: T, type: M.Type) -> Single<M> {
        return session.rx
            .request(
                target.method,
                target.url,
                parameters: target.parameters,
                encoding: target.encoding
            )
            .responseData()
            .map { response, data in
                guard (200..<300) ~= response.statusCode else {
                    throw APIError.network
                }

                return data
            }
            .decode(type: M.self, decoder: jsonDecoder)
            .catch { error in
                // Map errors
                switch error {
                case is URLError:
                    throw APIError.network
                case is DecodingError:
                    throw APIError.parsing
                default:
                    throw (error as? APIError) ?? APIError.unknown
                }

            }
    }
}
