//
//  DataProvider.swift
//  Bible
//
//  Created by Bogdan Grozian on 26.09.2021.
//

import UIKit
import CoreData
import simd
import AVFoundation

final class BibleManager {
    private(set) var localizationBundle: Bundle!
    
    private func setupLocalizationBundle() {
        let language = bibleVersion.rawValue
        let path = Bundle.main.path(forResource: language, ofType: "lproj")
        localizationBundle = Bundle(path: path!)
    }

    static let shared = BibleManager()
    private init() {
        let language = UserDefaults.standard.string(forKey: UserDefaultsKey.language) ?? "en"
        bibleVersion = BibleVersion(rawValue: language) ?? .kingJamesVersion
        setupLocalizationBundle()
        getBible()
        NotificationCenter.default.addObserver(self, selector: #selector(saveContext), name: UIApplication.willResignActiveNotification, object: nil)
    }

    // Core Data
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    lazy var context = appDelegate.persistentContainer.viewContext
    // Support
    let userDefaults = UserDefaults.standard
    private let decodingQueue = DispatchQueue(label: "com.BibleManager.decodingBible", attributes: .concurrent, autoreleaseFrequency: .workItem)

    // MARK: - Notifications
    static let bibleDidChangeNotification: Notification.Name = .init(rawValue: "bibleDidUpdate")
    static let bookmarksDidChangeNotification: Notification.Name = .init(rawValue: "bookmarksDidChange")
    static let activeBookDidChangeNotification: Notification.Name = .init(rawValue: "activeBookDidUpdate")
    static let fontPointSizeDidChangeNotification: Notification.Name = .init(rawValue: "fontPointSizeDidUpdate")
    static let historyDidChangeNotification: Notification.Name = .init(rawValue: "historyDidChange")
    static let referenceToActiveBookDidChange: Notification.Name = .init(rawValue: "referenceToActiveBookDidChange")

    private(set) var bibleVersion: BibleVersion {
        didSet {
            UserDefaults.standard.set(bibleVersion.rawValue, forKey: UserDefaultsKey.language)
            getBible()
        }
    }
    
    func setBibleVersion(_ version: BibleVersion) {
        bibleVersion = version
        setupLocalizationBundle()
        userDefaults.set(bibleVersion.rawValue, forKey: UserDefaultsKey.language)
    }

    private(set) var bible = [Book]() {
        didSet {
            updateActiveBook()
            garanteeMainThread {
                postNotification(BibleManager.bibleDidChangeNotification)
            }
        }
    }
    private(set) var oldTestament = [Book]()
    private(set) var newTestament = [Book]()

    private(set) var activeBook: Book? {
        didSet {
            garanteeMainThread {
                postNotification(BibleManager.activeBookDidChangeNotification)
            }
        }
    }
    
    lazy var chapterOffsetToOpen: Int? = getLastOpenedChapterOffset()
    
    var verseRowToScroll: Int? = nil

    var bookmarkToOpen: ObjectIdentifier? = nil
    
    private(set) var verseReferenceForActiveBookmark: Set<BibleVerse> = []
    
    private(set) lazy var font: UIFont = {
        let pointSize = userDefaults.float(forKey: UserDefaultsKey.fontPointSize)
        if pointSize != 0 {
            return .systemFont(ofSize: CGFloat(pointSize))
        } else {
            return .systemFont(ofSize: CGFloat(17))
        }
    }() {
        didSet {
            garanteeMainThread {
                postNotification(BibleManager.fontPointSizeDidChangeNotification)
            }
        }
    }
    
    lazy var bookmarks: [Bookmark] = fetchBookrmarks() {
        didSet {
            garanteeMainThread {
                postNotification(BibleManager.bookmarksDidChangeNotification)
            }
        }
    }
}

// MARK: - Set Active Book
extension BibleManager {
    func setActiveBook(book: Book) {
        guard bible.contains(where: { $0.abbrev == book.abbrev }) else { return }
        userDefaults.set(book.abbrev, forKey: UserDefaultsKey.activeBookAbbrev)
        updateBookmarkReferencesToBook(book: book)
        activeBook = book
    }

    func setActiveBook(abbrev: String) {
        guard let book = bible.first(where: {$0.abbrev == abbrev}) else { return }
        setActiveBook(book: book)
    }
}

// MARK: - Bible Font
extension BibleManager {
    func setBibleFont(pointSize: CGFloat) {
        font = .systemFont(ofSize: pointSize)
        userDefaults.set(Float(pointSize), forKey: UserDefaultsKey.fontPointSize)
    }
}

// MARK: - Bookmark reference to active book
extension BibleManager {
    func insertReferenceToActiveBook(verses: Set<BibleVerse>) {
        verses.forEach { verseReferenceForActiveBookmark.insert($0) }
        garanteeMainThread {
            postNotification(Self.referenceToActiveBookDidChange)
        }
    }

    func removeReferenceToActiveBook(verses: Set<BibleVerse>) {
        verses.forEach { verseReferenceForActiveBookmark.remove($0) }
        garanteeMainThread {
            postNotification(Self.referenceToActiveBookDidChange)
        }
    }
}

// MARK: - Update
extension BibleManager {
    private func getBible() {
        decodingQueue.async { [weak self] in
            guard let self = self else { return }
            let bibleData = self.readLocalFile()
            bibleData?.decoded(as: [Book].self, completion: { [weak self] result in
                switch result {
                case .success(let bible):
                    var indexMatthew: Int = 39
                    bible.enumerated().forEach {
                        if $0.element.abbrev == "mt" {
                            indexMatthew = $0.offset
                        }
                    }
                    self?.oldTestament = Array(bible.prefix(upTo: indexMatthew))
                    self?.newTestament = Array(bible.suffix(from: indexMatthew))
                    self?.bible = bible
                case .failure(let error):
                    print("decode error: \(error)")
                }
            })
        }
    }
    
    private func updateActiveBook() {
        guard let name = userDefaults.string(forKey: UserDefaultsKey.activeBookAbbrev) else {
            if let first = bible.first {
                activeBook = first
            }
            return
        }
        if let offSet = bible.enumerated().first(where: { $0.element.abbrev == name })?.offset {
            let book = bible[offSet]
            updateBookmarkReferencesToBook(book: book)
            activeBook = book
        }
    }
    
    func updateBookmarkReferencesToBook(book: Book) {
        let verses = bookmarks.compactMap(\.verses)
        var neededVerses: Set<BibleVerse> = []
        verses.forEach {
            $0.verses.forEach { verse in
                if verse.abbrev == book.abbrev {
                    neededVerses.insert(verse)
                }
            }
        }
        verseReferenceForActiveBookmark = neededVerses
        garanteeMainThread {
            postNotification(Self.referenceToActiveBookDidChange)
        }
    }
}

// MARK: - Support
extension BibleManager {
    private func readLocalFile() -> Data? {
        guard let bundlePath = getFilePath() else { return nil }
        do {
            return try String(contentsOfFile: bundlePath).data(using: .utf8)
        } catch {
            print(error)
        }
        return nil
    }

    private func getFilePath() -> String? {
        let fileName: String
        switch bibleVersion {
        case .kingJamesVersion: fileName = "en_kjv"
        case .Synodal: fileName = "ru_synodal"
        }
        return Bundle.main.path(forResource: fileName, ofType: "json")
    }
}

// MARK: - Models
extension BibleManager {
    struct UserDefaultsKey {
        static let activeBookAbbrev = "activeBookAbbrev"
        static let lastOpenedChapter = "lastOpenedChaoter"
        static let fontPointSize = "fontPointSize"
        static let readingHistory = "readingHistory"
        static let verseRowToScroll = "verseRowToScroll"
        static let language = "app_lang"
    }
    
    enum FetchBookmarksType {
        case all
//        case book(abbrev: String)
        
        var reqeust: NSFetchRequest<Bookmark> {
            switch self {
            case .all:
                return Bookmark.fetchRequest()
//            case .book(let abbrev):
                /*
                 @nonobjc public class func fetchBookRequest(abbrev: String) -> NSFetchRequest<BibleBookmark> {
                    let request = NSFetchRequest<BibleBookmark>(entityName: "BibleBookmark")
                    request.predicate = NSPredicate(format: "verses IN abbrev == %@", abbrev)
                    return request
                }
                 */
//                return Bookmark.fetchBookRequest(abbrev: abbrev)
            }
        }
    }
}
