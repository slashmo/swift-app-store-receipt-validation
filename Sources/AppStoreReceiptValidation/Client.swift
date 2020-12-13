import AsyncHTTPClient
import class Foundation.JSONDecoder
import class Foundation.JSONEncoder
import NIO
import NIOFoundationCompat

public protocol AppStoreClientRequestEncoder {
    func encodeAsByteBuffer<T: Encodable>(_ value: T, allocator: ByteBufferAllocator) throws -> ByteBuffer
}

public protocol AppStoreClientResponseDecoder {
    func decode<T: Decodable>(_ type: T.Type, from: ByteBuffer) throws -> T
}

public enum AppStore {
    public struct Client {
        let httpClient: HTTPClient
        let secret: String?
        let allocator = ByteBufferAllocator()
        let encoder: AppStoreClientRequestEncoder
        let decoder: AppStoreClientResponseDecoder

        public init(httpClient: HTTPClient, secret: String?) {
            self.init(httpClient: httpClient,
                      encoder: JSONEncoder(),
                      decoder: JSONDecoder(),
                      secret: secret)
        }

        public init(
            httpClient: HTTPClient,
            encoder: AppStoreClientRequestEncoder,
            decoder: AppStoreClientResponseDecoder,
            secret: String?
        ) {
            self.httpClient = httpClient
            self.encoder = encoder
            self.decoder = decoder
            self.secret = secret
        }

        public func validateReceipt(
            _ receipt: String,
            excludeOldTransactions: Bool? = nil,
            allocator: ByteBufferAllocator? = nil,
            on eventLoop: EventLoop? = nil
        ) -> EventLoopFuture<Receipt> {
            let eventLoop = eventLoop ?? self.httpClient.eventLoopGroup.next()
            let allocator = allocator ?? self.allocator

            let request = Request(
                receiptData: receipt,
                password: self.secret,
                excludeOldTransactions: excludeOldTransactions
            )

            return executeRequest(request, in: .production, allocator: allocator, on: eventLoop)
                .flatMapError { (error) -> EventLoopFuture<AppStore.Response> in
                    switch error {
                    case Error.receiptIsFromTestEnvironmentButWasSentToProductionEnvironment:
                        return self.executeRequest(request, in: .sandbox, allocator: allocator, on: eventLoop)
                    default:
                        // TBD: This doesn't look good. Maybe we keep the eventLoopGroup for ourselfs?
                        return eventLoop.makeFailedFuture(error)
                    }
                }
                .map { (response) -> (Receipt) in
                    response.receipt
                }
        }

        private func executeRequest(
            _ request: Request,
            in environment: Environment,
            allocator: ByteBufferAllocator,
            on eventLoop: EventLoop
        ) -> EventLoopFuture<Response> {
            return eventLoop.makeSucceededFuture(())
                .flatMapThrowing { (_) -> HTTPClient.Request in
                    let buffer = try self.encoder.encodeAsByteBuffer(request, allocator: allocator)
                    return try HTTPClient.Request(url: environment.url, method: .POST, body: .byteBuffer(buffer))
                }
                .flatMap { (request) -> EventLoopFuture<HTTPClient.Response> in
                    self.httpClient.execute(request: request, eventLoop: .delegateAndChannel(on: eventLoop))
                }
                .flatMapThrowing { (resp) throws -> (Response) in
                    let status = try self.decoder.decode(Status.self, from: resp.body!)

                    if status.status != 0 {
                        throw Error(statusCode: status.status)
                    }

                    return try self.decoder.decode(Response.self, from: resp.body!)
                }
        }
    }
}

extension JSONEncoder: AppStoreClientRequestEncoder {}

extension JSONDecoder: AppStoreClientResponseDecoder {}
