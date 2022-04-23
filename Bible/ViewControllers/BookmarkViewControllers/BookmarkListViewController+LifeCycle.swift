//
//  BookmarkListViewController+LifeCycle.swift
//  Bible
//
//  Created by Bogdan Grozian on 06.04.2022.
//

import UIKit

extension BookmarkListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(BookmarkTableViewCell.nib, forCellReuseIdentifier: BookmarkTableViewCell.identifier)
        subscribeForNotification(#selector(bookmarksDidChange), name: BibleManager.bookmarksDidChangeNotification)
        bookmarksDidChange()
        tableView.allowsMultipleSelectionDuringEditing = true
        navigationItem.title = "Bookmarks"
        tableView.separatorInset = .zero
        setupCreateEmptyBookmarkBarButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkIsNeedToOpenBookmark()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removedBookmarks.forEach { identifier in
            let bookmark = bibleManager.bookmarks.first(where: { $0.id == identifier })
            if let bookmark = bookmark {
                bibleManager.deleteBookmark(bookmark: bookmark)
            }
        }
        bibleManager.saveContext()
    }
}

extension BookmarkListViewController {
    @objc private func checkIsNeedToOpenBookmark() {
        guard let identifier = bibleManager.bookmarkToOpen else { return }
        if let offset = bookmarks.enumerated().first(where: { $0.element.id == identifier })?.offset {
            bibleManager.bookmarkToOpen = nil
            let indexPath: IndexPath = [0, offset]
            tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
            tableView(tableView, didSelectRowAt: indexPath)
        }
    }
    
    @objc private func bookmarksDidChange() {
        bookmarks = bibleManager.bookmarks
        checkIsNeededToHideRemoveBarButton()
        tableView.reloadData()
    }
    
    func checkIsNeededToHideRemoveBarButton() {
        if bookmarks.isEmpty {
            navigationItem.rightBarButtonItem = nil
        } else if navigationItem.rightBarButtonItem == nil {
            setupRemoveAllButton()
        }
    }
}

// MARK: Editing Bookmarks list
extension BookmarkListViewController {
    private func handleSelectToRemoveBookmarks(_ action: UIAction) {
        self.tableView.isEditing = true
        let removeSelected = UIAction { [weak self] _ in
            guard let self = self else { return }
            self.selectedBookmarks.forEach { bookmark in
                let offset = self.bookmarks.enumerated().first(where: { $0.element.id == bookmark.id })?.offset
                if let offset = offset {
                    self.bookmarks.remove(at: offset)
                    self.tableView.deleteRows(at: [[0, offset]], with: .left)
                    self.bibleManager.deleteBookmark(bookmark: bookmark)
                }
            }
            self.tableView.isEditing = false
            self.setupRemoveAllButton()
            self.checkIsNeededToHideRemoveBarButton()
        }
        let barButton = UIBarButtonItem(title: "Done", image: nil, primaryAction: removeSelected, menu: nil)
        self.navigationItem.setRightBarButton(barButton, animated: true)
    }
}

// MARK: - Setup
extension BookmarkListViewController {
    private func setupCreateEmptyBookmarkBarButton() {
        let createEmpyBookmark = UIAction { [weak self] _ in
            guard let self = self else { return }
            let bookmark = self.bibleManager.createBookmark(title: "Empy Bookmark")
            if let row = self.bookmarks.enumerated().first(where: { $0.element.id == bookmark.id })?.offset {
                let indexPath: IndexPath = [0, row]
                self.tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
                self.tableView(self.tableView, didSelectRowAt: indexPath)
            }
        }
        let barButton = UIBarButtonItem(image: UIImage(systemName: "plus"), primaryAction: createEmpyBookmark)
        navigationItem.setLeftBarButton(barButton, animated: true)
    }
    
    private func handleRemoveAllBookmarks(_ action: UIAction) {
        bibleManager.bookmarks.enumerated().forEach {
            bibleManager.deleteBookmark(bookmark: $0.element, updateReferencesToActiveBook: false)
        }
        if let book = bibleManager.activeBook {
            bibleManager.updateBookmarkReferencesToBook(book: book)
        }
        checkIsNeededToHideRemoveBarButton()
    }
    
    private func setupRemoveAllButton() {
        let selectToRemoveBookmark = UIAction(handler: handleSelectToRemoveBookmarks)
        let removeAll = UIAction(title: "Remove all bookmarks", attributes: [.destructive], handler: handleRemoveAllBookmarks)
        let removeAllMenu = UIMenu(children: [removeAll])
        let barButton = UIBarButtonItem(title: "Edit", image: nil, primaryAction: selectToRemoveBookmark, menu: removeAllMenu)
        navigationItem.setRightBarButton(barButton, animated: true)
    }
}
