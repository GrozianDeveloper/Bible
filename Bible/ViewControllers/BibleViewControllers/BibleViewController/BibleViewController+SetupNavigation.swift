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
    }
    
    private func setupLeftBarItem() {
        let item = UIBarButtonItem(image: UIImage(systemName: "chevron.left.circle"), style: .plain, target: self, action: #selector(leftBarItemDidTap))
        navigationItem.leftBarButtonItem = item
    }
    private func setupRightBarItem() {
        let item = UIBarButtonItem(image: UIImage(systemName: "chevron.right.circle"), style: .plain, target: self, action: #selector(rightBarItemDidTap))
        navigationItem.rightBarButtonItem = item
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
            bibleManager.chapterOffsetToOpen = chapter
            bibleManager.openViewController(self, target: .bibleWithBook(book: book, chapter: bibleManager.chapterOffsetToOpen!, rows: nil))
            previousBook = nil
        }
    }

    @objc private func rightBarItemDidTap() {
        if activeChapterOffset < pages.count - 1 {
            activeChapterOffset += 1
            bookPageController.setViewControllers([pages[activeChapterOffset]], direction: .forward, animated: false)
        } else if let book = nextBook {
            bibleManager.chapterOffsetToOpen = 0
            bibleManager.openViewController(self, target: .bibleWithBook(book: book, chapter: 0, rows: nil))
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
