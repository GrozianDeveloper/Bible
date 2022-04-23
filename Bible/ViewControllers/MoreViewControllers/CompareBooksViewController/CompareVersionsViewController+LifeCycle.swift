//
//  CompareVersionsViewController+LifeCycle.swift
//  Bible
//
//  Created by Bogdan Grozian on 19.04.2022.
//

import UIKit

// MARK: - LifeCycle
extension CompareVersionsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        initialDataSetup()
        setupCompareView()
        setupTableViews()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        userDefault.set(leftVersion.rawValue, forKey: CVCUserDefaultKeys.previousLeftVersionKey)
        userDefault.set(rightVersion.rawValue, forKey: CVCUserDefaultKeys.previousRightVersionKey)
        userDefault.set(leftBook.abbrev, forKey: CVCUserDefaultKeys.previousOpenBook)
        userDefault.set("\(chapterOffset)", forKey: CVCUserDefaultKeys.previousOpenChapter)
    }
}

private extension CompareVersionsViewController {
    private func initialDataSetup() {
        let leftPreviousRawValue = userDefault.string(forKey: CVCUserDefaultKeys.previousLeftVersionKey)
        let rightPreviousRawValue = userDefault.string(forKey: CVCUserDefaultKeys.previousRightVersionKey)
        let lastOpenBookAbbrev = userDefault.string(forKey: CVCUserDefaultKeys.previousOpenBook)
        
        if let lastOpenChapter = userDefault.string(forKey: CVCUserDefaultKeys.previousOpenChapter) {
            chapterOffset = Int(lastOpenChapter)!
        }

        var leftVersion: BibleVersion?
        var rightVersion: BibleVersion?
        if let value = leftPreviousRawValue {
            leftVersion = BibleVersion(rawValue: value)
        }
        if let value = rightPreviousRawValue {
            rightVersion = BibleVersion(rawValue: value)
        }
        self.leftVersion = leftVersion ?? bibleManager.bibleVersion
        if let version = rightVersion {
            self.rightVersion = version
        } else {
            self.rightVersion = BibleVersion.allCases.first(where: { $0 != self.leftVersion })!
        }
        let abbrev = lastOpenBookAbbrev ?? bibleManager.activeBook?.abbrev
        updateBookForVersion(isLeft: true, abbrev: abbrev) { [weak self] book in
            garanteeMainThread { [weak self] in
                guard let self = self else { return }
                self.compareView.navigationView.bookButton.setTitle(book.abbrev.localized(), for: .normal)
            }
        }
        updateBookForVersion(isLeft: false, abbrev: abbrev)
    }
}
