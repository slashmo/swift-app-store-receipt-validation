import AsyncHTTPClient
import NIO

public protocol AppStoreClientRequestEncoder {
    func encode<T: Encodable>(_ value: T, using allocator: ByteBufferAllocator) throws -> ByteBuffer
}

public protocol AppStoreClientResponseDecoder {
    func decode<T: Decodable>(_ type: T.Type, from: ByteBuffer) throws -> T
}

public struct AppStoreClient {
    let httpClient: HTTPClient
    let secret: String?
    let allocator = ByteBufferAllocator()
    let encoder: AppStoreClientRequestEncoder
    let decoder: AppStoreClientResponseDecoder

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

    public func validateReceipt(_ receipt: String, excludeOldTransactions: Bool? = nil)
        -> EventLoopFuture<Receipt> {
        let request = Request(
            receiptData: receipt,
            password: secret,
            excludeOldTransactions: excludeOldTransactions
        )

        return executeRequest(request, in: .production)
            .flatMapError { (error) -> EventLoopFuture<AppStoreClient.Response> in
                switch error {
                case Error.receiptIsFromTestEnvironmentButWasSentToProductionEnvironment:
                    return self.executeRequest(request, in: .sandbox)
                default:
                    // TBD: This doesn't look good. Maybe we keep the eventLoopGroup for ourselfs?
                    return self.httpClient.eventLoopGroup.next().makeFailedFuture(error)
                }
            }
            .map { (response) -> (Receipt) in
                response.receipt
            }
    }

    private func executeRequest(_ request: Request, in environment: Environment)
        -> EventLoopFuture<Response> {
        let buffer = try! encoder.encode(request, using: allocator)

        return httpClient.post(url: environment.url, body: .byteBuffer(buffer), deadline: NIODeadline.now() + .seconds(5))
            .flatMapThrowing { (resp) throws -> (Response) in
                let status = try self.decoder.decode(Status.self, from: resp.body!)

                if status.status != 0 {
                    throw Error(statusCode: status.status)
                }

                return try self.decoder.decode(Response.self, from: resp.body!)
            }
    }
}
