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

open class BaseNetworkAPI<Target: TargetType>: NetworkAPIProtocol {
    typealias AccessTokenProviding = ((Target) -> String)

    let session: Session

    // Bare-bone JSON decoder, sub-classes can provide more fine-tune one.
    open lazy var jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    private let accessTokenProviding: AccessTokenProviding?

    init(session: Session = .default, accessTokenProviding: AccessTokenProviding? = nil) {
        self.session = session
        self.accessTokenProviding = accessTokenProviding
    }

    func request<M: Decodable>(for target: Target, type: M.Type) -> Single<M> {
        // Very basic, hand-coded logger!
        #if DEBUG
        print("[API][Info] Request: \(target.url)\n\(target.headers ?? [:])")
        #endif

        var headers = target.headers

        // Check the neccessary of authorization via access token.
        if let authorizable = target as? AccessTokenAuthorizable,
           let authorizationType = authorizable.authorizationType,
           let accessToken = accessTokenProviding?(target) {
            let header = HTTPHeader(
                name: "Authorization",
                value: "\(authorizationType.rawValue) \(accessToken)"
            )
            
            if headers == nil {
                headers = .init([header])
            } else {
                headers?.add(header)
            }
        }

        return session.rx
            .request(
                target.method,
                target.url,
                parameters: target.parameters,
                encoding: target.encoding,
                headers: headers
            )
            .responseData()
            .do(onNext: { response, data in
                #if DEBUG
                let statusCode = response.statusCode
                print("[API][Info] Response: \(target.url)\n\(statusCode) \(String(decoding: data, as: UTF8.self))")
                #endif
            })
            .map { response, data in
                guard (200..<300) ~= response.statusCode else {
                    throw APIError.network
                }

                return data
            }
            .decode(type: M.self, decoder: jsonDecoder)
            .catch { error in
                #if DEBUG
                print("[API][Error] Request: \(target.url) failed with error: \(error.localizedDescription)")
                #endif

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
