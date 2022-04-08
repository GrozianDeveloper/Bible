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
        setupNotificationAcceptence()
        bookmarksDidChange()
        tableView.allowsMultipleSelectionDuringEditing = true
        navigationItem.title = "Bookmarks"
        tableView.separatorInset = .zero
        setupCreateEmptyBookmarkBarButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        openBookmark()
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
    @objc private func openBookmark() {
        guard let identifier = bibleManager.bookmarkToOpen else { return }
        if let offset = bookmarks.enumerated().first(where: { $0.element.id == identifier })?.offset {
            bibleManager.bookmarkToOpen = nil
            let indexPath: IndexPath = [0, offset]
            tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
            tableView(tableView, didSelectRowAt: indexPath)
        }
    }

    private func setupNotificationAcceptence() {
        subscribeForNotification(#selector(bookmarksDidChange), name: BibleManager.bookmarksDidChangeNotification)
    }
    
    @objc private func bookmarksDidChange() {
        bookmarks = bibleManager.bookmarks
        checkIsNeededToHideRemoveBarButton()
        tableView.reloadData()
    }
    
    private func checkIsNeededToHideRemoveBarButton() {
        if bookmarks.isEmpty {
            navigationItem.rightBarButtonItem = nil
        } else if navigationItem.rightBarButtonItem == nil {
            setupRemoveAllButton()
        }
    }
}
// MARK: Editing Bookmarks list
extension BookmarkListViewController {
    private func handleSelectToRemoveBookmarks() {
        self.tableView.isEditing = true
        let removeSelected = UIAction { [weak self] _ in
            guard let self = self else { return }
            self.selectedBookmarks.forEach { bookmark in
                let offset = self.bookmarks.enumerated().first(where: { $0.element.id == bookmark.id })?.offset
                if let offset = offset {
                    self.bookmarks.remove(at: offset)
                    self.bibleManager.deleteBookmark(bookmark: bookmark)
                }
                self.tableView.reloadData()
            }
            self.tableView.isEditing = false
            self.setupRemoveAllButton()
        }
        let trashImage = UIImage(systemName: "trash")?.withRenderingMode(.alwaysTemplate)
        let barButton = UIBarButtonItem(title: nil, image: trashImage, primaryAction: removeSelected, menu: nil)
        barButton.tintColor = .red
        self.navigationItem.setRightBarButton(barButton, animated: true)
    }

    private func handleRemoveAllBookmarks() {
        bibleManager.bookmarks.forEach {
            bibleManager.deleteBookmark(bookmark: $0)
        }
        bookmarks = bibleManager.bookmarks
        tableView.reloadData()
    }
    
    private func setupRemoveAllButton() {
        let selectToRemoveBookmark = UIAction { [weak self] _ in
            self?.handleSelectToRemoveBookmarks()
        }
        let removeAll = UIAction(title: "Remove all bookmarks", attributes: [.destructive]) { [weak self] _ in
            self?.handleRemoveAllBookmarks()
        }
        let removeAllMenu = UIMenu(children: [removeAll])
        let barButton = UIBarButtonItem(title: "Edit", image: nil, primaryAction: selectToRemoveBookmark, menu: removeAllMenu)
        navigationItem.setRightBarButton(barButton, animated: true)
    }
    
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
}