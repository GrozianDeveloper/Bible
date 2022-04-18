//
//  BookmarkViewController.swift
//  Bible
//
//  Created by Bogdan Grozian on 03.03.2022.
//

import UIKit

final class BookmarkListViewController: UITableViewController {
    
    let bibleManager = BibleManager.shared
    var bookmarks: [Bookmark] = []
    var removedBookmarks: Set<ObjectIdentifier> = []
    var selectedBookmarks: Set<Bookmark> = []
}
