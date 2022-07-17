import XCTest
import Files

@testable import AudioKnigiApi

class AudioKnigiServiceTests: XCTestCase {
  var subject = AudioKnigiApiService()

  func testGetAuthorsLetters() throws {
    let result = try subject.getAuthorsLetters()

    print(try result.prettify())

    XCTAssert(result.count > 0)
  }

  func testGetNewBooks() throws {
    let result = try subject.getNewBooks()

    print(try result.prettify())

    XCTAssert(result.items.count > 0)
  }

  func testGetBestBooks() throws {
    let result = try subject.getBestBooks()

    print(try result.prettify())

    XCTAssert(result.items.count > 0)
  }

//  func testGetBestBooksByMonth() throws {
//    let exp = expectation(description: "Gets best books by month")
//
//    _ = subject.getBestBooks(period: "30").subscribe(onNext: { result in
//      //print(result as Any)
//
//      XCTAssert(result.count > 0)
//
//      exp.fulfill()
//    })
//
//    waitForExpectations(timeout: 10, handler: nil)
//  }
//
//  func testGetBestBooks() throws {
//    let exp = expectation(description: "Gets best books")
//
//    _ = subject.getBestBooks(period: "all").subscribe(onNext: { result in
//      //print(result as Any)
//
//      XCTAssert(result.count > 0)
//
//      exp.fulfill()
//    })
//
//    waitForExpectations(timeout: 10, handler: nil)
//  }

  func testGetAuthorBooks() throws {
    let result = try subject.getAuthors()

    if let id = result.items.first!["id"] {
      let books = try subject.getBooks(path: id)

      print(try books.prettify())

      XCTAssert(books.items.count > 0)
    }
  }

  func testGetPerformersBooks() throws {
    let result = try subject.getPerformers()

    if let id = result.items.first!["id"] {
      let books = try subject.getBooks(path: id)

      print(try books.prettify())

      XCTAssert(books.items.count > 0)
    }
  }

  func testGetAuthors() throws {
    let result = try subject.getAuthors()

    print(try result.prettify())

    XCTAssert(result.items.count > 0)
  }

  func testGetPerformers() throws {
    let result = try subject.getPerformers()

    print(try result.prettify())

    XCTAssert(result.items.count > 0)
  }

  func testGetAllGenres() throws {
    let result = try subject.getGenres(page: 1)

    print(try result.prettify())

    XCTAssert(result.count > 0)

    let result2 = try subject.getGenres(page: 2)

    print(try result2.prettify())

    XCTAssert(result2.count > 0)
  }

  func testGetGenre() throws {
    let genres = try subject.getGenres(page: 1)

    if let item = genres.first {
      if let id = item["id"] {
        let genre = try subject.getGenre(path: id)

        print(try genre.prettify())

        XCTAssert(genre.items.count > 0)
      }
    }
  }

  func testPagination() throws {
    let result1 = try subject.getNewBooks(page: 1)

    // print(try result1.prettify())

    if let pagination1 = result1.pagination {
      XCTAssertEqual(pagination1.has_next, true)
      XCTAssertEqual(pagination1.has_previous, false)
      XCTAssertEqual(pagination1.page, 1)
    }

    let result2 = try subject.getNewBooks(page: 2)

    if let pagination2 = result2.pagination {
      XCTAssertEqual(pagination2.has_next, true)
      XCTAssertEqual(pagination2.has_previous, true)
      XCTAssertEqual(pagination2.page, 2)
    }
  }

  func testGetAudioTracks() throws {
    let url = "\(AudioKnigiApiService.SiteUrl)/pratchett-terri-volnyy-narodec"

    let result = try subject.getAudioTracks(url)

    print(try result.prettify())

    XCTAssertNotNil(result)
    XCTAssert(result.count > 0)
  }

  func testSearch() throws {
    let query = "пратчетт"

    let result = try subject.search(query)

    print(try result.prettify())

    XCTAssert(result.items.count > 0)
  }

  func _testGrouping() throws {
    let data: Data? = try File(path: "authors.json").read()

    let items: [NameClassifier.Item] = try data!.decoded() as [NameClassifier.Item]

    let classifier = NameClassifier()
    let classified = try classifier.classify(items: items)

    //print(classified)

    XCTAssert(classified.count > 0)
  }

  func _testGenerateAuthorsList() throws {
    try generateAuthorsList("authors.json")
  }

  func _testGeneratePerformersList() throws {
    try generatePerformersList("performers.json")
  }

  func testGenerateAuthorsInGroupsList() throws {
    let data: Data? = try File(path: "authors.json").read()

    let items: [NameClassifier.Item] = try data!.decoded() as [NameClassifier.Item]

    let classifier = NameClassifier()
    let classified = try classifier.classify2(items: items)

    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let data2 = try encoder.encode(classified)

    //print(data2)

    let folder = try Folder(path: ".")
    try folder.createFile(named: "authors-in-groups.json", contents: data2)
  }

  func testGeneratePerformersInGroupsList() throws {
    let data: Data? = try File(path: "performers.json").read()

    let items: [NameClassifier.Item] = try data!.decoded() as [NameClassifier.Item]

    let classifier = NameClassifier()
    let classified = try classifier.classify2(items: items)

    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let data2 = try encoder.encode(classified)

    //print(data2)

    let folder = try Folder(path: ".")
    try folder.createFile(named: "performers-in-groups.json", contents: data2)
  }

  private func generateAuthorsList(_ fileName: String) throws {
    var list = [Any]()

    print("Visiting page 1")

    let result = try subject.getAuthors()

    list += result.items

    let pagination = result.pagination!

    let pages = pagination.pages

    for page in (2...pages) {
      print("Visiting page \(page)")

      let result2 = try subject.getAuthors(page: page)

      list += result2.items
    }

    let filteredList = list.map {["id": ($0 as! [String: String])["id"]!, "name": ($0 as! [String: String])["name"]!] }

    let folder = try Folder(path: ".")
    try folder.createFile(named: fileName, contents: try asPrettifiedData(filteredList))
  }

  private func generatePerformersList(_ fileName: String) throws {
    var list = [Any]()

    print("Visiting page 1")

    let result = try subject.getPerformers()

    list += result.items

    let pagination = result.pagination!

    let pages = pagination.pages

    for page in (2...pages) {
      print("Visiting page \(page)")

      let result2 = try subject.getPerformers(page: page)

      list += result2.items
    }

    let filteredList = list.map {["id": ($0 as! [String: String])["id"]!, "name": ($0 as! [String: String])["name"]!] }

    let folder = try Folder(path: ".")
    try folder.createFile(named: fileName, contents: try asPrettifiedData(filteredList))
  }

  var encoder: JSONEncoder = {
    let encoder = JSONEncoder()

    encoder.outputFormatting = .prettyPrinted

    return encoder
  }()

  public func asPrettifiedData(_ value: Any) throws -> Data {
    if let value = value as? [[String: String]] {
      return try encoder.encode(value)
    }
    else if let value = value as? [String: String] {
      return try encoder.encode(value)
    }

    return Data()
  }
}
