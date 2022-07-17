import Foundation
import Files
import SwiftSoup
import SimpleHttpClient

open class AudioKnigiApiService {
  public static let SiteUrl = "https://akniga.org"

  let apiClient = ApiClient(URL(string: SiteUrl)!)

  public init() {}

  public static func getURLPathOnly(_ url: String, baseUrl: String) -> String {
    String(url[baseUrl.index(url.startIndex, offsetBy: baseUrl.count)...])
  }

  func getPagePath(path: String, page: Int=1) -> String {
    if page == 1 {
      return path
    }
    else {
      return "\(path)page\(page)/"
    }
  }

  public func getAuthorsLetters() throws -> [String] {
    var result = [String]()

    let path = "/authors/"

    if let document = try getDocument(path) {
      let items = try document.select("ul[id='author-prefix-filter'] li a")

      for item in items.array() {
        let name = try item.text()

        result.append(name)
      }
    }

    return result
  }

  public func getNewBooks(page: Int=1) throws -> BookResults {
    try getBooks(path: "/index/", page: page)
  }

  public func getBestBooks(page: Int=1, period: String? = nil) throws -> BookResults {
    try getBooks(path: "/index/top/", page: page, period: period)
  }

  public func getBooks(path: String, page: Int=1, period: String? = nil) throws -> BookResults {
    var result = BookResults()

    //let encodedPath = path.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!

    let pagePath = getPagePath(path: path, page: page)

    var queryItems: Set<URLQueryItem> = []

    if let period = period {
      queryItems.insert(URLQueryItem(name: "period", value: period))
    }

    if let document = try getDocument(pagePath, queryItems: queryItems) {
      result = try getBookItems(document, path: path, page: page)
    }

    return result
  }

  func getBookItems(_ document: Document, path: String, page: Int) throws -> BookResults {
    var items = [BookItem]()

    let list = try document.select("div[class=content__main__articles--item]")

    for element: Element in list.array() {
      let link = try element.select("div a")
      let name = try element.select("h2[class=caption__article-main]").text()
      let href = try link.attr("href")
      let thumb = try link.select("img").attr("src")
      let description = try element.select("span[class=description__article-main]").text()

      items.append(["type": "book", "id": href, "name": name, "thumb": thumb, "description": description])
    }

    let pagination = try extractPaginationData(document: document, path: path, page: page)

    return BookResults(items: items, pagination: pagination)
  }

  public func getAuthors(page: Int=1) throws -> BookResults {
    try getCollection(path: "/authors/", page: page)
  }

  public func getPerformers(page: Int=1) throws -> BookResults {
    try getCollection(path: "/performers/", page: page)
  }

  func getCollection(path: String, page: Int=1) throws -> BookResults {
    var collection = [BookItem]()
    var pagination = Pagination()

    let pagePath = getPagePath(path: path, page: page)

    if let document = try getDocument(pagePath) {
      let items = try document.select("td[class=cell-name]")

      for item: Element in items.array() {
        let link = try item.select("h4 a")
        let name = try link.text()
        let href = try link.attr("href")
        let thumb = "https://audioknigi.club/templates/skin/aclub/images/avatar_blog_48x48.png"
        //try link.select("img").attr("src")

        let index = href.index(href.startIndex, offsetBy: AudioKnigiApiService.SiteUrl.count)

        let id = String(href[index ..< href.endIndex]) + "/"

        if let filteredId = id.removingPercentEncoding {
          collection.append(["type": "collection", "id": filteredId, "name": name, "thumb": thumb]) 
        }
      }

      if !items.array().isEmpty {
        pagination = try extractPaginationData(document: document, path: path, page: page)
      }
    }

    return BookResults(items: collection, pagination: pagination)
  }

  public func getGenres(page: Int=1) throws ->  [BookItem] {
    var collection = [BookItem]()
    //var pagination = Pagination()

    let path = getPagePath(path: "/sections/", page: page)

    if let document = try getDocument(path) {
      let items = try document.select("td[class=cell-name]")

      for item: Element in items.array() {
        let link = try item.select("a")
        let name = try item.select("h4 a").text()
        let href = try link.attr("href")

        let index = href.index(href.startIndex, offsetBy: AudioKnigiApiService.SiteUrl.count)

        let id = String(href[index ..< href.endIndex])

        let thumb = try link.select("img").attr("src")

        collection.append(["type": "genre", "id": id, "name": name, "thumb": thumb])
      }
    }

    //return BookResults(items: collection, pagination: pagination)

    return collection
  }

  func getGenre(path: String, page: Int=1) throws -> BookResults {
    try getBooks(path: path, page: page)
  }

  func extractPaginationData(document: Document, path: String, page: Int) throws -> Pagination {
    var pages = 1

    let items = try document.select("div[class=paging] div[class=page__nav] a[class=page__nav--standart]")

    //if paginationRoot.size() > 0 {
      //let paginationBlock = paginationRoot.get(0)

      //let items = try paginationRoot.select("a")

    if items.count > 0 {
      let lastLink = items.get(items.size() - 1)
      pages = try Int(lastLink.text())!
    }
    else {
      pages = 1
    }

      //if lastLink.size() == 1 {
        //lastLink = try items.get(items.size() - 2)

//        if try lastLink.text() == "последняя" {
//          let link = try lastLink.select("a").attr("href")
//
//          let index1 = link.find("page")
//          let index2 = link.find("?")
//
//          if let index1 = index1 {
//            let index3 = link.index(index1, offsetBy: "page".count)
//            var index4: String.Index?
//
//            if index2 == nil {
//              index4 = link.index(link.endIndex, offsetBy: -1)
//            }
//            else if let index2 = index2 {
//              index4 = link.index(index2, offsetBy: -1)
//            }
//
//            if let index4 = index4 {
//              pages = Int(link[index3..<index4])!
//            }
//          }
//        }
//        else {
//          pages = try Int(lastLink.text())!
//    pages = try Int(lastLink.text())!
//        }
      //}
      //else {
//        let href = try items.attr("href")
//
//        let pattern = path + "page"
//
//        let index1 = href.find(pattern)
//        let index2 = href.find("/?")

//        if index2 != nil {
//          index2 = href.endIndex-1
//        }

        //pages = href[index1+pattern.length..index2].to_i
      //}
    //}

    return Pagination(page: page, pages: pages, has_previous: page > 1, has_next: page < pages)
  }

  public func search(_ query: String, page: Int=1) throws -> BookResults {
    var result = BookResults()

    let path = getPagePath(path: "/search/books/", page: page)

//    params["q"] = query.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!

    var queryItems: Set<URLQueryItem> = []
    queryItems.insert(URLQueryItem(name: "q", value: query))

    if let response = try apiClient.request(path, queryItems: queryItems),
       let data = response.data,
       let document = try data.toDocument() {
      result = try getBookItems(document, path: path, page: page)
    }

    return result
  }

  public func getAudioTracks(_ url: String) throws -> [Track] {
    var newTracks = [Track]()

    let (cookie, securityLsKey) = try getCookieAndSecurityLsKey()

    let path = AudioKnigiApiService.getURLPathOnly(url, baseUrl: AudioKnigiApiService.SiteUrl)

    let response = try apiClient.request(path)

    if let securityLsKey = securityLsKey, let response = response,
       let data = response.data,
       let document = try data.toDocument() {
      if let bookId = try getBookId(document: document) {
        let securityParams = getSecurityParams(bid: bookId, securityLsKey: securityLsKey)

        let newPath = "ajax/bid/\(bookId)"

        if let cookie = cookie {
          newTracks = try requestTracks(path: newPath, content: securityParams, cookie: cookie)
        }
      }
    }

    return newTracks
  }

  func requestTracks(path: String, content: String, cookie: String) throws -> [Track] {
    var newTracks = [Track]()

    var headers: Set<HttpHeader> = []

    //headers.append(HttpHeader(field: "Content-Type", value: "application/x-www-form-urlencoded; charset=UTF-8"))
    //headers.append(HttpHeader(field: "cookie", value: cookie))
    headers.insert(HttpHeader(field: "user-agent", value: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.86 Safari/537.36"))

    if let body = content.data(using: .utf8, allowLossyConversion: false),
       let response = try apiClient.request(path, method: .post, headers: headers, body: body) {
      if let data1 = response.data, let tracks = try apiClient.decode(data1, to: Tracks.self) {
        if let data2 = tracks.aItems.data(using: .utf8), let items = try apiClient.decode(data2, to: [Track].self) {
          newTracks = items
        }
      }
    }

    return newTracks
  }

  func getCookieAndSecurityLsKey() throws -> (String?, String?)  {
    let (cookie, response) = try getCookie()

    var securityLsKey: String?

    if let response = response, let data = response.data,
       let document = try data.toDocument() {
      let scripts = try document.select("script")

      for script in scripts {
        let text = try script.html()

        if let key = try getSecurityLsKey(text: text) {
          securityLsKey = key
        }
      }
    }

    return (cookie, securityLsKey)
  }

  func getCookie() throws -> (String?, ApiResponse?)  {
    let headers: Set<HttpHeader> = [
      HttpHeader(field: "user-agent", value:
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.86 Safari/537.36")
    ]

    var cookie: String?

    let response = try apiClient.request(headers: headers)

    if let cookies = HTTPCookieStorage.shared.cookies {
      for c in cookies {
        if c.name == "PHPSESSID" {
          cookie = "\(c)"
        }
      }
    }

    return (cookie, response)
  }

  func getBookId(document: Document) throws -> Int? {
    let items = try document.select("article")

    if items.array().count > 0, let first = items.first() {
      let globalId = try first.attr("data-bid")

      return Int(globalId)
    }

    return nil
  }

  func getSecurityLsKey(text: String) throws -> String? {
    var security_ls_key: String?

    let pattern = ",(LIVESTREET_SECURITY_KEY\\s+=\\s+'.*'),"

    let regex = try NSRegularExpression(pattern: pattern)

    let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))

    let match = getMatched(text, matches: matches, index: 1)

    if let match = match, !match.isEmpty {
      if let index = match.find("'") {
        let index1 = match.index(index, offsetBy: 1)

        if let index2 = match.find("',") {
          security_ls_key = String(match[index1..<index2])
        }
      }
    }

    return security_ls_key
  }

  func getSecurityParams(bid: Int, securityLsKey: String) -> String {
    let secretPassphrase = "EKxtcg46V";

    let AES = CryptoJS.AES()

    let encrypted = AES.encrypt("\"" + securityLsKey + "\"", password: secretPassphrase)

    let ct = encrypted[0]
    let iv = encrypted[1]
    let salt = encrypted[2]

    let hashString = "{" +
      "\"ct\":\"" + ct + "\"," +
      "\"iv\":\"" + iv + "\"," +
      "\"s\":\"" + salt + "\"" +
      "}"

    let hash = hashString
      .replacingOccurrences(of: "{", with: "%7B")
      .replacingOccurrences(of: "}", with: "%7D")
      .replacingOccurrences(of: ",", with: "%2C")
      .replacingOccurrences(of: "/", with: "%2F")
      .replacingOccurrences(of: "\"", with: "%22")
      .replacingOccurrences(of: ":", with: "%3A")
      .replacingOccurrences(of: "+", with: "%2B")

    return "bid=\(bid)&hash=\(hash)&security_ls_key=\(securityLsKey)"
  }

  func getMatched(_ link: String, matches: [NSTextCheckingResult], index: Int) -> String? {
    var matched: String?

    let match = matches.first

    if let match = match, index < match.numberOfRanges {
      let capturedGroupIndex = match.range(at: index)

      let index1 = link.index(link.startIndex, offsetBy: capturedGroupIndex.location)
      let index2 = link.index(index1, offsetBy: capturedGroupIndex.length-1)

      matched = String(link[index1 ... index2])
    }

    return matched
  }

  public func getItemsInGroups(_ fileName: String) -> [NameClassifier.ItemsGroup] {
    var items: [NameClassifier.ItemsGroup] = []

    do {
      let data: Data? = try File(path: fileName).read()

      if let data = data {
        do {
          items = try data.decoded() as [NameClassifier.ItemsGroup]
        }
        catch let e {
          print("Error: \(e)")
        }
      }
    }
    catch let e {
      print("Error: \(e)")
    }

    return items
  }

  public func getDocument(_ path: String = "", queryItems: Set<URLQueryItem> = []) throws -> Document? {
    var document: Document? = nil

    if let response = try apiClient.request(path, queryItems: queryItems), let data = response.data {
      document = try data.toDocument()
    }

    return document
  }
}
