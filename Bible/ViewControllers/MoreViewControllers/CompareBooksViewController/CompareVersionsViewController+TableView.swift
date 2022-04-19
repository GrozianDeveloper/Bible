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
extension CompareVersionsViewController: UITableViewDelegate {
    
}

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

// MARK: - Support
private extension CompareVersionsViewController {
    private func isLeftTableView(_ tableView: UITableView) -> Bool {
        return tableView == leftTableView
    }
}
