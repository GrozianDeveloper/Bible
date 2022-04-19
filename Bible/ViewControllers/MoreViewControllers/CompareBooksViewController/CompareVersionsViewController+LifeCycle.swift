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
        separator.attributedText = NSAttributedString(string: ".\n.\n.", attributes: [
            .foregroundColor: UIColor.clear,
            .strokeColor: UIColor.label
        ])
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        userDefault.set(leftVersion.rawValue, forKey: CVCUserDefaultKeys.previousLeftVersionKey)
        userDefault.set(rightVersion.rawValue, forKey: CVCUserDefaultKeys.previousRightVersionKey)
    }
}

private extension CompareVersionsViewController {
    private func initialDataSetup() {
        let leftPreviousRawValue = userDefault.string(forKey: CVCUserDefaultKeys.previousLeftVersionKey)
        let rightPreviousRawValue = userDefault.string(forKey: CVCUserDefaultKeys.previousRightVersionKey)

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
        let abbrev = bibleManager.activeBook?.abbrev
        updateBookForVersion(isLeft: true, abbrev: abbrev) { [weak self] in
            garanteeMainThread { [weak self] in
                guard let self = self else { return }
                self.compareView.navigationView.bookButton.setTitle(abbrev?.localized(), for: .normal)
            }
        }
        updateBookForVersion(isLeft: false, abbrev: abbrev)
    }
}
