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
        setupBackBarItem()
        self.navigationController?.pushViewController(navigatorVC, animated: true)
    }

    private func chapterButtonDidTap() {
        guard let book = bibleManager.activeBook else { return }
        let navigatorVC = BibleNavigatorViewController(type: .chapter(book: book))
        setupBackBarItem()
        self.navigationController?.pushViewController(navigatorVC, animated: true)
    }
    
    @objc private func leftBarItemDidTap() {
        if activeChapterOffset > 0 {
            activeChapterOffset -= 1
            bookViewController.setViewControllers([pages[activeChapterOffset]], direction: .forward, animated: false)
        } else if let book = previousBook {
            let chapterOffset = book.chapters.count - 1
            bibleManager.openViewController(self, target: .bible(abbrev: book.abbrev, chapter: chapterOffset, row: nil))
            previousBook = nil
        }
    }

    @objc private func rightBarItemDidTap() {
        if activeChapterOffset < pages.count - 1 {
            activeChapterOffset += 1
            bookViewController.setViewControllers([pages[activeChapterOffset]], direction: .forward, animated: false)
        } else if let book = nextBook {
            bibleManager.openViewController(self, target: .bible(abbrev: book.abbrev, chapter: 0, row: nil))
            nextBook = nil
        }
    }
    
    private func setupBackBarItem() {
        let backItem = UIBarButtonItem()
        backItem.title = bibleManager.activeBook?.name ?? "Bible".localized()
        navigationItem.backBarButtonItem = backItem
    }
}
