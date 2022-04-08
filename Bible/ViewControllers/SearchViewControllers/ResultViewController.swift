//
//  ResultViewController.swift
//  Bible
//
//  Created by Bogdan Grozian on 04.03.2022.
//

import UIKit


final class SearchResultViewController: UITableViewController {
    
    private var previousResults: [SearchResultItem] = []
    var delegate: SearchResultHandler?
    var results: [SearchResultItem] = [] {
        willSet {
            previousResults = results
        }
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.tableView.reloadData()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(TextTableViewCell.self, forCellReuseIdentifier: TextTableViewCell.identifier)
    }
}

// MARK: - Data Source
extension SearchResultViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        results.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TextTableViewCell(components: [])
        let item = results[indexPath.row]
        cell.label.text = " \(item.bookName) \(item.chapterOffset + 1) : \(item.row + 1) \n\(item.verse)"
        return cell
    }
}

// MARK: - Delegate
extension SearchResultViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectResult(item: results[indexPath.row])
    }
}

struct SearchResultItem  {
    let bookName: String
    let abbrev: String
    let chapterOffset: Int
    let row: Int
    let verse: String
    let range: Range<String.Index>
}

protocol SearchResultHandler {
    func didSelectResult(item: SearchResultItem)
}
