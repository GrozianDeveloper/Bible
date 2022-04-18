//
//  CompareBooksViewController.swift
//  Bible
//
//  Created by Bogdan Grozian on 17.04.2022.
//

import UIKit

final class CompareVersionsViewController: UIViewController {
    
    @IBOutlet weak var stackView: UIStackView!
    
    let bibleManager = BibleManager.shared

    var currentChapter: Int = 0

    var leftVersion: BibleVersion? = nil
    var leftBible: [Book]? = nil
    var leftBook: Book? = nil
    var leftChapter: [String] = []

    var rightVersion: BibleVersion? = nil
    var rightBible: [Book]? = nil
    var rightBook: Book? = nil
    var rightChapter: [String] = []

    let leftTableView = UITableView()
    let rightTableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func openVersionSelector(forLeft isLeft: Bool) {
        let view = UITableView()
        view
    }
    
    func changeCurrentBooks(abbrev: String) {
        guard let leftVersion = leftVersion, let rightVersion = rightVersion else { return }
        let chapter = currentChapter
        let abbrev = leftBook?.abbrev ?? bibleManager.activeBook?.abbrev ?? "gn"
        bibleManager.getBible(version: leftVersion) { [weak self] leftBible in
            self?.leftBible = leftBible
            self?.leftBook = leftBible.first(where: { $0.abbrev == abbrev })
            self?.updateChaptersViewController(isLeft: true, chapter: chapter)
        }
        bibleManager.getBible(version: rightVersion) { [weak self] rightBible in
            self?.rightBible = rightBible
            self?.rightBook = rightBible.first(where: { $0.abbrev == abbrev })
            self?.updateChaptersViewController(isLeft: false, chapter: chapter)
        }
    }
    
    
    func updateChaptersViewController(isLeft: Bool, chapter: Int) {
        guard let book = isLeft ? leftBook : rightBook else { return }
        let newChapter = ChapterViewController(book: book, offset: chapter)
//        if isLeft {
//            leftBookViewController = newChapter
//        } else {
//            rightBookViewController = newChapter
//        }
    }
}
