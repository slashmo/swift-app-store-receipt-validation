import struct Foundation.Date

extension AppStore {
    public enum Error: Swift.Error {
        /// The App Store could not read the JSON object you provided.
        case invalidJSONObject

        /// The data in the receipt-data property was malformed or missing.
        case receiptDataMalformedOrMissing

        /// The receipt could not be authenticated.
        case receiptCouldNotBeAuthenticated

        /// The shared secret you provided does not match the shared secret on file for your account.
        case sharedSecretDoesNotMatchTheSharedSecretOnFileForAccount

        /// The receipt server is not currently available.
        case receiptServerIsCurrentlyUnavailable

        /// This receipt is valid but the subscription has expired. When this status code is returned to your server, the receipt data
        /// is also decoded and returned as part of the response.
        /// _Only returned for iOS 6 style transaction receipts for auto-renewable subscriptions._
        case receiptIsValidButSubscriptionHasExpired

        /// This receipt is from the test environment, but it was sent to the production environment for verification.
        /// Send it to the test environment instead.
        case receiptIsFromTestEnvironmentButWasSentToProductionEnvironment

        /// This receipt is from the production environment, but it was sent to the test environment for verification.
        /// Send it to the production environment instead.
        case receiptIsFromProductionEnvironmentButWasSentToTestEnvironment

        /// This receipt could not be authorized. Treat this the same as if a purchase was never made.
        case receiptCouldNotBeAuthorized

        /// Internal data access error.
        case internalDataAccessError

        /// Catch all error introduced by this library to handle unknown status codes
        case unknownError

        init(statusCode: Int) {
            switch statusCode {
            case 21000:
                self = .invalidJSONObject
            case 21002:
                self = .receiptDataMalformedOrMissing
            case 21003:
                self = .receiptCouldNotBeAuthenticated
            case 21004:
                self = .sharedSecretDoesNotMatchTheSharedSecretOnFileForAccount
            case 21005:
                self = .receiptServerIsCurrentlyUnavailable
            case 21006:
                self = .receiptIsValidButSubscriptionHasExpired
            case 21007:
                self = .receiptIsFromTestEnvironmentButWasSentToProductionEnvironment
            case 21008:
                self = .receiptIsFromProductionEnvironmentButWasSentToTestEnvironment
            case 21010:
                self = .receiptCouldNotBeAuthorized
            case 21100 ... 21199:
                self = .internalDataAccessError
            default:
                self = .unknownError
            }
        }
    }

    public struct Receipt: Codable {
        public let bundleId: String
        public let applicationVersion: String
        public let inApp: [InAppPurchase]
        public let originalApplicationVersion: String
        public let receiptCreationDate: Date
        public let receiptExpirationDate: Date?

        enum CodingKeys: String, CodingKey {
            case bundleId = "bundle_id"
            case applicationVersion = "application_version"
            case inApp = "in_app"
            case originalApplicationVersion = "original_application_version"
            case receiptCreationDate = "receipt_creation_date_ms"
            case receiptExpirationDate = "receipt_expiration_date_ms"
        }
    }

    public struct InAppPurchase: Codable {
        /// The number of items purchased.
        ///
        /// This value corresponds to the quantity property of the SKPayment object stored in the transaction’s payment property.
        public let quantity: String

        /// The product identifier of the item that was purchased.
        ///
        /// This value corresponds to the productIdentifier property of the SKPayment object stored in the transaction’s payment property.
        public let productId: String

        /// The transaction identifier of the item that was purchased.
        ///
        /// This value corresponds to the transaction’s `transactionIdentifier` property.
        ///
        /// For a transaction that restores a previous transaction, this value is different from the transaction identifier of the original
        /// purchase transaction. In an auto-renewable subscription receipt, a new value for the transaction identifier is generated every
        /// time the subscription automatically renews or is restored on a new device.
        public let transactionId: String

        /// For a transaction that restores a previous transaction, the transaction identifier of the original transaction. Otherwise, identical
        /// to the transaction identifier.
        ///
        /// This value corresponds to the original transaction’s transactionIdentifier property.
        ///
        /// This value is the same for all receipts that have been generated for a specific subscription. This value is useful for relating
        /// together multiple iOS 6 style transaction receipts for the same individual customer’s subscription.
        public let originalTransactionId: String

        /// The date and time that the item was purchased.
        ///
        /// This value corresponds to the transaction’s transactionDate property.
        ///
        /// For a transaction that restores a previous transaction, the purchase date is the same as the original purchase date. Use
        /// Original Purchase Date to get the date of the original transaction.
        ///
        /// In an auto-renewable subscription receipt, the purchase date is the date when the subscription was either purchased or
        /// renewed (with or without a lapse). For an automatic renewal that occurs on the expiration date of the current period, the
        /// purchase date is the start date of the next period, which is identical to the end date of the current period.
        public let purchaseDate: Date

        /// For a transaction that restores a previous transaction, the date of the original transaction.
        ///
        /// This value corresponds to the original transaction’s transactionDate property.
        ///
        /// In an auto-renewable subscription receipt, this indicates the beginning of the subscription period, even if the subscription
        /// has been renewed.
        public let originalPurchaseDate: Date

        /// The expiration date for the subscription, expressed as the number of milliseconds since January 1, 1970, 00:00:00 GMT.
        ///
        /// This key is only present for auto-renewable subscription receipts. Use this value to identify the date when the subscription
        /// will renew or expire, to determine if a customer should have access to content or service. After validating the latest receipt,
        /// if the subscription expiration date for the latest renewal transaction is a past date, it is safe to assume that the subscription
        /// has expired.
        public let subscriptionExpirationDate: Date?

        /// For an expired subscription, the reason for the subscription expiration.
        ///
        /// - 1 - Customer canceled their subscription.
        /// - 2 - Billing error; for example customer’s payment information was no longer valid.
        /// - 3 - Customer did not agree to a recent price increase.
        /// - 4 - Product was not available for purchase at the time of renewal.
        /// - 5 - Unknown error.
        ///
        /// This key is only present for a receipt containing an expired auto-renewable subscription. You can use this value to decide
        /// whether to display appropriate messaging in your app for customers to resubscribe.
        public let subscriptionExpirationIntent: SubscriptionExpirationIntent?

        /// For an expired subscription, whether or not Apple is still attempting to automatically renew the subscription.
        ///
        /// - 1 - App Store is still attempting to renew the subscription.
        /// - 0 - App Store has stopped attempting to renew the subscription.
        ///
        /// This key is only present for auto-renewable subscription receipts. If the customer’s subscription failed to renew because
        /// the App Store was unable to complete the transaction, this value will reflect whether or not the App Store is still trying to
        /// renew the subscription.
        public let subscriptionRetryFlag: SubscriptionRetryFlag?

        /// For a subscription, whether or not it is in the free trial period.
        ///
        /// This key is only present for auto-renewable subscription receipts. The value for this key is "true" if the customer’s
        /// subscription is currently in the free trial period, or "false" if not.
        ///
        /// **Note**: If a previous subscription period in the receipt has the value “true” for either the `is_trial_period` or the
        ///          `is_in_intro_offer_period` key, the user is not eligible for a free trial or introductory price within that
        ///          subscription group.
        public let subscriptionTrialPeriod: SubscriptionTrialPeriod?

        /// For an auto-renewable subscription, whether or not it is in the introductory price period.
        ///
        /// This key is only present for auto-renewable subscription receipts. The value for this key is "true" if the customer’s
        /// subscription is currently in an introductory price period, or "false" if not.
        ///
        /// **Note**: If a previous subscription period in the receipt has the value “true” for either the `is_trial_period` or the
        ///          `is_in_intro_offer_period` key, the user is not eligible for a free trial or introductory price within that
        ///          subscription group.
        public let subscriptionIsInIntroductoryPricePeriod: SubscriptionIntroductoryPricePeriod?

        /// The current renewal status for the auto-renewable subscription.
        ///
        /// - 1 - Subscription will renew at the end of the current subscription period.
        /// - 0 - Customer has turned off automatic renewal for their subscription.
        ///
        /// This key is only present for auto-renewable subscription receipts, for active or expired subscriptions. The value for
        ///  this key should not be interpreted as the customer’s subscription status. You can use this value to display an
        ///  alternative subscription product in your app, for example, a lower level subscription plan that the customer can
        ///  downgrade to from their current plan.
        public let subscriptionAutoRenewStatus: SubscriptionAutoRenewStatus?

        /// The current renewal preference for the auto-renewable subscription.
        ///
        /// This key is only present for auto-renewable subscription receipts. The value for this key corresponds to the
        /// `productIdentifier` property of the product that the customer’s subscription renews. You can use this value to
        /// present an alternative service level to the customer before the current subscription period ends.
        public let subscriptionAutoRenewPreface: String?

        /// The current price consent status for a subscription price increase.
        ///
        /// - 1 - Customer has agreed to the price increase. Subscription will renew at the higher price.
        /// - 0 - Customer has not taken action regarding the increased price. Subscription expires if the customer
        ///      takes no action before the renewal date.
        ///
        /// This key is only present for auto-renewable subscription receipts if the subscription price was
        /// increased without keeping the existing price for active subscribers. You can use this value to
        /// track customer adoption of the new price and take appropriate action.
        public let subscriptionPriceConsentStatus: SubscriptionPriceConsentStatus?

        /// For a transaction that was canceled by Apple customer support, the time and date of the cancellation. For an
        /// auto-renewable subscription plan that was upgraded, the time and date of the upgrade transaction.
        ///
        /// Treat a canceled receipt the same as if no purchase had ever been made.
        ///
        /// **Note**: A canceled in-app purchase remains in the receipt indefinitely. Only applicable if the refund was for a
        ///          non-consumable product, an auto-renewable subscription, a non-renewing subscription, or for a
        ///          free subscription.
        public let cancellationDate: Date?

        /// For a transaction that was canceled, the reason for cancellation.
        ///
        /// - 1 - Customer canceled their transaction due to an actual or perceived issue within your app.
        /// - 0 - Transaction was canceled for another reason, for example, if the customer made the purchase accidentally.
        ///
        /// Use this value along with the cancellation date to identify possible issues in your app that may lead customers to
        /// contact Apple customer support.
        public let cancellationReason: CancellationReason?

        /// A string that the App Store uses to uniquely identify the application that created the transaction.
        ///
        /// If your server supports multiple applications, you can use this value to differentiate between them. Apps are assigned an
        /// identifier only in the production environment, so this key is not present for receipts created in the test environment.
        ///
        /// This field is not present for Mac apps.
        public let appItemId: String?

        /// An arbitrary number that uniquely identifies a revision of your application.
        ///
        /// This key is not present for receipts created in the test environment. Use this value to identify the version of the app that
        /// the customer bought.
        public let externalVersionIdentifier: String?

        /// The primary key for identifying subscription purchases.
        ///
        /// This value is a unique ID that identifies purchase events across devices, including subscription renewal purchase events.
        public let webOrderLineItemId: String?

        enum CodingKeys: String, CodingKey {
            case quantity
            case productId = "product_id"
            case transactionId = "transaction_id"
            case originalTransactionId = "original_transaction_id"
            case purchaseDate = "purchase_date_ms"
            case originalPurchaseDate = "original_purchase_date_ms"
            case subscriptionExpirationDate = "subscription_expiration_date_ms"
            case subscriptionExpirationIntent = "expiration_intent"
            case subscriptionRetryFlag = "is_in_billing_retry_period"
            case subscriptionTrialPeriod = "is_trial_period"
            case subscriptionIsInIntroductoryPricePeriod = "is_in_intro_offer_period"
            case subscriptionAutoRenewStatus = "auto_renew_status"
            case subscriptionAutoRenewPreface = "auto_renew_product_id"
            case subscriptionPriceConsentStatus = "price_consent_status"
            case cancellationDate = "cancellationDateMS"
            case cancellationReason = "cancellation_reason"
            case appItemId = "app_item_id"
            case externalVersionIdentifier = "version_external_identifier"
            case webOrderLineItemId = "web_order_line_item_id"
        }
    }

    public enum SubscriptionExpirationIntent: String, Codable {
        case customerCancelled = "1"
        case billingError = "2"
        case customerDidNotAgreeWithPriceIncrease = "3"
        case productWasUnavailableAtTimeOfRenewal = "4"
        case unknownError = "5"
    }

    public enum SubscriptionRetryFlag: String, Codable {
        case appStoreStillAttemptingToRenewSubscription = "0"
        case appStoreHasStoppedAttemptingToRenewTheSubscription = "1"
    }

    public enum SubscriptionTrialPeriod: String, Codable {
        case isInFreeTrial = "true"
        case isNotInFreeTrial = "false"
    }

    public enum SubscriptionIntroductoryPricePeriod: String, Codable {
        case isInIntroductoryPricePeriod = "true"
        case isNotInIntroductoryPricePeriod = "false"
    }

    public enum SubscriptionAutoRenewStatus: String, Codable {
        case customerHasTurnedOffAutomaticRenewal = "0"
        case willRenew = "1"
    }

    public enum SubscriptionPriceConsentStatus: String, Codable {
        case customerHasNotTakenAction = "0"
        case customerHasAgreedToPriceIncrease = "1"
    }

    public enum CancellationReason: String, Codable {
        case actualOrPercivedIssueWithinTheApp = "1"
        case otherReason = "0"
    }
}

extension AppStore.Receipt {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.bundleId = try container.decode(String.self, forKey: .bundleId)
        self.applicationVersion = try container.decode(String.self, forKey: .applicationVersion)
        self.inApp = try container.decode([AppStore.InAppPurchase].self, forKey: .inApp)
        self.originalApplicationVersion = try container.decode(String.self, forKey: .originalApplicationVersion)
        self.receiptCreationDate = try container.decodeAppStoreDate(forKey: .receiptCreationDate)
        self.receiptExpirationDate = try container.decodeAppStoreDateIfPresent(forKey: .receiptExpirationDate)
    }
}

extension AppStore.InAppPurchase {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.quantity = try container.decode(String.self, forKey: .quantity)
        self.productId = try container.decode(String.self, forKey: .productId)
        self.transactionId = try container.decode(String.self, forKey: .transactionId)
        self.originalTransactionId = try container.decode(String.self, forKey: .originalTransactionId)
        self.purchaseDate = try container.decodeAppStoreDate(forKey: .purchaseDate)
        self.originalPurchaseDate = try container.decodeAppStoreDate(forKey: .originalPurchaseDate)
        self.subscriptionExpirationDate = try container.decodeAppStoreDateIfPresent(forKey: .subscriptionExpirationDate)
        self.subscriptionExpirationIntent = try container.decodeIfPresent(AppStore.SubscriptionExpirationIntent.self, forKey: .subscriptionExpirationIntent)
        self.subscriptionRetryFlag = try container.decodeIfPresent(AppStore.SubscriptionRetryFlag.self, forKey: .subscriptionRetryFlag)
        self.subscriptionTrialPeriod = try container.decodeIfPresent(AppStore.SubscriptionTrialPeriod.self, forKey: .subscriptionTrialPeriod)
        self.subscriptionIsInIntroductoryPricePeriod = try container.decodeIfPresent(AppStore.SubscriptionIntroductoryPricePeriod.self, forKey: .subscriptionIsInIntroductoryPricePeriod)
        self.subscriptionAutoRenewStatus = try container.decodeIfPresent(AppStore.SubscriptionAutoRenewStatus.self, forKey: .subscriptionAutoRenewStatus)
        self.subscriptionAutoRenewPreface = try container.decodeIfPresent(String.self, forKey: .subscriptionAutoRenewPreface)
        self.subscriptionPriceConsentStatus = try container.decodeIfPresent(AppStore.SubscriptionPriceConsentStatus.self, forKey: .subscriptionPriceConsentStatus)
        self.cancellationDate = try container.decodeAppStoreDateIfPresent(forKey: .cancellationDate)
        self.cancellationReason = try container.decodeIfPresent(AppStore.CancellationReason.self, forKey: .cancellationReason)
        self.appItemId = try container.decodeIfPresent(String.self, forKey: .appItemId)
        self.externalVersionIdentifier = try container.decodeIfPresent(String.self, forKey: .externalVersionIdentifier)
        self.webOrderLineItemId = try container.decodeIfPresent(String.self, forKey: .webOrderLineItemId)
    }
}

extension KeyedDecodingContainer {
    func decodeAppStoreDate(forKey key: K) throws -> Date {
        let string = try self.decode(String.self, forKey: key)

        guard let timeIntervalSince1970inMs = Double(string) else {
            throw DecodingError.dataCorruptedError(
                forKey: key,
                in: self,
                debugDescription: "Expected to have a TimeInterval in ms within the string to decode a date."
            )
        }

        return Date(timeIntervalSince1970: timeIntervalSince1970inMs / 1000)
    }

    func decodeAppStoreDateIfPresent(forKey key: K) throws -> Date? {
        guard let string = try self.decodeIfPresent(String.self, forKey: key) else {
            return nil
        }

        guard let timeIntervalSince1970inMs = Double(string) else {
            throw DecodingError.dataCorruptedError(
                forKey: key,
                in: self,
                debugDescription: "Expected to have a TimeInterval in ms within the string to decode a date."
            )
        }

        return Date(timeIntervalSince1970: timeIntervalSince1970inMs / 1000)
    }
}
