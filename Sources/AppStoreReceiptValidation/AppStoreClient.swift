import Foundation
import NIO
import NIOFoundationCompat
import AsyncHTTPClient

public class AppStoreClient {
  
  let httpClient: HTTPClient
  let secret    : String?
  let allocator = ByteBufferAllocator()
  let encoder   = JSONEncoder()
  let decoder   = JSONDecoder() // TBD: 
  
  public init(eventLoopGroup: EventLoopGroup, secret: String?) {
    
    self.httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
    self.secret     = secret
    
    self.decoder.dateDecodingStrategy = .custom { (decoder) -> Date in
      let container = try decoder.singleValueContainer()
      let string    = try container.decode(String.self)
      
      guard let timeIntervalSince1970inMs = Double(string) else {
        throw DecodingError.dataCorruptedError(
          in: container,
          debugDescription: "Expected to have a TimeInterval in ms within the string to decode a date.")
      }
      
      return Date(timeIntervalSince1970: timeIntervalSince1970inMs / 1000)
    }
  }
  
  public func syncShutdown() throws {
    try self.httpClient.syncShutdown()
  }
  
  public func validateAppStoreReceipt(_ receipt: String, excludeOldTransactions: Bool? = nil)
    -> EventLoopFuture<Receipt>
  {
    let request = Request(
      receiptData: receipt,
      password: secret,
      excludeOldTransactions: excludeOldTransactions)
    
    return self.executeRequest(request, in: .production)
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
        return response.receipt
      }
  }
  
  private func executeRequest(
    _ request: Request,
    in environment: Environment) -> EventLoopFuture<Response>
  {
    let buffer = try! encoder.encodeAsByteBuffer(request, allocator: allocator)
    
    return self.httpClient.post(url: environment.url, body: .byteBuffer(buffer), deadline: NIODeadline.now() + .seconds(5))
      .flatMapThrowing { (resp) throws -> (Response) in
        let status = try self.decoder.decode(Status.self, from: resp.body!)
        
        if status.status != 0 {
          throw Error(statusCode: status.status)
        }
        
        return try self.decoder.decode(Response.self, from: resp.body!)
      }
  }
}
