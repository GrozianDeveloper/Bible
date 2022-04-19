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

        navigationItem.titleView = compareView
    }
}

// MARK: Handle
extension CompareVersionsViewController {
    @objc private func compareViewVersionButtonDidTap(button: UIButton) {
        let isLeft = button == compareView.leftVersionButton
        openVersionSelector(forLeft: isLeft)
    }
}
