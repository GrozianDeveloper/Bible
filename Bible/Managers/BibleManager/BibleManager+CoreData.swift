//
//  BibleManager+CoreData.swift
//  Bible
//
//  Created by Bogdan Grozian on 02.03.2022.
//

import CoreData
import UIKit.UIColor

extension BibleManager {
    @discardableResult func createBookmark(title: String? = nil, book: Book? = nil, verses: [BibleVerse]? = nil, note: String? = nil) -> Bookmark {
        let bookmarkEntity = NSEntityDescription.entity(forEntityName: "Bookmark", in: context)!
        let bookmark = Bookmark(entity: bookmarkEntity, insertInto: context)

        var createdTitle: String? = title
        let verses = verses ?? []
        if createdTitle == nil, let book = book {
            createdTitle = book.name

            if let verse = verses.first {
                let localizedChapter = "Chapter".localized(.ui)
                createdTitle?.append(" \(localizedChapter) \(verse.chapterOffset + 1)")
            }
        }
        bookmark.title = createdTitle
        bookmark.verses = BibleVerses(verses: verses)
        bookmark.note = note
        bookmarks.append(bookmark)
        return bookmark
    }
    
    // MARK: - Delete
    func deleteBookmark(bookmark: Bookmark) {
        let index: Int = bookmarks.firstIndex(where: { $0 == bookmark } )!
        context.delete(bookmark)
        bookmarks.remove(at: index)
        if let book = activeBook {
            updateBookmarkReferencesToBook(book: book)
        }
    }
    
    func deleteBookmarkAt(index: Int) {
        context.delete(bookmarks[index])
        bookmarks.remove(at: index)
    }
    
    // MARK: - Fetch
    func fetchBookrmarks(_ fetchType: FetchBookmarksType = .all) -> [Bookmark] {
        do {
            let bookrmarks = try context.fetch(fetchType.reqeust)
            return bookrmarks
        }
        catch {
            print("fetch", error)
            return []
        }
    }
    
    // MARK: - Save
    @objc func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \n \(nserror), \(nserror.userInfo)")
            }
            postNotification(Self.bookmarksDidChangeNotification)
        }
    }
}
