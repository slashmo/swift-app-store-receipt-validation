# AppStoreReceiptValidation

[![Swift 5.1](https://img.shields.io/badge/Swift-5.1-blue.svg)](https://swift.org/download/)
[![github-actions](https://github.com/fabianfett/swift-aws-lambda/workflows/CI/badge.svg)](https://github.com/fabianfett/swift-aws-lambda/actions)
[![codecov](https://codecov.io/gh/fabianfett/swift-app-store-receipt-validation/branch/master/graph/badge.svg)](https://codecov.io/gh/fabianfett/swift-app-store-receipt-validation)
![macOS](https://img.shields.io/badge/os-macOS-green.svg?style=flat)
![tuxOS](https://img.shields.io/badge/os-tuxOS-green.svg?style=flat)

This package implements the [validating receipts with the app store](https://developer.apple.com/library/archive/releasenotes/General/ValidateAppStoreReceipt/Chapters/ValidateRemotely.html#//apple_ref/doc/uid/TP40010573-CH104-SW1) api.

## Features:

- [x] Great swift server citizen: Uses [`AsyncHTTPClient`](https://github.com/swift-server/async-http-client) and [`Swift-NIO`](https://github.com/apple/swift-nio) under the hood.
- [x] Automatic retry, if sandbox receipt was send to production.
- [x] Response object is pure swift struct using enums.
- [x] API Erros are translated into corresponding swift errors.
