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
        case .bible(let abbrev, let chapter, let row):
            setActiveBook(abbrev: abbrev)
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
        case bible(abbrev: String, chapter: Int, row: Int?)
        case bookmark(id: ObjectIdentifier)
    }
}
