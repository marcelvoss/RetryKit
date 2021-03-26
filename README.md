# RetryKit

RetryKit is a tiny package that implements a mechanism for retrying work based on strategies (and when using e.g. `NSOperation` is overkill).

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

RetryKit ships with three different strategies for retrying: `immediate`, `after(delay: Int)`,`.custom((Int) -> TimeInterval)`.