//
//  ViewController.swift
//  Bible
//
//  Created by Bogdan Grozian on 27.02.2022.
//

import UIKit

final class ChapterViewController: UITableViewController  {
    
    private let bibleManager = BibleManager.shared

    let book: Book
    let chapterOffset: Int
    private let chapterText: [String]

    init(book: Book, offset: Int) {
        self.book = book
        self.chapterOffset = offset
        chapterText = book.chapters[chapterOffset]
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("ChapterViewController not created for coder")
    }

    var bookmarkRelatedRows: Set<Int> = []
}

// MARK: - Life Cycle
extension ChapterViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(TextTableViewCell.nib, forCellReuseIdentifier: TextTableViewCell.identifier)
        tableView.separatorStyle = .none
        subscribeForNotification(#selector(fontDidUpdate), name: BibleManager.fontPointSizeDidChangeNotification)
    }
}

// MARK: - Scroll To Verse
extension ChapterViewController {
    func scrollToVerse(rows: [Int], completion: (() -> ())? = nil) {
        guard !rows.isEmpty else {
            completion?()
            return
        }
        var indexes: [Int]
        if rows.count == 1 {
            indexes = [rows.first!]
        } else {
            indexes = Array(rows.first!...rows.last!)
        }
        let cells = indexes.compactMap {
            tableView.cellForRow(at: [0, $0]) as? TextTableViewCell
        }
        cells.forEach { $0.selectionColor = .systemGray }
        UIView.animateKeyframes(withDuration: 1, delay: .zero) {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
                cells.forEach { $0.setSelected(true, animated: true) }
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                cells.forEach { $0.setSelected(false, animated: true) }
            }
        } completion: { _ in
            completion?()
        }
    }
}

// MARK: - Delegate
extension ChapterViewController {
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let row = indexPath.row
        let title = book.name + " \(chapterOffset + 1):\(row + 1)"
        let verseText = "\(title)\n\(chapterText[row])"

        let createBookmark = UIAction(title: "Create bookmark".localized(.ui),
                                      image: UIImage(systemName: "bookmark.fill")) { [weak self] _ in
            guard let self = self else { return }
            let verse = BibleVerse(abbrev: self.book.abbrev,
                                   chapterOffset: self.chapterOffset,
                                   row: row)
            let bookmark = self.bibleManager.createBookmark(book: self.book,
                                                            verses: [verse],
                                                            note: verseText)
            self.bibleManager.openViewController(self, target: .bookmark(id: bookmark.id))
        }

        let copyText = UIAction(title: "Copy".localized(.ui)) { action in
            UIPasteboard.general.string = verseText
        }

        var menuChildrens: [UIMenuElement] = [createBookmark, copyText]
        if bookmarkRelatedRows.contains(indexPath.row) {
            let bookmarks = getBookmarksFor(row)
            if !bookmarks.isEmpty {
                bookmarks.forEach { bookmark in
                    let bookmarkAction = UIAction(
                        title: bookmark.title ?? "Bookmark Title",
                        image: UIImage(systemName: "bookmark.fill")) { [weak self] _ in
                            self?.bibleManager.openViewController(self, target: .bookmark(id: bookmark.id))
                    }
                    menuChildrens.append(bookmarkAction)
                }
            }
        }
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { _ in
            let menu = UIMenu(title: "", image: nil, children: menuChildrens)
            return menu
        })
    }
    
    private func getBookmarksFor(_ row: Int) -> Set<Bookmark> {
        guard let abbrev = bibleManager.activeBook?.abbrev else { return [] }
        var returningBookmarks: Set<Bookmark> = []
        bibleManager.bookmarks.forEach { bookmark in
            bookmark.verses?.verses.forEach {
                if $0.abbrev == abbrev, $0.chapterOffset == chapterOffset, $0.row == row {
                    returningBookmarks.insert(bookmark)
                }
            }
        }
        return returningBookmarks
    }
}

// MARK: - DataSource
extension ChapterViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chapterText.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: TextTableViewCell.identifier, for: indexPath)
        if let cell = cell as? TextTableViewCell {
            let row = indexPath.row
            let text = "\(row + 1). \(chapterText[row])"
            let standardFont = BibleManager.shared.font
            if bookmarkRelatedRows.contains(indexPath.row), bibleManager.colorizeReferencedverses {
                cell.label.font = .boldSystemFont(ofSize: standardFont.pointSize)
            } else {
                cell.label.font = standardFont
            }
            cell.label.text = text
        }
        return cell
    }
}

// MARK: - Support
extension ChapterViewController {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == BibleManager.SwitchableSettings.colorizeVerses.userDefaultKey {
            let indexes = bookmarkRelatedRows.map { IndexPath(row: $0, section: 0)}
            tableView.reloadRows(at: indexes, with: .none)
        }
    }
    
    @objc private func fontDidUpdate() {
        tableView.reloadData()
    }
}
