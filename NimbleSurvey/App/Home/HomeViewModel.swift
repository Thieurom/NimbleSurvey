//
//  HomeViewModel.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 11/05/2022.
//

import Foundation
import RxCocoa
import RxDataSources
import RxSwift

struct SurveyViewModel: Equatable {
    let id: String
    let title: String
    let description: String
    let thumbnailUrl: URL?
    let coverImageUrl: URL?

    init(survey: Survey) {
        self.id = survey.id
        self.title = survey.title
        self.description = survey.description
        self.thumbnailUrl = survey.coverImageUrl

        if let urlString = survey.coverImageUrl?.absoluteString {
            self.coverImageUrl = URL(string: urlString + "l")
        } else {
            self.coverImageUrl = survey.coverImageUrl
        }
    }
}

enum SurveyListError: Error, Equatable {
    case unAuthorized
    case failToRefresh
    case failToLoadmore

    var message: String {
        switch self {
        case .unAuthorized:
            return R.string.localizable.unauthorized_error()
        case .failToRefresh:
            return R.string.localizable.unknown_error()
        case .failToLoadmore:
            return R.string.localizable.survey_list_load_more_error()
        }
    }
}

class HomeViewModel: ViewModelType {

    // MARK: - Nested types

    struct Input {
        let viewDidLoadTrigger: Observable<Date>
        let loadMoreTrigger: Observable<Void>
        let retryTrigger: Observable<Void>
    }

    struct Output {
        let subtitle: Driver<String>
        let headline: Driver<String>
        let avatarImage: Driver<UIImage?>
        let showingHeaderView: Driver<Bool>
        let enableRetry: Driver<Bool>
        let loadingMore: Driver<Bool>
        let sections: Driver<[Section]>
        let error: Driver<SurveyListError>
    }

    struct Section: SectionModelType, Equatable {
        var items: [SectionItem]

        init(items: [SectionItem]) {
            self.items = items
        }

        init(original: Section, items: [SectionItem]) {
            self = original
            self.items = items
        }
    }

    enum SectionItem: Equatable {
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

    // MARK: - Internal states

    private var currentPage = 1
    private let pageSize = 5
    private let placeholder = BehaviorRelay<[SectionItem]>(value: [])
    private let surveyList = BehaviorRelay<[Survey]>(value: [])

    // MARK: - Initialization

    init(nimbleSurveyClient: NimbleSurveyClientType) {
        self.nimbleSurveyClient = nimbleSurveyClient
    }

    func transform(input: Input) -> Output {
        let subtile = input.viewDidLoadTrigger
            .compactMap { [weak self] date -> String? in
                return self?.dateFormater.string(from: date).uppercased()
            }
            .take(1)

        let showingHeaderView = PublishSubject<Bool>()
        let loadingMore = PublishSubject<Bool>()
        let enableRetry = PublishSubject<Bool>()
        let errorSubject = PublishSubject<SurveyListError>()

        let surveys = Observable.merge(
            input.viewDidLoadTrigger.map { _ in true },
            input.loadMoreTrigger.map { _ in false },
            input.retryTrigger.map { _ in true }
        )
            .flatMapLatest { [weak self] requestingFirstPage -> Observable<[Survey]> in
                guard let self = self else {
                    return .empty()
                }

                if requestingFirstPage {
                    showingHeaderView.onNext(true)
                    enableRetry.onNext(false)
                    self.currentPage = 1
                    self.placeholder.accept([SectionItem.placeholder])
                } else {
                    loadingMore.onNext(true)
                    self.currentPage += 1
                }

                return self.nimbleSurveyClient
                    .surveyList(pageNumber: self.currentPage, pageSize: self.pageSize)
                    .do(onSuccess: { [weak self] in
                        if requestingFirstPage {
                            showingHeaderView.onNext(false)
                            self?.surveyList.accept($0)
                        } else {
                            loadingMore.onNext(false)
                            // Accumulate the survey items from 1st page upto `currentPage`
                            self?.surveyList.accept((self?.surveyList.value ?? []) + $0)
                        }
                    })
                    .asObservable()
                    .take(1)
                    .catch { [weak self] error in
                        if requestingFirstPage {
                            showingHeaderView.onNext(false)
                            enableRetry.onNext(true)
                            self?.surveyList.accept([])
                        } else {
                            loadingMore.onNext(false)
                        }

                        switch error {
                        case NimbleSurveyError.unAuthorized:
                            errorSubject.onNext(.unAuthorized)
                        case NimbleSurveyError.unknown:
                            errorSubject.onNext(
                                requestingFirstPage
                                ? .failToRefresh
                                : .failToLoadmore
                            )
                        default:
                            errorSubject.onNext(.failToLoadmore)
                        }

                        return .just([])
                    }
            }
            .map { [weak self] _ in
                return self?.surveyList.value ?? []
            }
            .map {
                $0.map { SectionItem.survey(SurveyViewModel(survey: $0)) }
            }

        let sections = Observable.merge(placeholder.asObservable(), surveys)
            .map { [Section(items: $0)] }

        return Output(
            subtitle: subtile.asDriver(onErrorJustReturn: ""),
            headline: .just(R.string.localizable.home_today()).asDriver(),
            avatarImage: .just(R.image.avatar()).asDriver(),
            showingHeaderView: showingHeaderView.asDriver(onErrorJustReturn: false),
            enableRetry: enableRetry.startWith(false).asDriver(onErrorJustReturn: false),
            loadingMore: loadingMore.startWith(false).asDriver(onErrorJustReturn: false),
            sections: sections.asDriver(onErrorJustReturn: []),
            error: errorSubject.asDriver(onErrorJustReturn: .failToRefresh)
        )
    }
}
