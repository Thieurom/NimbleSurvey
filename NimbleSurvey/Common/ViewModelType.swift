//
//  ViewModelType.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 10/05/2022.
//

protocol ViewModelType {
    associatedtype Input
    associatedtype Output

    func transform(input: Input) -> Output
}
