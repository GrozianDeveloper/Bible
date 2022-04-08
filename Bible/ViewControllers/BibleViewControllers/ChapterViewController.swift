//
//  ViewController.swift
//  Bible
//
//  Created by Bogdan Grozian on 27.02.2022.
//

import UIKit

final class ChapterViewController: UITableViewController  {
    init(book: Book, chapters: [String], offset: Int) {
        self.book = book
        self.chapterOffset = offset
        super.init(nibName: nil, bundle: nil)
    }
    
    var bookmarkRelatedRows: Set<Int> = []
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    let book: Book
    let chapterOffset: Int
    private let bibleManager = BibleManager.shared
    
    func scrollToVerse(row: Int, completion: (() -> ())? = nil) {
        let index: IndexPath = [0, row]
        let cell = tableView.cellForRow(at: index)
        cell?.selectionStyle = .gray
        UIView.animateKeyframes(withDuration: 1, delay: .zero) {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
                cell?.setSelected(true, animated: true)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                cell?.setSelected(false, animated: true)
            }
        } completion: { _ in
            completion?()
        }
    }
}

// MARK: - Life Cycle
extension ChapterViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        observeFontSize()
    }
}

// MARK: - Delegate
extension ChapterViewController {
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let row = indexPath.row
        let book = book
        let name = book.name + " \(chapterOffset + 1):\(row + 1)"
        let verseText =  "\(name)\n\(book.chapters[chapterOffset][row])"
        let verse = BibleVerse(abbrev: book.abbrev, chapterOffset: chapterOffset, row: row)
//        let identifier = "\(String(describing: index))" as NSString
        let createBookmark = UIAction(title: "Create bookmark".localized(.ui),
                                      image: UIImage(systemName: "bookmark.fill")) { [weak self] _ in
            guard let self = self else { return }
            let bookmark = self.bibleManager.createBookmark(book: book, verses: [verse], note: verseText)
            self.bibleManager.bookmarkToOpen = bookmark.id
            self.tabBarController?.selectedIndex = 2
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
        return book.chapters[chapterOffset].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TextTableViewCell()
        let row = indexPath.row
        let text = "\(row + 1). \(book.chapters[chapterOffset][row])"
        if bookmarkRelatedRows.contains(indexPath.row) {
            cell.fontType = .boldBible
//            let strokeTextAttributes = [
//                NSAttributedString.Key.strokeColor : UIColor.label,
//                NSAttributedString.Key.strokeWidth : -4.0]
//              as [NSAttributedString.Key : Any]
//            cell.label.attributedText = NSMutableAttributedString(string: text, attributes: strokeTextAttributes)
        } else {
            cell.fontType = .standartBible
        }
        cell.label.text = text
        return cell
    }
}

// MARK: - Setup
extension ChapterViewController {
    private func setupTableView() {
        tableView.register(TextTableViewCell.self, forCellReuseIdentifier: TextTableViewCell.identifier)

        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
    }
}

// MARK: - Support
extension ChapterViewController {
    private func observeFontSize() {
        subscribeForNotification(#selector(fontDidUpdate), name: BibleManager.fontPointSizeDidChangeNotification)
    }
    
    @objc private func fontDidUpdate() {
        tableView.reloadData()
    }
}
