import Foundation
import NIO

extension AppStoreClient {
  struct Request: Codable {
    let receiptData: String
    let password: String?
    let excludeOldTransactions: Bool?

    enum CodingKeys: String, CodingKey {
      case receiptData = "receipt-data"
      case password
      case excludeOldTransactions = "exclude-old-transactions"
    }
  }
}

extension AppStoreClient {
  struct Status: Codable {
    let status: Int
  }

  struct Response: Codable {
    let receipt: Receipt // json
    let latestReceipt: String?
    let latestReceiptInfo: Receipt? // json
//    let latestExpiredReceiptInfo: Any? // json
//    let pendingRenewalInfo: Any?
    let isRetryable: Bool?
    let environment: Environment

    enum CodingKeys: String, CodingKey {
      case receipt
      case latestReceipt = "latest_receipt"
      case latestReceiptInfo = "latest_receipt_info"
      case isRetryable = "is-retryable"
      case environment
    }
  }
}
