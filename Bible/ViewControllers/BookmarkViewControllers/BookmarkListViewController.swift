//
//  BookmarkViewController.swift
//  Bible
//
//  Created by Bogdan Grozian on 03.03.2022.
//

import UIKit

final class BookmarkListViewController: UITableViewController {
    
    /// Used for opening bookmark with it's ObjectIdentifier (bookmark.id)
    static let openBookmarkUserDefaultsKey = "openBookmark"
    
    let bibleManager = BibleManager.shared
    var bookmarks: [Bookmark] = []
    var removedBookmarks: Set<ObjectIdentifier> = []
    var selectedBookmarks: Set<Bookmark> = []
}
