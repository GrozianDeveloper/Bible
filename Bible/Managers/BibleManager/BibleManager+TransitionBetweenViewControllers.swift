//
//  BibleManager+TransitionBetweenViewControllers.swift
//  Bible
//
//  Created by Bogdan Grozian on 06.04.2022.
//

import UIKit

extension BibleManager {
    func openViewController(_ self: UIViewController?, target: TargerViewController) {
        switch target {
        case .bibleWithAbbrev(let abbrev, let chapter, let row):
            setActiveBook(abbrev: abbrev)
            chapterOffsetToOpen = chapter
            verseRowToScroll = row
            self?.tabBarController?.selectedIndex = 0
        case .bibleWithBook(let book, let chapter, let row):
            setActiveBook(book: book)
            chapterOffsetToOpen = chapter
            verseRowToScroll = row
            self?.tabBarController?.selectedIndex = 0
        case .bookmark(let id):
            bookmarkToOpen = id
            self?.tabBarController?.selectedIndex = 2
        }
    }
}

extension BibleManager {
    enum TargerViewController {
        case bibleWithAbbrev(abbrev: String, chapter: Int?, rows: [Int]?)
        case bibleWithBook(book: Book, chapter: Int?, rows: [Int]?)
        case bookmark(id: ObjectIdentifier)
    }
}
