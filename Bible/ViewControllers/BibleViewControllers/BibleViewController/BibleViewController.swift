//
//  MainViewController.swift
//  Bible
//
//  Created by Bogdan Grozian on 27.02.2022.
//

import UIKit

final class BibleViewController: UIViewController {

    let bibleManager = BibleManager.shared

    let bookPageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    let bibleNavigationView = BibleNavigationView()
    
    /// Pages == book chapters
    var pages = [ChapterViewController]()

    var activeChapterOffset: Int = BibleManager.shared.getLastOpenedChapterOffset() {
        didSet {
            checkActiveChapterOffset()
            addChapterToReadedHistory(offset: activeChapterOffset)
            updateNavigationItem()
        }
    }

    var readedHistoryItems = [BibleHistoryItem]()

    var currentBookIndex = 0
    var nextBook: Book?
    var previousBook: Book?
}

// MARK: - Support
private extension BibleViewController {
    private func checkActiveChapterOffset() {
        guard let book = bibleManager.activeBook else { return }
        if activeChapterOffset == 0 {
            updateNextOrPreviousBook(isNext: false)
        } else if activeChapterOffset == book.chapters.count - 1 {
            updateNextOrPreviousBook(isNext: true)
        }
    }
    
    private func addChapterToReadedHistory(offset: Int) {
        guard let abbrev = bibleManager.activeBook?.abbrev else { return }
        readedHistoryItems.append(BibleHistoryItem(abbrev: abbrev, chapterOffset: offset))
    }
    
    private func updateNavigationItem() {
        bibleNavigationView.chapterButton.setTitle(String(activeChapterOffset + 1), for: .normal)
        updateLeftOrRightNavigationItem(isLeft: true)
        updateLeftOrRightNavigationItem(isLeft: false)
    }

    /// - Parameter isNext: if false will update previous book
    private func updateNextOrPreviousBook(isNext: Bool) {
        guard let book = bibleManager.activeBook,
              let offset = bibleManager.bible.enumerated().first(where: { $0.element.abbrev == book.abbrev })?.offset else {
            return
        }
        let newOffset = offset + (isNext ? 1 : -1)
        if bibleManager.bible.indices.contains(newOffset) {
            if isNext {
                nextBook = bibleManager.bible[newOffset]
            } else {
                previousBook = bibleManager.bible[newOffset]
            }
        }
    }
    
    /// - Parameter isLeft: If false will update right
    private func updateLeftOrRightNavigationItem(isLeft: Bool) {
        guard let item = isLeft ? navigationItem.leftBarButtonItem : navigationItem.rightBarButtonItem else { return }
        let checkChapterOffset = isLeft ? activeChapterOffset == 0 : activeChapterOffset == pages.endIndex - 1
        let direction = isLeft ? "left" : "right"
        if checkChapterOffset {
            let imageName = "arrow.turn.up.\(direction)"
            item.image = UIImage(systemName: imageName)
            let checkBookIndex = isLeft ? currentBookIndex == 0 : currentBookIndex == bibleManager.bible.endIndex - 1
            if checkBookIndex {
                item.tintColor = .tertiaryLabel
            } else if item.tintColor != .label {
                item.tintColor = .label
            }
        } else {
            let standartImage = UIImage(systemName: "chevron.\(direction)")
            if item.image != standartImage {
                item.image = standartImage
            }
            if item.tintColor != .secondaryLabel {
                item.tintColor = .secondaryLabel
            }
        }
    }
}
