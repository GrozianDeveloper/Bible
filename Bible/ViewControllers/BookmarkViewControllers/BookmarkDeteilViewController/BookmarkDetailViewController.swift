//
//  BookmarkDetailViewController.swift
//  Bible
//
//  Created by Bogdan Grozian on 03.03.2022.
//

import UIKit
import AVKit.AVPlayerViewController

final class BookmarkDetailViewController: UIViewController {
    
    let player = AVPlayer()
    let textView = UITextView()
    var verseSelectorView: BibleNavigatorViewController?
    private(set) lazy var versesPresenterView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TextCollectionViewCell.self, forCellWithReuseIdentifier: TextCollectionViewCell.identifier)
        collectionView.contentInset = .init(top: 0, left: 15, bottom: 0, right: 15)
        return collectionView
    }()
    
    let bookmark: Bookmark
    var totalVerses: [BibleVerse]
    var versesToActiveBook: Set<BibleVerse> = []
    var textForCollectionView: [NSAttributedString] = []
    var bookmarkWasChanged: ((Bookmark.ID) -> ())?

    init(bookmark: Bookmark) {
        self.bookmark = bookmark
        self.totalVerses = bookmark.verses?.verses ?? []
        super.init(nibName: nil, bundle: nil)
        self.textForCollectionView = totalVerses.map(createTextForVerse)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let bibleManager = BibleManager.shared
    
    /// First character
    var commandAtLocation: Int? = nil
    var executingCommand: TextCommand? = nil
}

// MARK: - Support
extension BookmarkDetailViewController {
    func createTextForVerse(_ verse: BibleVerse) -> NSAttributedString {
        let text = "\(verse.abbrev) \(verse.chapterOffset + 1):\(verse.row + 1)"
        let arrtibutedText = NSAttributedString(string: text, attributes: [.link: ""])
        return arrtibutedText
    }
    
    enum TextCommand {
        case reference
        case referenceWith
    }
}
