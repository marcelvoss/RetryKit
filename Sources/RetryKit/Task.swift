//
//  Task.swift
//  Created by Marcel Voß on 26.03.21.
//

import Foundation

/// An object that represents any work that can be tried again.
public struct Task<Output> {
    public typealias WorkClosure = (@escaping (Output) -> Void) -> Void
    public typealias OutputValidationClosure = (Output) -> Bool

    let work: WorkClosure
    let outputValidation: OutputValidationClosure

    private(set) var attempts = 0
    private let maximumAttempts: Int

    public init(maximumAttempts: Int, work: @escaping WorkClosure, outputValidation: @escaping OutputValidationClosure) {
        self.maximumAttempts = maximumAttempts
        self.work = work
        self.outputValidation = outputValidation
    }

    func createTask(attempts: Int) -> Self {
        var aTask = Task(maximumAttempts: maximumAttempts, work: work, outputValidation: outputValidation)
        aTask.attempts = attempts
        return aTask
    }

    var canRetry: Bool {
        attempts < maximumAttempts
    }
}
