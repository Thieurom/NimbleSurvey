//
//  HomeViewModelTests.swift
//  NimbleSurveyTests
//
//  Created by Doan Le Thieu on 19/05/2022.
//

import Alamofire
@testable import NimbleSurvey
import RxBlocking
import RxSwift
import RxTest
import XCTest

class HomeViewModelTests: XCTestCase {
    // SUT
    private var homeViewModel: HomeViewModel!

    // Mock dependencies
    private var mockNimbleSurveyClient: MockNimbleSurveyClient!

    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = .current
        return formatter
    }()

    private lazy var outputDateFormater = DateFormatter().apply {
        $0.timeZone = .current
        $0.locale = .current
        $0.dateFormat = "EEEE, MMMM dd"
    }

    private var scheduler: TestScheduler!
    private var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()

        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        homeViewModel = nil
        mockNimbleSurveyClient = nil
        scheduler = nil

        super.tearDown()
    }

    func testSingleElementData() {
        guard let date = dateFormatter.date(from: "2022-05-19 12:00:00") else {
            fatalError("Failed to parse date")
        }

        mockNimbleSurveyClient = MockNimbleSurveyClient()
        homeViewModel = HomeViewModel(nimbleSurveyClient: mockNimbleSurveyClient)

        let viewDidLoadTrigger = scheduler.createColdObservable([
            .next(100, date)
        ])

        let loadMoreTrigger = scheduler.createColdObservable(
            [Recorded<Event<Void>>]()
        )

        let retryTrigger = scheduler.createColdObservable(
            [Recorded<Event<Void>>]()
        )

        let input = HomeViewModel.Input(
            viewDidLoadTrigger: viewDidLoadTrigger.asObservable(),
            loadMoreTrigger: loadMoreTrigger.asObservable(),
            retryTrigger: retryTrigger.asObservable()
        )

        let output = homeViewModel.transform(input: input)
        let subtitle = scheduler.createObserver(String.self)
        let headline = scheduler.createObserver(String.self)
        let avatarImage = scheduler.createObserver(UIImage?.self)

        output.subtitle
            .drive(subtitle)
            .disposed(by: disposeBag)

        output.headline
            .drive(headline)
            .disposed(by: disposeBag)

        output.avatarImage
            .drive(avatarImage)
            .disposed(by: disposeBag)

        scheduler.start()

        let expectedHeadline = Recorded.events([
            .next(0, R.string.localizable.home_today()),
            .completed(0)
        ])

        let expectedSubtitle = Recorded.events([
            .next(100, outputDateFormater.string(from: date).uppercased()),
            .completed(100)
        ])

        let expectedAvatarImage = Recorded.events([
            .next(0, R.image.avatar()),
            .completed(0)
        ])

        XCTAssertEqual(subtitle.events, expectedSubtitle)
        XCTAssertEqual(headline.events, expectedHeadline)
        XCTAssertEqual(avatarImage.events, expectedAvatarImage)
    }

    func testGetSurveyListFailEmptySectionWhenViewModelDeallocated() {
        guard let date = dateFormatter.date(from: "2022-05-19 12:00:00") else {
            fatalError("Failed to parse date")
        }

        mockNimbleSurveyClient = MockNimbleSurveyClient()
        mockNimbleSurveyClient.surveyListResult = .failure(.unknown)
        homeViewModel = HomeViewModel(nimbleSurveyClient: mockNimbleSurveyClient)

        let viewDidLoadTrigger = scheduler.createColdObservable([
            .next(100, date)
        ])

        let loadMoreTrigger = scheduler.createColdObservable(
            [Recorded<Event<Void>>]()
        )

        let retryTrigger = scheduler.createColdObservable(
            [Recorded<Event<Void>>]()
        )

        let input = HomeViewModel.Input(
            viewDidLoadTrigger: viewDidLoadTrigger.asObservable(),
            loadMoreTrigger: loadMoreTrigger.asObservable(),
            retryTrigger: retryTrigger.asObservable()
        )

        let output = homeViewModel.transform(input: input)

        let (
            showingHeaderView,
            enableRetry,
            loadingMore,
            sections,
            error
        ) = scheduler.createHomeViewModelObservers()

        disposeBag.insert(
            output.showingHeaderView.drive(showingHeaderView),
            output.enableRetry.drive(enableRetry),
            output.loadingMore.drive(loadingMore),
            output.sections.drive(sections),
            output.error.drive(error)
        )

        // Nil out `homeViewModel`
        homeViewModel = nil
        scheduler.start()

        let expectedShowingHeaderView = Recorded<Event<Bool>>.events([])
        let expectedEnableRetry = Recorded.events([
            .next(0, false)
        ])

        let expectedLoadingMore = Recorded.events([
            .next(0, false)
        ])

        let expectedSections = Recorded.events([
            .next(0, [HomeViewModel.Section(items: [])])
        ])

        let expectedError = Recorded<Event<SurveyListError>>.events([])

        XCTAssertEqual(showingHeaderView.events, expectedShowingHeaderView)
        XCTAssertEqual(enableRetry.events, expectedEnableRetry)
        XCTAssertEqual(loadingMore.events, expectedLoadingMore)
        XCTAssertEqual(sections.events, expectedSections)
        XCTAssertEqual(error.events, expectedError)
    }

    func testGetSurveyListViewDidLoadFailThenRetryFail() {
        guard let date = dateFormatter.date(from: "2022-05-19 12:00:00") else {
            fatalError("Failed to parse date")
        }

        mockNimbleSurveyClient = MockNimbleSurveyClient()
        mockNimbleSurveyClient.surveyListResult = .failure(.unknown)
        homeViewModel = HomeViewModel(nimbleSurveyClient: mockNimbleSurveyClient)

        let viewDidLoadTrigger = scheduler.createColdObservable([
            .next(100, date)
        ])

        let loadMoreTrigger = scheduler.createColdObservable(
            [Recorded<Event<Void>>]()
        )

        let retryTrigger = scheduler.createColdObservable([
            .next(200, ())
        ])

        let input = HomeViewModel.Input(
            viewDidLoadTrigger: viewDidLoadTrigger.asObservable(),
            loadMoreTrigger: loadMoreTrigger.asObservable(),
            retryTrigger: retryTrigger.asObservable()
        )

        let output = homeViewModel.transform(input: input)

        let (
            showingHeaderView,
            enableRetry,
            loadingMore,
            sections,
            error
        ) = scheduler.createHomeViewModelObservers()

        disposeBag.insert(
            output.showingHeaderView.drive(showingHeaderView),
            output.enableRetry.drive(enableRetry),
            output.loadingMore.drive(loadingMore),
            output.sections.drive(sections),
            output.error.drive(error)
        )

        scheduler.start()

        let expectedShowingHeaderView = Recorded.events([
            .next(100, true),
            .next(100, false),
            .next(200, true),
            .next(200, false)
        ])

        let expectedEnableRetry = Recorded.events([
            .next(0, false),
            .next(100, false),
            .next(100, true),
            .next(200, false),
            .next(200, true)
        ])

        let expectedLoadingMore = Recorded.events([
            .next(0, false)
        ])

        let expectedSections = Recorded<Event<[HomeViewModel.Section]>>.events([
            .next(0, [.init(items: [])]),
            .next(100, [.init(items: [HomeViewModel.SectionItem.placeholder])]),
            .next(100, [.init(items: [])]),
            .next(200, [.init(items: [HomeViewModel.SectionItem.placeholder])]),
            .next(200, [.init(items: [])])
        ])

        let expectedError = Recorded.events([
            .next(100, SurveyListError.failToRefresh),
            .next(200, SurveyListError.failToRefresh)
        ])

        XCTAssertEqual(showingHeaderView.events, expectedShowingHeaderView)
        XCTAssertEqual(enableRetry.events, expectedEnableRetry)
        XCTAssertEqual(loadingMore.events, expectedLoadingMore)
        XCTAssertEqual(sections.events, expectedSections)
        XCTAssertEqual(error.events, expectedError)
    }

    func testViewDidLoadGetSurveyListSucceed() {
        guard let date = dateFormatter.date(from: "2022-05-19 12:00:00") else {
            fatalError("Failed to parse date")
        }

        let survey = Survey(
            id: "123",
            title: "Lorem",
            description: "Lorem",
            coverImageUrl: nil
        )

        mockNimbleSurveyClient = MockNimbleSurveyClient()
        mockNimbleSurveyClient.surveyListResult = .success([survey])
        homeViewModel = HomeViewModel(nimbleSurveyClient: mockNimbleSurveyClient)

        let viewDidLoadTrigger = scheduler.createColdObservable([
            .next(100, date)
        ])

        let loadMoreTrigger = scheduler.createColdObservable(
            [Recorded<Event<Void>>]()
        )

        let retryTrigger = scheduler.createColdObservable(
            [Recorded<Event<Void>>]()
        )

        let input = HomeViewModel.Input(
            viewDidLoadTrigger: viewDidLoadTrigger.asObservable(),
            loadMoreTrigger: loadMoreTrigger.asObservable(),
            retryTrigger: retryTrigger.asObservable()
        )

        let output = homeViewModel.transform(input: input)

        let (
            showingHeaderView,
            enableRetry,
            loadingMore,
            sections,
            error
        ) = scheduler.createHomeViewModelObservers()

        disposeBag.insert(
            output.showingHeaderView.drive(showingHeaderView),
            output.enableRetry.drive(enableRetry),
            output.loadingMore.drive(loadingMore),
            output.sections.drive(sections),
            output.error.drive(error)
        )

        scheduler.start()

        let expectedShowingHeaderView = Recorded.events([
            .next(100, true),
            .next(100, false)
        ])

        let expectedEnableRetry = Recorded.events([
            .next(0, false),
            .next(100, false)
        ])

        let expectedLoadingMore = Recorded.events([
            .next(0, false)
        ])

        let surveyViewModel = SurveyViewModel(survey: survey)
        let expectedSections = Recorded<Event<[HomeViewModel.Section]>>.events([
            .next(0, [.init(items: [])]),
            .next(100, [.init(items: [HomeViewModel.SectionItem.placeholder])]),
            .next(100, [.init(items: [HomeViewModel.SectionItem.survey(surveyViewModel)])])
        ])

        let expectedError = Recorded<Event<SurveyListError>>.events([])

        XCTAssertEqual(showingHeaderView.events, expectedShowingHeaderView)
        XCTAssertEqual(enableRetry.events, expectedEnableRetry)
        XCTAssertEqual(loadingMore.events, expectedLoadingMore)
        XCTAssertEqual(sections.events, expectedSections)
        XCTAssertEqual(error.events, expectedError)
    }

    func testGetSurveyListLoadMoreFailGettingData() {
        mockNimbleSurveyClient = MockNimbleSurveyClient()
        mockNimbleSurveyClient.surveyListResult = .failure(.unknown)
        homeViewModel = HomeViewModel(nimbleSurveyClient: mockNimbleSurveyClient)

        let viewDidLoadTrigger = scheduler.createColdObservable(
            [Recorded<Event<Date>>]()
        )

        // Hack here: load more when view did load hasn't been triggered!!!
        let loadMoreTrigger = scheduler.createColdObservable([
            .next(100, ())
        ])

        let retryTrigger = scheduler.createColdObservable(
            [Recorded<Event<Void>>]()
        )

        let input = HomeViewModel.Input(
            viewDidLoadTrigger: viewDidLoadTrigger.asObservable(),
            loadMoreTrigger: loadMoreTrigger.asObservable(),
            retryTrigger: retryTrigger.asObservable()
        )

        let output = homeViewModel.transform(input: input)

        let (
            showingHeaderView,
            enableRetry,
            loadingMore,
            sections,
            error
        ) = scheduler.createHomeViewModelObservers()

        disposeBag.insert(
            output.showingHeaderView.drive(showingHeaderView),
            output.enableRetry.drive(enableRetry),
            output.loadingMore.drive(loadingMore),
            output.sections.drive(sections),
            output.error.drive(error)
        )

        scheduler.start()

        let expectedShowingHeaderView = Recorded<Event<Bool>>.events([])

        let expectedEnableRetry = Recorded.events([
            .next(0, false)
        ])

        let expectedLoadingMore = Recorded.events([
            .next(0, false),
            .next(100, true),
            .next(100, false)
        ])

        let expectedSections = Recorded<Event<[HomeViewModel.Section]>>.events([
            .next(0, [.init(items: [])]),
            .next(100, [.init(items: [])])
        ])

        let expectedError = Recorded.events([
            .next(100, SurveyListError.failToLoadmore)
        ])

        XCTAssertEqual(showingHeaderView.events, expectedShowingHeaderView)
        XCTAssertEqual(enableRetry.events, expectedEnableRetry)
        XCTAssertEqual(loadingMore.events, expectedLoadingMore)
        XCTAssertEqual(sections.events, expectedSections)
        XCTAssertEqual(error.events, expectedError)
    }

    func testGetSurveyListLoadMoreFailAuthorizing() {
        mockNimbleSurveyClient = MockNimbleSurveyClient()
        mockNimbleSurveyClient.surveyListResult = .failure(.unAuthorized)
        homeViewModel = HomeViewModel(nimbleSurveyClient: mockNimbleSurveyClient)

        let viewDidLoadTrigger = scheduler.createColdObservable(
            [Recorded<Event<Date>>]()
        )

        // Hack here: load more when view did load hasn't been triggered!!!
        let loadMoreTrigger = scheduler.createColdObservable([
            .next(100, ())
        ])

        let retryTrigger = scheduler.createColdObservable(
            [Recorded<Event<Void>>]()
        )

        let input = HomeViewModel.Input(
            viewDidLoadTrigger: viewDidLoadTrigger.asObservable(),
            loadMoreTrigger: loadMoreTrigger.asObservable(),
            retryTrigger: retryTrigger.asObservable()
        )

        let output = homeViewModel.transform(input: input)

        let (
            showingHeaderView,
            enableRetry,
            loadingMore,
            sections,
            error
        ) = scheduler.createHomeViewModelObservers()

        disposeBag.insert(
            output.showingHeaderView.drive(showingHeaderView),
            output.enableRetry.drive(enableRetry),
            output.loadingMore.drive(loadingMore),
            output.sections.drive(sections),
            output.error.drive(error)
        )

        scheduler.start()

        let expectedShowingHeaderView = Recorded<Event<Bool>>.events([])

        let expectedEnableRetry = Recorded.events([
            .next(0, false)
        ])

        let expectedLoadingMore = Recorded.events([
            .next(0, false),
            .next(100, true),
            .next(100, false)
        ])

        let expectedSections = Recorded<Event<[HomeViewModel.Section]>>.events([
            .next(0, [.init(items: [])]),
            .next(100, [.init(items: [])])
        ])

        let expectedError = Recorded.events([
            .next(100, SurveyListError.unAuthorized)
        ])

        XCTAssertEqual(showingHeaderView.events, expectedShowingHeaderView)
        XCTAssertEqual(enableRetry.events, expectedEnableRetry)
        XCTAssertEqual(loadingMore.events, expectedLoadingMore)
        XCTAssertEqual(sections.events, expectedSections)
        XCTAssertEqual(error.events, expectedError)
    }

    func testLoadMoreSurveyListSucceed() {
        let survey = Survey(
            id: "123",
            title: "Lorem",
            description: "Lorem",
            coverImageUrl: nil
        )

        mockNimbleSurveyClient = MockNimbleSurveyClient()
        mockNimbleSurveyClient.surveyListResult = .success([survey])
        homeViewModel = HomeViewModel(nimbleSurveyClient: mockNimbleSurveyClient)

        let viewDidLoadTrigger = scheduler.createColdObservable(
            [Recorded<Event<Date>>]()
        )

        // Hack here: load more when view did load hasn't been triggered!!!
        let loadMoreTrigger = scheduler.createColdObservable([
            .next(100, ())
        ])

        let retryTrigger = scheduler.createColdObservable(
            [Recorded<Event<Void>>]()
        )

        let input = HomeViewModel.Input(
            viewDidLoadTrigger: viewDidLoadTrigger.asObservable(),
            loadMoreTrigger: loadMoreTrigger.asObservable(),
            retryTrigger: retryTrigger.asObservable()
        )

        let output = homeViewModel.transform(input: input)

        let (
            showingHeaderView,
            enableRetry,
            loadingMore,
            sections,
            error
        ) = scheduler.createHomeViewModelObservers()

        disposeBag.insert(
            output.showingHeaderView.drive(showingHeaderView),
            output.enableRetry.drive(enableRetry),
            output.loadingMore.drive(loadingMore),
            output.sections.drive(sections),
            output.error.drive(error)
        )

        scheduler.start()

        let expectedShowingHeaderView = Recorded<Event<Bool>>.events([])

        let expectedEnableRetry = Recorded.events([
            .next(0, false)
        ])

        let expectedLoadingMore = Recorded.events([
            .next(0, false),
            .next(100, true),
            .next(100, false)
        ])

        let surveyViewModel = SurveyViewModel(survey: survey)
        let expectedSections = Recorded<Event<[HomeViewModel.Section]>>.events([
            .next(0, [.init(items: [])]),
            .next(100, [.init(items: [HomeViewModel.SectionItem.survey(surveyViewModel)])])
        ])

        let expectedError = Recorded<Event<SurveyListError>>.events([])

        XCTAssertEqual(showingHeaderView.events, expectedShowingHeaderView)
        XCTAssertEqual(enableRetry.events, expectedEnableRetry)
        XCTAssertEqual(loadingMore.events, expectedLoadingMore)
        XCTAssertEqual(sections.events, expectedSections)
        XCTAssertEqual(error.events, expectedError)
    }
}

// MARK: - Helpers

extension TestScheduler {
    // swiftlint:disable:next large_tuple
    func createHomeViewModelObservers() -> (
        TestableObserver<Bool>,
        TestableObserver<Bool>,
        TestableObserver<Bool>,
        TestableObserver<[HomeViewModel.Section]>,
        TestableObserver<SurveyListError>
    ) {
        return (
            createObserver(Bool.self),
            createObserver(Bool.self),
            createObserver(Bool.self),
            createObserver([HomeViewModel.Section].self),
            createObserver(SurveyListError.self)
        )
    }
}
