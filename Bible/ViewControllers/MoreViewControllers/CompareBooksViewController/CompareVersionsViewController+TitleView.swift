//
//  CompareVersionsViewController+TitleView.swift
//  Bible
//
//  Created by Bogdan Grozian on 19.04.2022.
//

import UIKit

extension CompareVersionsViewController {
    func setupCompareView() {
        compareView.leftVersionButton.addTarget(self, action: #selector(compareViewVersionButtonDidTap), for: .touchUpInside)
        compareView.rightVersionButton.addTarget(self, action: #selector(compareViewVersionButtonDidTap), for: .touchUpInside)
        compareView.navigationView.bookButtonDidTapCallBack = { [weak self] in
            self?.openBibleNavigator(.book)
        }
        compareView.navigationView.chapterButtonDidTapCallBack = { [weak self] in
            if let book = self?.leftBook {
                self?.openBibleNavigator(.chapter(book: book))
            }
        }
        navigationItem.titleView = compareView
    }
}

// MARK: Handle
extension CompareVersionsViewController {
    @objc private func compareViewVersionButtonDidTap(button: UIButton) {
        let isLeft = button == compareView.leftVersionButton
        openVersionSelector(forLeft: isLeft)
    }
    
    private func openBibleNavigator(_ type: BibleNavigatorViewController.NavigationType) {
        let vc = BibleNavigatorViewController(type: type)
        vc.delegate = self
        vc.isModalInPresentation = true
        let navigationController = UINavigationController(rootViewController: vc)
        if let presentationController = navigationController.presentationController as? UISheetPresentationController {
            presentationController.detents = [.medium()]
        }
        presentedBibleNavigator = vc
        self.present(navigationController, animated: true)
    }
}

extension CompareVersionsViewController: BibleNavigatorDelegate {
    func didSelect(book: Book, chapterOffset: Int?, verse: Int?) {
        if let offset = chapterOffset {
            self.chapterOffset = offset
        }
        updateBookForVersion(isLeft: true, abbrev: book.abbrev)
        updateBookForVersion(isLeft: false, abbrev: book.abbrev)
        presentedBibleNavigator?.navigationController?.dismiss(animated: true)
    }
}
