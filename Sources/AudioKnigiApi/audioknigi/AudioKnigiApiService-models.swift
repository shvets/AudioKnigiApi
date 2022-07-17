import Foundation
import SimpleHttpClient
import Codextended

extension AudioKnigiApiService {
  public typealias BookItem = [String: String]

  public struct Pagination: Codable {
    let page: Int
    let pages: Int
    let has_previous: Bool
    let has_next: Bool

    init(page: Int = 1, pages: Int = 1, has_previous: Bool = false, has_next: Bool = false) {
      self.page = page
      self.pages = pages
      self.has_previous = has_previous
      self.has_next = has_next
    }
  }

  public struct BookResults: Codable {
    public let items: [BookItem]
    let pagination: Pagination?

    init(items: [BookItem] = [], pagination: Pagination? = nil) {
      self.items = items

      self.pagination = pagination
    }
  }

  public struct PersonName {
    public let name: String
    public let id: String

    public init(name: String, id: String) {
      self.name = name
      self.id = id
    }
  }

  public struct Tracks: Codable {
    public let aItems: String
    public let bStateError: Bool?
    public let fstate: Bool?
    public let sMsg: String?
    public let sMsgTitle: String?

    public init(aItems: String, bStateError: Bool, fstate: Bool, sMsg: String, sMsgTitle: String) {
      self.aItems = aItems
      self.bStateError = bStateError
      self.fstate = fstate
      self.sMsg = sMsg
      self.sMsgTitle = sMsgTitle
    }
  }

  public struct Track: Codable {
    public let albumName: String?
    public let title: String
    public let url: String?
    public let time: Int

    enum CodingKeys: String, CodingKey {
      case albumName = "cat"
      case title
      case url = "mp3"
      case time
    }

    public init(albumName: String, title: String, url: String, time: Int) {
      self.albumName = albumName
      self.title = title
      self.url = url
      self.time = time
    }

    public init(from decoder: Decoder) throws {
      let albumName = (try? decoder.decode("cat")) ?? ""
      let title = (try? decoder.decode("title")) ?? ""
      let url = (try? decoder.decode("mp3")) ?? ""
      let time = (try? decoder.decode("time")) ?? 0

      self.init(albumName: albumName, title: title, url: url, time: time)
    }

    public func encode(to encoder: Encoder) throws {
      try encoder.encode(albumName, for: "albumName")
      try encoder.encode(title, for: "title")
      try encoder.encode(url, for: "url")
      try encoder.encode(time, for: "time")
    }
  }
}
