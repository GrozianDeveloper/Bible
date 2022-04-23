//
//  CompareBooksViewController.swift
//  Bible
//
//  Created by Bogdan Grozian on 17.04.2022.
//

import UIKit

final class CompareVersionsViewController: UIViewController {
    var verseCenteredOnScroll = true
    @IBAction func toggleCenteringVerses(_ sender: UIBarButtonItem) {
        verseCenteredOnScroll.toggle()
        let centered = verseCenteredOnScroll
        UIView.animate(withDuration: 0.2) {
            sender.tintColor = centered ? .label : .secondaryLabel
        }
    }
    
    
    @IBOutlet private(set) weak var leftTableView: UITableView!
    @IBOutlet private(set) weak var rightTableView: UITableView!
    let compareView = VersionsCompareView()
    
    @IBOutlet private weak var separator: UIImageView!
    @IBOutlet private weak var separatorCenterXConstaint: NSLayoutConstraint!
    private(set) var isDragingSeparator = false
    var isDragingLeftTableView = true

    let userDefault = UserDefaults.standard
    let bibleManager = BibleManager.shared

    var chapterOffset: Int = 0

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
            updateChapter(isLeft: true)
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
            updateChapter(isLeft: false)
        }
    }
    private(set) var rightChapter: [String] = []
    var presentedBibleNavigator: BibleNavigatorViewController? = nil
}

// MARK: - Separator
extension CompareVersionsViewController {
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
            let center = view.frame.width / 2
            let maximumOffset = (center) / 2
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
        isDragingLeftTableView = leftTableView.frame.width > rightTableView.frame.width
        let tableView = isDragingLeftTableView ? leftTableView : rightTableView
        centerOppositeTableViewVisibleCells(tableView!)
    }
}

// MARK: Support
extension CompareVersionsViewController {
    private func updateChapter(isLeft: Bool) {
        let book = isLeft ? leftBook : rightBook
        if !book!.chapters.indices.contains(chapterOffset) {
            chapterOffset = 0
        }
        let chapters = book!.chapters[chapterOffset].enumerated().map {
            return "\($0.offset + 1). \($0.element)"
        }
        isLeft ? (leftChapter = chapters) : (rightChapter = chapters)
        garanteeMainThread { [weak self] in
            isLeft ? self?.leftTableView.reloadData() : self?.rightTableView.reloadData()
        }
    }
    private func shortNameForVersion(_ version: BibleVersion) -> String {
        switch version {
        case .kingJamesVersion:
            return " KJV "
        case .Synodal:
            return " СНД "
        }
    }

    struct CVCUserDefaultKeys {
        static let previousLeftVersionKey = "comparePreviousLeftVersion"
        static let previousRightVersionKey = "comparePreviousRightVersion"
        static let previousOpenBook = "comparePreviousOpenBook"
        static let previousOpenChapter = "comparePreviousOpenChapter"
    }
}

