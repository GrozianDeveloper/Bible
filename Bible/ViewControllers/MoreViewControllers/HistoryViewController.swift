//
//  HistoryViewController.swift
//  Bible
//
//  Created by Bogdan Grozian on 01.03.2022.
//

import UIKit

final class HistoryViewController: UITableViewController {
    
    private var history: [BibleHistoryItem] = BibleManager.shared.getHistory() {
        didSet {
            tableView.reloadData()
        }
    }

    let bibleManager = BibleManager.shared
}

// MARK: Life Cycle
extension HistoryViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNotifications()
    }
}

// MARK: - Delegate
extension HistoryViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = history[indexPath.row]
        let book = findBookByAbbrev(item.abbrev)
        let name = book?.name ?? "Do not remeber name"

        let laterAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
        let goAction = UIAlertAction(title: "Go".localized(), style: .default) { [weak self] _ in
            self?.bibleManager.openViewController(self, target: .bibleWithAbbrev(abbrev: item.abbrev, chapter: item.chapterOffset, rows: nil))
        }
        let alertController = UIAlertController(title: nil, message:  "Do you want to go at \(name) \(item.chapterOffset + 1)", preferredStyle: .alert)
        alertController.addAction(laterAction)
        alertController.addAction(goAction)
        UIView.animate(withDuration: 0.1) { [weak self] in
            self?.present(alertController, animated: true, completion: nil)
        }
    }
}

// MARK: - Data Source
extension HistoryViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)
        let item = history[indexPath.row]
        let bookName = findBookByAbbrev(item.abbrev)?.name ?? "Do not remember name"
        let leftLabel = cell.viewWithTag(1) as? UILabel
        leftLabel?.text = item.creationDate
        let mainLabel = cell.viewWithTag(2) as? UILabel
        mainLabel?.text = " \(bookName) \(item.chapterOffset + 1)"
        mainLabel?.textAlignment = .center
        mainLabel?.font = .systemFont(ofSize: 20)
        return cell
    }
}

// MARK: Setup
private extension HistoryViewController  {
    private func setupTableView() {
        tableView.register(TextTableViewCell.nib, forCellReuseIdentifier: TextTableViewCell.identifier)
        tableView.separatorStyle = .none
    }
    
    private func setupNotifications() {
        subscribeForNotification(#selector(historyDidChange), name: BibleManager.historyDidChangeNotification)
    }
}

// MARK: Support
private extension HistoryViewController {
    private func findBookByAbbrev(_ abbrev: String) -> Book? {
        return bibleManager.bible.first(where: { $0.abbrev == abbrev })
    }

    @objc private func historyDidChange() {
        history = BibleManager.shared.getHistory()
    }
}
