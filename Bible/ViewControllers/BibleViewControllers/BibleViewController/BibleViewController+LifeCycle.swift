//
//  BibleViewController+LifeCycle.swift
//  Bible
//
//  Created by Bogdan Grozian on 16.04.2022.
//

import UIKit

// MARK: - Life Cycle
extension BibleViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBookPageController()
        updatePages()
        setupNavigationBar()
        setupNotificationSubsriptions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkNeedToScroll()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        bibleManager.addChaptersToHistory(items: readedHistoryItems)
    }
}

// MARK: - Setup Book View
extension BibleViewController {
    private func setupBookPageController() {
        addChild(bookPageController)
        view.addSubview(bookPageController.view)
        bookPageController.view.translatesAutoresizingMaskIntoConstraints = false
        bookPageController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        bookPageController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        bookPageController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        bookPageController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        bookPageController.didMove(toParent: self)
        bookPageController.dataSource = self
        bookPageController.delegate = self
    }
}

// MARK: - Scroll to chpater and verse
extension BibleViewController {
    private func checkNeedToScroll() {
//        print(pages.count, activeChapterOffset, bibleManager.chapterOffsetToOpen)
        if let openChapter = bibleManager.chapterOffsetToOpen, !pages.isEmpty {
            if pages.indices.contains(openChapter) {
                activeChapterOffset = openChapter
            } else {
                activeChapterOffset = 0
            }
            let activePage = pages[activeChapterOffset]
            bookPageController.setViewControllers([activePage], direction: .forward, animated: false)
            print("nilled")
            bibleManager.chapterOffsetToOpen = nil
        }
        if let rows = bibleManager.verseRowToScroll {
            let first = bookPageController.viewControllers?.first as? ChapterViewController
            if let row = rows.first {
                let position: UITableView.ScrollPosition = rows.count > 1 ? .top : .middle
                    first?.tableView.scrollToRow(at: [0, row], at: position, animated: false)
                    let _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(scrollToVerse), userInfo: nil, repeats: false)
            }
        }
    }
}

// MARK: - Notification
extension BibleViewController {
    private func setupNotificationSubsriptions() {
        subscribeForNotification(#selector(updatePages), name: BibleManager.activeBookDidChangeNotification)
        subscribeForNotification(#selector(activeBookReferencesDidChange), name: BibleManager.referenceToActiveBookDidChange)
        subscribeForNotification(#selector(safeActiveChapterOffset), name: UIApplication.willResignActiveNotification)
    }
    
    @objc private func activeBookReferencesDidChange() {
        pages.forEach { page in
            page.bookmarkRelatedRows = []
            let inSameChapter = bibleManager.verseReferenceForActiveBookmark.filter { $0.chapterOffset == page.chapterOffset
            }
            page.bookmarkRelatedRows = Set(inSameChapter.map(\.row))
            page.tableView.reloadData()
        }
    }

    @objc func updatePages() {
        guard let book = bibleManager.activeBook else {
            return }
        // update pages
        pages = book.chapters.enumerated().map {
            ChapterViewController(book: book, offset: $0.offset)
        }
        let title = book.abbrev.localized(.bible)
        bibleNavigationView.bookButton.setTitle(title, for: .normal)
        currentBookIndex = bibleManager.bible.firstIndex(of: book) ?? 0
        checkNeedToScroll()
        navigationItem.backButtonTitle = book.name
    }

    @objc private func safeActiveChapterOffset() {
        bibleManager.setLastOpenedChapter(offset: activeChapterOffset)
    }
    
    @objc private func scrollToVerse() {
        guard let rows = bibleManager.verseRowToScroll, let vc = bookPageController.viewControllers?.first as? ChapterViewController else { return }
        vc.scrollToVerse(rows: rows) { [weak self] in
            self?.bibleManager.verseRowToScroll = nil
        }
    }
}
