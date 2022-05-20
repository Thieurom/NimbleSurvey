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

        let input = HomeViewModel.Input(
            viewDidLoadTrigger: viewDidLoadTrigger.asObservable()
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

    func testGetRurveyListFailEmptySection() {
        guard let date = dateFormatter.date(from: "2022-05-19 12:00:00") else {
            fatalError("Failed to parse date")
        }

        mockNimbleSurveyClient = MockNimbleSurveyClient()
        mockNimbleSurveyClient.surveyListResult = .failure(.unknown)
        homeViewModel = HomeViewModel(nimbleSurveyClient: mockNimbleSurveyClient)

        let viewDidLoadTrigger = scheduler.createColdObservable([
            .next(100, date)
        ])

        let input = HomeViewModel.Input(
            viewDidLoadTrigger: viewDidLoadTrigger.asObservable()
        )

        let output = homeViewModel.transform(input: input)
        let requestInFlight = scheduler.createObserver(Bool.self)
        let sections = scheduler.createObserver([HomeViewModel.Section].self)

        output.requestInFlight
            .drive(requestInFlight)
            .disposed(by: disposeBag)

        output.sections
            .drive(sections)
            .disposed(by: disposeBag)

        scheduler.start()

        let expectedRequestInFlight = Recorded.events([
            .next(100, true)
        ])

        let expectedSections = Recorded.events([
            .next(0, [HomeViewModel.Section(items: [HomeViewModel.SectionItem.placeholder])]),
            .next(100, [HomeViewModel.Section]()),
            .completed(100)
        ])

        XCTAssertEqual(requestInFlight.events, expectedRequestInFlight)
        XCTAssertEqual(sections.events, expectedSections)
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

        let input = HomeViewModel.Input(
            viewDidLoadTrigger: viewDidLoadTrigger.asObservable()
        )

        let output = homeViewModel.transform(input: input)
        let requestInFlight = scheduler.createObserver(Bool.self)
        let sections = scheduler.createObserver([HomeViewModel.Section].self)

        output.requestInFlight
            .drive(requestInFlight)
            .disposed(by: disposeBag)

        output.sections
            .drive(sections)
            .disposed(by: disposeBag)

        // Nil out `homeViewModel`
        homeViewModel = nil
        scheduler.start()

        let expectedRequestInFlight = Recorded<Event<Bool>>.events([])

        let expectedSections = Recorded.events([
            .next(0, [HomeViewModel.Section(items: [HomeViewModel.SectionItem.placeholder])])
        ])

        XCTAssertEqual(requestInFlight.events, expectedRequestInFlight)
        XCTAssertEqual(sections.events, expectedSections)
    }

    func testGetSurveyListSucceed() {
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

        let input = HomeViewModel.Input(
            viewDidLoadTrigger: viewDidLoadTrigger.asObservable()
        )

        let output = homeViewModel.transform(input: input)
        let requestInFlight = scheduler.createObserver(Bool.self)
        let sections = scheduler.createObserver([HomeViewModel.Section].self)

        output.requestInFlight
            .drive(requestInFlight)
            .disposed(by: disposeBag)

        output.sections
            .drive(sections)
            .disposed(by: disposeBag)

        scheduler.start()

        let expectedRequestInFlight = Recorded.events([
            .next(100, true),
            .next(100, false)
        ])

        let surveyViewModel = SurveyViewModel(survey: survey)

        let expectedSections = Recorded<Event<[HomeViewModel.Section]>>.events([
            .next(0, [.init(items: [HomeViewModel.SectionItem.placeholder])]),
            .next(100, [.init(items: [HomeViewModel.SectionItem.survey(surveyViewModel)])])
        ])

        XCTAssertEqual(requestInFlight.events, expectedRequestInFlight)
        XCTAssertEqual(sections.events, expectedSections)
    }
}
