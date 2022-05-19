//
//  MockURLProtocol.swift
//  NimbleSurveyTests
//
//  Created by Doan Le Thieu on 09/05/2022.
//

import Foundation

enum ResponseType {
    case error(Error)
    case data(HTTPURLResponse, Data)
}

class MockURLProtocol: URLProtocol {
    static var responseType: ResponseType?

    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()

    private var dataTask: URLSessionDataTask?

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        dataTask = session.dataTask(with: request.urlRequest!)
        dataTask?.cancel()
    }

    override func stopLoading() {
        dataTask?.cancel()
    }
}

extension MockURLProtocol: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        switch MockURLProtocol.responseType {
        case .error(let error):
            client?.urlProtocol(self, didFailWithError: error)
        case let .data(response, data):
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        default:
            break
        }

        client?.urlProtocolDidFinishLoading(self)
    }
}
