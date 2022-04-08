//
//  MainViewController.swift
//  Bible
//
//  Created by Bogdan Grozian on 27.02.2022.
//

import UIKit

final class BibleViewController: UIViewController {

    let bookViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    let bibleNavigationView = BibleNavigationView()
    
    /// Page = chapter
    private(set) var pages = [ChapterViewController]()

    var activeChapterOffset: Int = BibleManager.shared.getLastOpenedChapterOffset() {
        didSet {
            checkActiveChapterOffset()
            addChapterToReadedItems(offset: activeChapterOffset)
            updateNavigationItem()
        }
    }
    private var readedHistoryItems = [BibleHistoryItem]()
    let bibleManager = BibleManager.shared
    
    var nextBook: Book?
    var previousBook: Book?
    private(set) var currentBookIndex = 0 {
        didSet {
            updateNavigationItem()
        }
    }
}

// MARK: - Life Cycle
extension BibleViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        createBookViewController()
        updatePages()
        setupNavigationBar()
        setupNotificationSubsriptions()
        addBookViewController()
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

extension BibleViewController {
    private func checkNeedToScroll() {
        if let openChapter = bibleManager.chapterOffsetToOpen, pages.indices.contains(openChapter) {
            activeChapterOffset = openChapter
            let activePage = pages[activeChapterOffset]
            bookViewController.setViewControllers([activePage], direction: .forward, animated: false)
        }
        if let row = bibleManager.verseRowToScroll {
            let first = bookViewController.viewControllers?.first as? ChapterViewController
            first?.tableView.scrollToRow(at: [0, row], at: .middle, animated: false)
            let _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(scrollToVerse), userInfo: nil, repeats: false)
        }
    }
}

// MARK: - Setup Book View
extension BibleViewController {
    private func createBookViewController() {
        bookViewController.dataSource = self
        bookViewController.delegate = self
    }

    private func addBookViewController() {
        addChild(bookViewController)
        view.addSubview(bookViewController.view)
        bookViewController.view.translatesAutoresizingMaskIntoConstraints = false
        bookViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        bookViewController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        bookViewController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        bookViewController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        bookViewController.didMove(toParent: self)
    }
}

// MARK: - Notification
extension BibleViewController {
    private func setupNotificationSubsriptions() {
        subscribeForNotification(#selector(updatePages), name: BibleManager.activeBookDidChangeNotification)
        subscribeForNotification(#selector(safeActiveChapterOffset), name: UIApplication.willResignActiveNotification)
        subscribeForNotification(#selector(activeBookReferencesDidChange), name: BibleManager.referenceToActiveBookDidChange)
    }
    
    @objc private func activeBookReferencesDidChange() {
        pages.forEach { page in
            page.bookmarkRelatedRows = []
            let inSameChapter = bibleManager.verseReferenceForActiveBookmark.filter( { verse in
                return verse.chapterOffset == page.chapterOffset
            })
            page.bookmarkRelatedRows = Set(inSameChapter.map(\.row))
        }
    }

    @objc private func updatePages() {
        guard let book = bibleManager.activeBook else { return }
        // update pages
        pages = book.chapters.enumerated().map { chapter in
            let vc = ChapterViewController(book: book, chapters: chapter.element, offset: chapter.offset)
            return vc
        }
        let title = book.abbrev.localized(.bible)
        bibleNavigationView.bookButton.setTitle(title, for: .normal)
        currentBookIndex = bibleManager.bible.firstIndex(of: book) ?? 0
        checkNeedToScroll()
    }

    @objc private func safeActiveChapterOffset() {
        bibleManager.setLastOpenedChapter(offset: activeChapterOffset)
    }
    
    @objc private func scrollToVerse() {
        guard let row = bibleManager.verseRowToScroll, let vc = bookViewController.viewControllers?.first as? ChapterViewController else { return }
        vc.scrollToVerse(row: row) { [weak self] in
            self?.bibleManager.verseRowToScroll = nil
        }
    }
}

// MARK: - Support
extension BibleViewController {
    private func checkActiveChapterOffset() {
        guard let book = bibleManager.activeBook else { return }
        if activeChapterOffset == 0 {
            updateNextOrPreviousBook(isNext: false)
        } else if activeChapterOffset == book.chapters.count - 1 {
            updateNextOrPreviousBook(isNext: true)
        }
    }
    
    
    /// - Parameter isNext: if false will update previous book
    private func updateNextOrPreviousBook(isNext: Bool) {
        guard let book = bibleManager.activeBook else { return }
        let offset = bibleManager.bible.enumerated().first(where: { $0.element.abbrev == book.abbrev })?.offset ?? 0
        let newOffset = offset + (isNext ? 1 : -1)
        if bibleManager.bible.indices.contains(newOffset) {
            if isNext {
                nextBook = bibleManager.bible[newOffset]
            } else {
                previousBook = bibleManager.bible[newOffset]
                
            }
        }
    }
    
    private func addChapterToReadedItems(offset: Int) {
        guard let abbrev = bibleManager.activeBook?.abbrev else { return }
        readedHistoryItems.append(.init(abbrev: abbrev, chapterOffset: offset))
    }
    
    private func updateNavigationItem() {
        bibleNavigationView.chapterButton.setTitle(String(activeChapterOffset + 1), for: .normal)
        configureLeftNavigaitonItem()
        configureRightNavigaitonItem()
    }
    private func configureLeftNavigaitonItem() {
        guard let item = navigationItem.leftBarButtonItem else { return }
        if activeChapterOffset == 0 {
            item.image = UIImage(systemName: "arrow.turn.up.left")
            if currentBookIndex == 0 {
                item.tintColor = .quaternaryLabel
            }
        } else {
            item.image = UIImage(systemName: "chevron.left")
            if item.tintColor == .quaternaryLabel {
                item.tintColor = .tintColor
            }
        }
    }

    private func configureRightNavigaitonItem() {
        guard let item = navigationItem.rightBarButtonItem else { return }
        if activeChapterOffset == pages.endIndex - 1 {
            item.image = UIImage(systemName: "arrow.turn.up.right")
            if currentBookIndex == bibleManager.bible.endIndex - 1 {
                item.tintColor = .quaternaryLabel
            }
        } else {
            item.image = UIImage(systemName: "chevron.right")
            if item.tintColor == .quaternaryLabel {
                item.tintColor = .tintColor
            }
        }
    }
    
    private func getBookNameAbbreviations(_ book: Book) -> String {
//        switch book.abbrev {
//            case
//        }
        return ""
    }
}
