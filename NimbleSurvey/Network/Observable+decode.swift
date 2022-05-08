//
//  Observable+decode.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 09/05/2022.
//

import RxSwift

extension Observable where Element == Data {
    func decode<M: Decodable>(type: M.Type, decoder: JSONDecoder) -> Single<M> {
        return map {
            try decoder.decode(M.self, from: $0)
        }
        .asSingle()
    }
}
