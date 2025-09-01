import XCTest
import Files

@testable import AudioKnigiApi

class AudioKnigiServiceTests: XCTestCase {
  var subject = AudioKnigiApiService()

  func testGetAuthorsLetters() async throws {
    let result = try await subject.getAuthorsLetters()

    print(try result.prettify())

    XCTAssert(result.count > 0)
  }

  func testGetNewBooks() async throws {
    let result = try await subject.getNewBooks()

    print(try result.prettify())

    XCTAssert(result.items.count > 0)
  }

  func testGetBestBooks() async throws {
    let result = try await subject.getBestBooks()

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

  func testGetAuthorBooks() async throws {
    let result = try await subject.getAuthors()

    if let id = result.items.first!.value["id"] {
      let books = try await subject.getBooks(path: id)

      print(try books.prettify())

      XCTAssert(books.items.count > 0)
    }
  }

  func testGetPerformersBooks() async throws {
    let result = try await subject.getPerformers()

    if let id = result.items.first!.value["id"] {
      let books = try await subject.getBooks(path: id)

      print(try books.prettify())

      XCTAssert(books.items.count > 0)
    }
  }

  func testGetAuthors() async throws {
    let result = try await subject.getAuthors()

    print(try result.prettify())

    XCTAssert(result.items.count > 0)
  }

  func testGetPerformers() async throws {
    let result = try await subject.getPerformers()

    print(try result.prettify())

    XCTAssert(result.items.count > 0)
  }

  func testGetAllGenres() async throws {
    let result = try await subject.getGenres(page: 1)

    print(try result.prettify())

    XCTAssert(result.count > 0)

    let result2 = try await subject.getGenres(page: 2)

    print(try result2.prettify())

    XCTAssert(result2.count > 0)
  }

  func testGetGenre() async throws {
    let genres = try await subject.getGenres(page: 1)

    if let item = genres.first {
      if let id = item.value["id"] {
        let genre = try await subject.getGenre(path: id)

        print(try genre.prettify())

        XCTAssert(genre.items.count > 0)
      }
    }
  }

  func testPagination() async throws {
    let result1 = try await subject.getNewBooks(page: 1)

    // print(try result1.prettify())

    if let pagination1 = result1.pagination {
      XCTAssertEqual(pagination1.has_next, true)
      XCTAssertEqual(pagination1.has_previous, false)
      XCTAssertEqual(pagination1.page, 1)
    }

    let result2 = try await subject.getNewBooks(page: 2)

    if let pagination2 = result2.pagination {
      XCTAssertEqual(pagination2.has_next, true)
      XCTAssertEqual(pagination2.has_previous, true)
      XCTAssertEqual(pagination2.page, 2)
    }
  }

  func testGetAudioTracks() async throws {
    let url = "\(AudioKnigiApiService.SiteUrl)/pratchett-terri-volnye-malcy-audiokniga"

    let result = try await subject.getAudioTracks(url)

    print(try result.prettify())

    XCTAssertNotNil(result)
    XCTAssert(result.count > 0)
  }

  func testSearch() async throws {
    let query = "пратчетт"

    let result = try await subject.search(query)

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

  func _testGenerateAuthorsList() async throws {
    try await generateAuthorsList("authors.json")
  }

  func _testGeneratePerformersList() async throws {
    try await generatePerformersList("performers.json")
  }

  func _testGenerateAuthorsInGroupsList() throws {
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

  func _testGeneratePerformersInGroupsList() throws {
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

  private func generateAuthorsList(_ fileName: String) async throws {
    var list = [Any]()

    print("Visiting page 1")

    let result = try await subject.getAuthors()

    list += result.items

    let pagination = result.pagination!

    let pages = pagination.pages

    for page in (2...pages) {
      print("Visiting page \(page)")

      let result2 = try await subject.getAuthors(page: page)

      list += result2.items
    }

    let filteredList = list.map {["id": ($0 as! [String: String])["id"]!, "name": ($0 as! [String: String])["name"]!] }

    let folder = try Folder(path: ".")
    try folder.createFile(named: fileName, contents: try asPrettifiedData(filteredList))
  }

  private func generatePerformersList(_ fileName: String) async throws {
    var list = [Any]()

    print("Visiting page 1")

    let result = try await subject.getPerformers()

    list += result.items

    let pagination = result.pagination!

    let pages = pagination.pages

    for page in (2...pages) {
      print("Visiting page \(page)")

      let result2 = try await subject.getPerformers(page: page)

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
