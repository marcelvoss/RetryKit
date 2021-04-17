import XCTest
@testable import RetryKit

final class RetrierTests: XCTestCase {

    func testRespectsMaximumAttemptLimit() {
        var count = 0

        let task = Task<Int>(maximumAttempts: 2, work: {
            count += 1
            $0(1)
        }, outputValidation: { $0 < 5 })

        let retrier = Retrier(strategy: .immediate, dispatchQueue: .main)
        retrier.begin(task) {
            XCTAssertEqual(count, 2)
        }
    }

    func testDispatchesWorkToCorrectQueue() {
        let task = Task<Int>(maximumAttempts: 2, work: {
            XCTAssertTrue(Thread.isMainThread)
            $0(1)
        }, outputValidation: { _ in
            XCTAssertTrue(Thread.isMainThread)
            return false
        })

        DispatchQueue(label: "com.marcelvoss.retrykit.tests", qos: .background).async {
            XCTAssertFalse(Thread.isMainThread)

            let retrier = Retrier(strategy: .immediate, dispatchQueue: .main)
            retrier.begin(task) {
                XCTAssertTrue(Thread.isMainThread)
            }
        }
    }

    func testRespectsValidationClosure() {
        var count = 0
        let task = Task<Int>(maximumAttempts: 5, work: {
            count += 1
            $0(1)
        }, outputValidation: { $0 != 1 })

        let retrier = Retrier(strategy: .immediate, dispatchQueue: .main)
        retrier.begin(task) {
            XCTAssertEqual(count, 1)
        }
    }

    // MARK: - Strategies
    func testDelayForImmediateStrategy() {
        let strategy: Retrier.Strategy = .immediate
        XCTAssertEqual(strategy.delayInterval(for: 1), .zero)
        XCTAssertEqual(strategy.delayInterval(for: 5), .zero)
        XCTAssertEqual(strategy.delayInterval(for: 10), .zero)
    }

    func testDelayForAfterDelayStrategy() {
        let strategy: Retrier.Strategy = .after(delay: 2)
        XCTAssertEqual(strategy.delayInterval(for: 1), 2.0)
        XCTAssertEqual(strategy.delayInterval(for: 5), 2.0)
        XCTAssertEqual(strategy.delayInterval(for: 10), 2.0)
    }

    func testDelayForCustomStrategy() {
        let strategy: Retrier.Strategy = .custom { TimeInterval($0 * 2) }

        XCTAssertEqual(strategy.delayInterval(for: 1), 2.0)
        XCTAssertEqual(strategy.delayInterval(for: 5), 10.0)
        XCTAssertEqual(strategy.delayInterval(for: 10), 20.0)
    }
    
}
