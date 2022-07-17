import Foundation
import SwiftSoup

extension Data {
  public func toDocument(encoding: String.Encoding = .utf8) throws -> Document? {
    var document: Document?

    if let html = String(data: self, encoding: encoding) {
      document = try SwiftSoup.parse(html)
    }

    return document
  }
}