//
//  CompareVersionsViewController+TableView.swift
//  Bible
//
//  Created by Bogdan Grozian on 19.04.2022.
//

import UIKit

// MARK: - Setup
extension CompareVersionsViewController {
    func setupTableViews() {
        leftTableView.register(TextTableViewCell.nib, forCellReuseIdentifier: TextTableViewCell.identifier)
       leftTableView.delegate = self
       leftTableView.dataSource = self
       
        rightTableView.register(TextTableViewCell.nib, forCellReuseIdentifier: TextTableViewCell.identifier)
       rightTableView.delegate = self
       rightTableView.dataSource = self
   }
}

// MARK: - UITableViewDelegate
extension CompareVersionsViewController: UITableViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isDragingLeftTableView = isLeftTableView(scrollView as! UITableView)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        centerOppositeTableViewVisibleCells(scrollView)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        centerOppositeTableViewVisibleCells(scrollView)
    }
}

// MARK: - UITableViewDataSource
extension CompareVersionsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isLeftTableView(tableView) ? leftChapter.count : rightChapter.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TextTableViewCell.identifier, for: indexPath)
        if let cell = cell as? TextTableViewCell {
            let isLeft = isLeftTableView(tableView)
            cell.label.text = isLeft ? leftChapter[indexPath.row] : rightChapter[indexPath.row]
        }
        return cell
    }
}

// MARK: Centering Feature
extension CompareVersionsViewController {
    func centerOppositeTableViewVisibleCells(_ scrollView: UIScrollView) {
        guard verseCenteredOnScroll else { return }
        let tableView = scrollView as! UITableView
        let isCurrentTableViewLeft = isLeftTableView(tableView)
        guard isDragingLeftTableView == isCurrentTableViewLeft,
                !isDragingSeparator,
                let visibleCellsIndexs = tableView.indexPathsForVisibleRows, !visibleCellsIndexs.isEmpty else {
            return
        }
        let oppositeTable: UITableView
        let oppositeDataSource: [String]
        if isDragingLeftTableView {
            oppositeTable = rightTableView
            oppositeDataSource = rightChapter
        } else {
            oppositeTable = leftTableView
            oppositeDataSource = leftChapter
        }
        let scrollIndex = visibleCellsIndexs.prefix(2).first(where: {
            return tableView.rectForRow(at: $0).origin.y >= tableView.contentOffset.y
        })
        if let indexPath = scrollIndex, oppositeDataSource.indices.contains(indexPath.row) {
            oppositeTable.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
}

// MARK: - Support
private extension CompareVersionsViewController {
    private func isLeftTableView(_ tableView: UITableView) -> Bool {
        return tableView == leftTableView
    }
}
