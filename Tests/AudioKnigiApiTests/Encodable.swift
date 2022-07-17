import Foundation
import Codextended

extension Encodable {
  public func prettify() throws -> String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    if let result = String(data: try encoded(using: encoder), encoding: .utf8) {
      return result
    }
    else {
      return "<cannot encode>"
    }
  }
}