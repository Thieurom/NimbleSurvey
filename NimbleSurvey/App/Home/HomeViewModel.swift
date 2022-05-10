//
//  HomeViewModel.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 11/05/2022.
//

import RxCocoa
import RxDataSources
import RxSwift

struct SurveyViewModel {
    let id: String
    let title: String
    let description: String
    let coverImageUrl: URL?

    init(survey: Survey) {
        self.id = survey.id
        self.title = survey.title
        self.description = survey.description
        self.coverImageUrl = survey.coverImageUrl
    }
}

class HomeViewModel: ViewModelType {

    // MARK: - Nested types

    struct Input {
        let viewDidLoadTrigger: Observable<Void>
    }

    struct Output {
        let subtitle: Driver<String>
        let headline: Driver<String>
        let avatarImage: Driver<UIImage?>
        let requestInFlight: Driver<Bool>
        let sections: Driver<[Section]>
    }

    struct Section: SectionModelType {
        var items: [SectionItem]

        init(items: [Item]) {
            self.items = items
        }

        init(original: Section, items: [SectionItem]) {
            self = original
            self.items = items
        }
    }

    enum SectionItem {
        case survey(SurveyViewModel)
        case placeholder
    }

    // MARK: - Dependencies

    private let nimbleSurveyClient: NimbleSurveyClientType

    private lazy var dateFormater = DateFormatter().apply {
        $0.timeZone = .current
        $0.locale = .current
        $0.dateFormat = "EEEE, MMMM dd"
    }

    // MARK: - Initialization

    init(nimbleSurveyClient: NimbleSurveyClientType) {
        self.nimbleSurveyClient = nimbleSurveyClient
    }

    func transform(input: Input) -> Output {
        let placeholder = Observable.just([SectionItem.placeholder])
        let requestInFlight = PublishSubject<Bool>()

        let surveys = input.viewDidLoadTrigger
            .flatMapLatest { [weak self] _ -> Observable<[Survey]> in
                guard let self = self else {
                    return .empty()
                }

                requestInFlight.onNext(true)

                return self.nimbleSurveyClient
                    .surveyList(pageNumber: 1, pageSize: 10)
                    .do(onSuccess: { _ in requestInFlight.onNext(false) })
                    .asObservable()
            }
            .map { Array($0.prefix(5)) } // Show only top five surveys
            .map {
                $0.map { SectionItem.survey(SurveyViewModel(survey: $0)) }
            }

        return Output(
            subtitle: .just(dateFormater.string(from: Date()).uppercased()).asDriver(),
            headline: .just(R.string.localizable.home_today()).asDriver(),
            avatarImage: .just(R.image.avatar()).asDriver(),
            requestInFlight: requestInFlight.asDriver(onErrorJustReturn: true),
            sections: Observable.merge(placeholder, surveys)
            .map { [Section(items: $0)] }
                .asDriver(onErrorJustReturn: [])
        )
    }
}
