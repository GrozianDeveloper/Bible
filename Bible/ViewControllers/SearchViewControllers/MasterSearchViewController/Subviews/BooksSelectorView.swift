//
//  BooksSelectorViewController.swift
//  Bible
//
//  Created by Bogdan Grozian on 14.03.2022.
//

import UIKit

final class BooksSelectorView: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        doneButton.layer.cornerRadius = 5
        doneButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        tableView.layer.cornerRadius = 5
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner]
    }
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var delegate: BookSelectorDelegate?
    @IBAction private func doneButtonDidTap(_ sender: Any) {
        delegate?.didTapDoneButton()
    }
    
    private let bibleManager = BibleManager.shared
    private var bible = [[Book]]()
}

// MARK: - UITableViewDelegate
extension BooksSelectorView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let book = getBookForIndex(indexPath)
        delegate?.didSelectBook(book)
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let book = getBookForIndex(indexPath)
        delegate?.didDeselectBook(book)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return bible.count
    }
}

// MARK: - UITableViewDataSource
extension BooksSelectorView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bible[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Old Testament"
        case 1:
            return "New Testament"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TextTableViewCell()
        cell.accessoryTypeWhenSelected = .checkmark
        let text: String = getBookForIndex(indexPath).name
        cell.label.text = text
        cell.label.font = .systemFont(ofSize: 20)
        return cell
    }
    
    private func getBookForIndex(_ indexPath: IndexPath) -> Book {
        return bible[indexPath.section][indexPath.row]
    }
}

// MARK: - Setup
extension BooksSelectorView {
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.contentInset.top = 15
        subscribeForNotification(#selector(bibleDidChange), name: BibleManager.bibleDidChangeNotification)
        bibleDidChange()
    }
    
    @objc private func bibleDidChange() {
        bible = [bibleManager.oldTestament, bibleManager.newTestament]
        tableView.reloadData()
    }
}
protocol BookSelectorDelegate {
    func didSelectBook(_ book: Book)
    func didDeselectBook(_ book: Book)
    func didTapDoneButton()
}
