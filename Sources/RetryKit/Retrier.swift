//
//  Retrier.swift
//  Created by Marcel Voß on 26.03.21.
//

import Foundation

/// An object that provides and handles a retry mechanism for `Task` objects.
public struct Retrier {
    public enum Strategy {
        /// A strategy that performs immediate attempts without adding any delay in between.
        case immediate

        /// A strategy that performs retries with adding a constant delay between each attempt.
        case after(delay: TimeInterval)

        /// A strategy that can be customized and receives the current attempt as a parameter for calculations.
        case custom((Int) -> TimeInterval)

        func delayInterval(for currentAttempt: Int) -> TimeInterval {
            switch self {
            case .immediate:
                return .zero
            case .after(let interval):
                return interval
            case .custom(let closure):
                return closure(currentAttempt)
            }
        }
    }

    // MARK: - Properties
    private let strategy: Strategy
    private let dispatchQueue: DispatchQueue

    // MARK: - Initializer
    /// Initializes a new instance.
    /// - Parameters:
    ///   - strategy: The strategy that is being used for retrying.
    ///   - dispatchQueue: The queue tasks are being dispatched to.
    public init(strategy: Strategy = .immediate, dispatchQueue: DispatchQueue) {
        self.strategy = strategy
        self.dispatchQueue = dispatchQueue
    }

    // MARK: - Retry
    /// Begins retrying a task.
    /// - Parameters:
    ///   - task: The task that should be retried.
    ///   - completion: The completion that is being executed once further retries are not possible anymore.
    ///                 This will be executed on the queue that this object has been initialized with.
    public func begin<Output>(_ task: Task<Output>, completion: (() -> Void)? = nil) {
        guard task.canRetry else {
            dispatchQueue.async {
                completion?()
            }
            return
        }

        let workItem = DispatchWorkItem {
            task.work { [self] output in
                // validate whether output is acceptable, otherwise attempt retry
                guard task.outputValidation(output) else {
                    return
                }

                begin(task.createTask(attempts: task.attempts + 1), completion: completion)
            }
        }

        // delay execution by strategy's time interval
        let timeInterval = strategy.delayInterval(for: task.attempts)
        dispatchQueue.asyncAfter(deadline: .now() + timeInterval, execute: workItem)
    }
}
