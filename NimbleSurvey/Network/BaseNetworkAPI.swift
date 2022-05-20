//
//  NetworkService.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 08/05/2022.
//

import Alamofire
import Foundation
import JSONAPI
import RxAlamofire
import RxSwift

enum APIError: Error {
    case network
    case badRequest
    case unAuthorized
    case notFound
    case parsing
    case unknown
}

open class BaseNetworkAPI<Target: TargetType>: NetworkAPIProtocol {
    typealias AccessTokenProviding = ((Target) -> String?)

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
                value: "\(authorizationType.value) \(accessToken)"
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
                switch response.statusCode {
                case 200..<300:
                    return data
                case 400:
                    throw APIError.badRequest
                case 401:
                    throw APIError.unAuthorized
                case 404:
                    throw APIError.notFound
                default:
                    throw APIError.network
                }
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
                case is DecodingError, is DocumentDecodingError:
                    // Include `DocumentDecodingError` which is from a 3rd-party lib
                    // may be not a good idea!
                    throw APIError.parsing
                default:
                    throw (error as? APIError) ?? APIError.unknown
                }

            }
    }
}
