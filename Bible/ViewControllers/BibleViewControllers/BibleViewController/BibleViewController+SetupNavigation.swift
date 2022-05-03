//
//  BibleViewController+SetupNavigation.swift
//  Bible
//
//  Created by Bogdan Grozian on 28.02.2022.
//

import UIKit

extension BibleViewController {
    func setupNavigationBar() {
        bibleNavigationView.chapterButtonDidTapCallBack = chapterButtonDidTap
        bibleNavigationView.bookButtonDidTapCallBack = bookButtonDidTap
        navigationItem.titleView = bibleNavigationView
        setupLeftBarItem()
        setupRightBarItem()
        checkNavigationBarButton()
    }
    
    private func setupLeftBarItem() {
        let item = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(leftBarItemDidTap))
        navigationItem.leftBarButtonItem = item
    }
    private func setupRightBarItem() {
        let item = UIBarButtonItem(image: UIImage(systemName: "chevron.right"), style: .plain, target: self, action: #selector(rightBarItemDidTap))
        navigationItem.rightBarButtonItem = item
    }
    
    private func checkNavigationBarButton() {
        let offset = activeChapterOffset
        activeChapterOffset = offset
    }
}

// MARK: Handle Navigation Buttons
extension BibleViewController {
    private func bookButtonDidTap() {
        let navigatorVC = BibleNavigatorViewController(type: .book)
        navigatorVC.delegate = self
        self.navigationController?.pushViewController(navigatorVC, animated: true)
    }

    private func chapterButtonDidTap() {
        guard let book = bibleManager.activeBook else { return }
        let navigatorVC = BibleNavigatorViewController(type: .chapter(book: book))
        navigatorVC.delegate = self
        self.navigationController?.pushViewController(navigatorVC, animated: true)
    }
    
    @objc private func leftBarItemDidTap() {
        if activeChapterOffset > 0 {
            activeChapterOffset -= 1
            bookPageController.setViewControllers([pages[activeChapterOffset]], direction: .forward, animated: false)
        } else if let book = previousBook {
            let chapter = book.chapters.count - 1
            activeChapterOffset = chapter
            bibleManager.chapterOffsetToOpen = chapter
            bibleManager.openViewController(self, target: .bibleWithBook(book: book, chapter: activeChapterOffset, rows: nil))
            previousBook = nil
        }
    }

    @objc private func rightBarItemDidTap() {
        if activeChapterOffset < pages.count - 1 {
            activeChapterOffset += 1
            bookPageController.setViewControllers([pages[activeChapterOffset]], direction: .forward, animated: false)
        } else if let book = nextBook {
            activeChapterOffset = 0
            bibleManager.chapterOffsetToOpen = activeChapterOffset
            bibleManager.openViewController(self, target: .bibleWithBook(book: book, chapter: bibleManager.chapterOffsetToOpen, rows: nil))
            nextBook = nil
        }
    }
}

// MARK: - BibleNavigatorDelegate2
extension BibleViewController: BibleNavigatorDelegate {
    func didSelect(book: Book, chapterOffset: Int?, verse: Int?) {
        bibleManager.chapterOffsetToOpen = chapterOffset
        bibleManager.setActiveBook(book: book)
    }
}
