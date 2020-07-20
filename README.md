# AppStoreReceiptValidation

[![Swift 5.1](https://img.shields.io/badge/Swift-5.1-blue.svg)](https://swift.org/download/)
[![github-actions](https://github.com/fabianfett/swift-aws-lambda/workflows/CI/badge.svg)](https://github.com/fabianfett/swift-aws-lambda/actions)
[![codecov](https://codecov.io/gh/fabianfett/swift-app-store-receipt-validation/branch/master/graph/badge.svg)](https://codecov.io/gh/fabianfett/swift-app-store-receipt-validation)

This package implements the [validating receipts with the app store](https://developer.apple.com/library/archive/releasenotes/General/ValidateAppStoreReceipt/Chapters/ValidateRemotely.html#//apple_ref/doc/uid/TP40010573-CH104-SW1) api.

## Features:

- [x] Great swift server citizen: Uses [`AsyncHTTPClient`](https://github.com/swift-server/async-http-client) and [`Swift-NIO`](https://github.com/apple/swift-nio) under the hood.
- [x] Automatic retry, if sandbox receipt was send to production.
- [x] Response object is pure swift struct using enums.
- [x] API Erros are translated into corresponding swift errors.

## Usage

Add `swift-app-store-receipt-validation`, `async-http-client` and `swift-nio` as dependencies to 
your project. For this open your `Package.swift` and add this to your dependencies:

```swift
  dependencies: [
    .package(url: "https://github.com/swift-server/async-http-client", .upToNextMajor(from: "1.1.0")),
    .package(url: "https://github.com/apple/swift-nio", .upToNextMajor(from: "2.14.0")),
    .package(url: "https://github.com/fabianfett/swift-app-store-receipt-validation", .upToNextMajor(from: "0.1.0")),
  ]
```
  
Then, add `AsyncHTTPClient`, `SwiftNIO` and `AppStoreReceiptValidation` as target dependencies.

```swift
  targets: [
    .target(name: "Hello", dependencies: [
      .product(name: "NIO", package: "swift-nio"),
      .product(name: "AsyncHTTPClient", package: "async-http-client"),
      .product(name: "AppStoreReceiptValidation", package: "swift-app-store-receipt-validation"),
    ]
  ]
```

To verify an AppStore Receipt in your code you need to create an `HTTPClient` first:

```swift

let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
defer { try? httpClient.syncShutdown() }

let appStoreClient = AppStoreClient(httpClient: httpClient, secret: "abc123")

let base64EncodedReceipt: String = ...
let receipt = try appStoreClient.validateReceipt(base64EncodedReceipt).wait()
```
