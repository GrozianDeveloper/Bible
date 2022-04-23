//
//  BookmarkListViewController+TableView.swift
//  Bible
//
//  Created by Bogdan Grozian on 06.04.2022.
//

import UIKit

// MARK: - Delegate
extension BookmarkListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            let bookmark = bookmarks[indexPath.row]
            selectedBookmarks.insert(bookmark)
            if let button = navigationItem.rightBarButtonItem, button.title != nil {
                button.title = nil
                let trashImage = UIImage(systemName: "trash")
                button.image = trashImage?.withRenderingMode(.alwaysTemplate)
                button.tintColor = .systemRed
            }
        } else {
            let bookmark = bookmarks[indexPath.row]
            let detailVC = BookmarkDetailViewController(bookmark: bookmark)
            detailVC.bookmarkWasChanged = handleBookmarkChange
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            let bookmark = bookmarks[indexPath.row]
            selectedBookmarks.remove(bookmark)
            if selectedBookmarks.isEmpty, let button = navigationItem.rightBarButtonItem {
                button.title = "Done"
                button.image = nil
                button.tintColor = .label
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let deletedBookmark = bookmarks.remove(at: indexPath.row)
            removedBookmarks.insert(deletedBookmark.id)
            tableView.deleteRows(at: [indexPath], with: .left)
            checkIsNeededToHideRemoveBarButton()
        default: break
        }
    }
    
    private func handleBookmarkChange(id: Bookmark.ID) {
        if let offset = bookmarks.enumerated().first(where: { $0.element.id == id } )?.offset {
            tableView.reloadRows(at: [[0, offset]], with: .none)
        }
    }
}

// MARK: - Data Source
extension BookmarkListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookmarks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BookmarkTableViewCell.identifier) as? BookmarkTableViewCell else {
            let errorDescription = "Cell do not created. \n\(bookmarks.count), \(indexPath.row)"
            fatalError(errorDescription)
        }
        let item = bookmarks[indexPath.row]
        cell.locationLabel.text = item.title ?? "Bookmark Name"
        cell.noteLabel.text = item.note
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}
