//
//  CompareBooksViewController.swift
//  Bible
//
//  Created by Bogdan Grozian on 17.04.2022.
//

import UIKit

final class CompareVersionsViewController: UIViewController {
    @IBOutlet weak var separatorCenterXConstaint: NSLayoutConstraint!

    var isDragingSeparator = false

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let currentTouch = touch.location(in: view)
            separator.frame.contains(currentTouch)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let currentTouch = touch.location(in: view).x
            let previousTouch = touch.previousLocation(in: view).x
            let shifting = currentTouch - previousTouch
            let maximumOffset = (view.frame.width / 2) / 2
            let newOffset = separatorCenterXConstaint.constant + shifting
            if abs(newOffset) < maximumOffset {
                separatorCenterXConstaint.constant = newOffset
            } else {
                let isOnLeftSide = (newOffset - maximumOffset) < .zero
                separatorCenterXConstaint.constant = isOnLeftSide ? -maximumOffset : maximumOffset
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDragingSeparator = false
    }
    
//    @IBOutlet weak var separator: UIImageView!
    
    @IBOutlet weak var separator: UILabel!
    let bibleManager = BibleManager.shared

    var currentChapter: Int = 0

    let userDefault = UserDefaults.standard
    var leftVersion: BibleVersion! {
        didSet {
            let name = shortNameForVersion(leftVersion)
            garanteeMainThread { [weak self] in
                self?.compareView.leftVersionButton.setTitle(name, for: .normal)
            }
        }
    }
    var leftBible: [Book]!
    var leftBook: Book! {
        didSet {
            if !leftBook.chapters.indices.contains(currentChapter) {
                currentChapter = 0
            }
            leftChapter = leftBook.chapters[currentChapter].enumerated().map {
                return "\($0.offset + 1). \($0.element) "
            }
            garanteeMainThread { [weak self] in
                self?.leftTableView.reloadData()
            }
        }
    }
    private(set) var leftChapter: [String] = []

    var rightVersion: BibleVersion! {
        didSet {
            let name = shortNameForVersion(rightVersion)
            garanteeMainThread { [weak self] in
                self?.compareView.rightVersionButton.setTitle(name, for: .normal)
            }
        }
    }
    var rightBible: [Book]!
    var rightBook: Book! {
        didSet {
            if !rightBook.chapters.indices.contains(currentChapter) {
                currentChapter = 0
            }
            rightChapter = rightBook.chapters[currentChapter].enumerated().map {
                return "\($0.offset + 1). \($0.element) "
            }
            garanteeMainThread { [weak self] in
                self?.rightTableView.reloadData()
            }
        }
    }
    private(set) var rightChapter: [String] = []

    @IBOutlet private(set) weak var leftTableView: UITableView!
    @IBOutlet private(set) weak var rightTableView: UITableView!
    
    let compareView = VersionsCompareView()
}

extension CompareVersionsViewController {
    struct CVCUserDefaultKeys {
        static let previousLeftVersionKey = "PreviousLeftVersion"
        static let previousRightVersionKey = "PreviousRightVersion"
    }
}

extension CompareVersionsViewController {
    private func shortNameForVersion(_ version: BibleVersion) -> String {
        switch version {
        case .kingJamesVersion:
            return " KJV "
        case .Synodal:
            return " СНД "
        }
    }
}
