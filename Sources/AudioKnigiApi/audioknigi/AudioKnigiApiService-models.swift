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
    public let bStateError: Bool
    public let fstate: Bool
    public let sMsg: String
    public let sMsgTitle: String

    public init(aItems: String, bStateError: Bool, fstate: Bool, sMsg: String, sMsgTitle: String) {
      self.aItems = aItems
      self.bStateError = bStateError
      self.fstate = fstate
      self.sMsg = sMsg
      self.sMsgTitle = sMsgTitle
    }
  }

//  public struct Tracks2: Codable {
//    public let title: String
//    public let res: String
//    public let hres: String
//    public let srv: String
//    public let sTextAuthor: String
//    public let sTextPerformer: String
//    public let sTextFav: String
//    public let items: String
//    public let topic_id: String
//    public let titleonly: String
//    public let slug: String
//    public let version: Int
//    public let bookurl: String
//    public let preview: String
//    public let author: String
//    public let sMsgTitle: String?
//    public let sMsg: String?
//    public let bStateError: Bool?
//
//    public init(
//        title: String,
//        res: String,
//        hres: String,
//        srv: String,
//        sTextAuthor: String,
//        sTextPerformer: String,
//        sTextFav: String,
//        items: String,
//        topic_id: String,
//        titleonly: String,
//        slug: String,
//        version: Int,
//        bookurl: String,
//        preview: String,
//        author: String,
//        sMsgTitle: String?,
//        sMsg: String?,
//        bStateError: Bool?) {
//      self.title = title
//      self.res = res
//      self.hres = hres
//      self.srv = srv
//      self.sTextAuthor = sTextAuthor
//      self.sTextPerformer = sTextPerformer
//      self.sTextFav = sTextFav
//      self.items = items
//
//      self.topic_id = topic_id
//      self.titleonly = titleonly
//      self.slug = slug
//      self.version = version
//      self.bookurl = bookurl
//
//      self.preview = preview
//      self.author = author
//      self.sMsgTitle = sMsgTitle
//      self.sMsg = sMsg
//      self.bStateError = bStateError
//    }
//  }

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

//  public struct Track2: Codable {
//    public let file: Int
//    public let title: String
//    public let time: Int
//    public let duration: Int
//    public let durationhms: String
//    public let time_from_start: Int
//    public let time_finish: Int
//
//    enum CodingKeys: String, CodingKey {
//      case albumName = "cat"
//      case title
//      case url = "mp3"
//      case time
//    }
//
//    public init(file: Int, title: String, time: Int, duration: Int, durationhms: String,
//                time_from_start: Int, time_finish: Int) {
//      self.file = file
//      self.title = title
//      self.time = time
//      self.duration = duration
//      self.durationhms = durationhms
//      self.time_from_start = time_from_start
//      self.time_finish = time_finish
//    }
//
//    public init(from decoder: Decoder) throws {
//      let file = (try? decoder.decode("file")) ?? 0
//      let title = (try? decoder.decode("title")) ?? ""
//      let time = (try? decoder.decode("time")) ?? 0
//      let duration = (try? decoder.decode("duration")) ?? 0
//      let durationhms = (try? decoder.decode("durationhms")) ?? ""
//      let time_from_start = (try? decoder.decode("time_from_start")) ?? 0
//      let time_finish = (try? decoder.decode("time_finish")) ?? 0
//
//      self.init(file: file, title: title, time: time, duration: duration, durationhms: durationhms,
//          time_from_start: time_from_start, time_finish: time_finish)
//    }
//
//    public func encode(to encoder: Encoder) throws {
//      try encoder.encode(file, for: "file")
//      try encoder.encode(title, for: "title")
//      try encoder.encode(time, for: "time")
//      try encoder.encode(duration, for: "duration")
//      try encoder.encode(durationhms, for: "durationhms")
//      try encoder.encode(time_from_start, for: "time_from_start")
//      try encoder.encode(time_finish, for: "time_finish")
//    }
//  }
}
