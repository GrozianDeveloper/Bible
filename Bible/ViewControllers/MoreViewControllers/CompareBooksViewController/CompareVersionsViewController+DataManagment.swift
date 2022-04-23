//
//  CompareVersionsViewController+DataManagment.swift
//  Bible
//
//  Created by Bogdan Grozian on 19.04.2022.
//

import UIKit

extension CompareVersionsViewController {
    func openVersionSelector(forLeft isLeft: Bool) {
        let versions = BibleVersion.allCases
        let versionsTitles = versions.map(\.title)
        let listVC = ListPreviewViewController(dataSoruce: [versionsTitles])
        listVC.simpleSelectHandle = { [weak self] indexPath in
            guard let self = self else { return }
            let item = versions[indexPath.row]
            let oppositeVersion = isLeft ? self.rightVersion : self.leftVersion
            if item != oppositeVersion {
                isLeft ? (self.leftVersion = item) : (self.rightVersion = item)
            } else {
                let previousLeft = self.leftVersion
                self.leftVersion = item
                self.rightVersion = previousLeft
                let abbrev = self.leftBook?.abbrev ?? self.rightBook?.abbrev
                self.updateBookForVersion(isLeft: !isLeft, abbrev: abbrev)
            }
            let abbrev = self.leftBook?.abbrev ?? self.rightBook?.abbrev
            self.updateBookForVersion(isLeft: isLeft, abbrev: abbrev)
            listVC.navigationController?.dismiss(animated: true)
        }
        listVC.isModalInPresentation = true
        let navigationController = UINavigationController(rootViewController: listVC)
        if let presentationController = navigationController.presentationController as? UISheetPresentationController {
            presentationController.detents = [.medium()]
        }
        self.present(navigationController, animated: true)
    }
    
    func updateBookForVersion(isLeft: Bool, abbrev: String?, completion: ((Book) -> ())? = nil) {
        guard let version = isLeft ? leftVersion : rightVersion else { return }
        let abbrev = abbrev ?? bibleManager.activeBook?.abbrev ?? "gn"
        bibleManager.getBible(version: version) { [weak self] bible in
            guard let self = self else { return }
            if isLeft {
                self.leftBible = bible
                self.leftBook = bible.first(where: { $0.abbrev == abbrev })
                completion?(self.leftBook!)
            } else {
                self.rightBible = bible
                self.rightBook = bible.first(where: { $0.abbrev == abbrev })
                completion?(self.rightBook!)
            }
        }
    }
}

// MARK: - Handy Methods
extension CompareVersionsViewController {
}
