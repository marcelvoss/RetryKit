# RetryKit

RetryKit is a tiny package that implements a flexible mechanism for retrying work based on strategies and outputs (and when using e.g. `NSOperation` is overkill).

## Installation

RetryKit is distributed using the Swift Package Manager. To install it into a project, add it as a dependency within your `Package.swift` manifest:

```swift
let package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/marcelvoss/RetryKit.git", from: "0.1.0")
    ],
    ...
)

```

Then import RetryKit wherever you’d like to use it:

```swift
import RetryKit
```

It's that simple! 🎉

## Usage

Using RetryKit is easy.

Work is being encapsulated in `Task` objects. These objects don't do anything else than keeping abstracting any work, providing an output validation closure and keeping the number of times they have been retried around. They're really simple, as reflected by their initializer:

```swift
let task = Task<Result<String, Error>>(maximumAttempts: 5, work: { output in
    // ...
}, outputValidation: { output in
    // ...
})
```

The output validation closure being called during retrying with the value of the produced output and allows for customizing whether work will be retried or not case-by-case. Therefore, it allows for simple but also pretty complex conditions.

`Task` objects are being dispatched by a `Retrier` object. `Retrier` objects are equally simple. They do have a single responsibility: dispatching tasks when appropriate.

### Strategies

RetryKit ships with three built-in different strategies for retrying: `immediate`, `after(delay: Int)`,`.custom((Int) -> TimeInterval)`.

#### .immediate
`.immediate` is the easiest from all of them. All work is being retried immediately without any delay in between. You might want to use this one when many repetitive retries is not a concern.

#### after(delay: TimeInterval)
`after(delay: TimeInterval)` does basically what you would expect by reading its interface. Work is being retried after a constant delay in between attempts.

#### .custom((Int) -> TimeInterval)
`.custom((Int) -> TimeInterval)` allows for most customization out of these three. The delay between attempts is being provided/calculcated by yourself using the number of retries that have happened so far.

A custom strategy is often most useful when you care about adding _some randomness_ to it and allows for using an [exponential backoff](https://en.wikipedia.org/wiki/Exponential_backoff) delay between attempts. 

