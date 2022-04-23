//
//  ResultViewController.swift
//  Bible
//
//  Created by Bogdan Grozian on 04.03.2022.
//

import UIKit


final class SearchResultViewController: UIViewController {
    
    private(set) var tableViewTopConstraint: NSLayoutConstraint!
    private let tableView = UITableView()

    var headerTopCornersCurved = true

    var delegate: SearchResultHandler?
    private var previousResults: [[SearchResultItem]] = []
    var results: [[SearchResultItem]] = [] {
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
}

// MARK: - Life Cycle
extension SearchResultViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.sectionHeaderTopPadding = 0
        tableView.separatorStyle = .none
        let left = tableView.separatorInset.left
        tableView.separatorInset = .init(top: 0, left: left, bottom: 0, right: left)
        tableView.register(TextTableViewCell.nib, forCellReuseIdentifier: TextTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableViewTopConstraint = tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        tableViewTopConstraint.isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.delegate = self
        tableView.dataSource = self
    }
}

// MARK: - UITableViewDelegate
extension SearchResultViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectResult(item: results[indexPath.section][indexPath.row])
    }
}

// MARK: - UITableViewDataSource
extension SearchResultViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let item = results[section].first else { return nil }
        let header = UIView()
        let bufferView = setupHeaderSubView(superView: header, subView: UIView())
        bufferView.clipsToBounds = true
        if headerTopCornersCurved {
            bufferView.layer.maskedCorners.insert(.layerMinXMinYCorner)
            bufferView.layer.maskedCorners.insert(.layerMaxXMinYCorner)
        } else {
            bufferView.layer.maskedCorners.remove(.layerMinXMinYCorner)
            bufferView.layer.maskedCorners.remove(.layerMaxXMinYCorner)
        }
        bufferView.layer.cornerRadius = 10
        bufferView.backgroundColor = .systemGroupedBackground
        let label = setupHeaderSubView(superView: bufferView, subView: UILabel(), verticalOffset: 5, horizontalOffset: 5) as! UILabel
        label.text = item.bookName
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        return header
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        results.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        results[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TextTableViewCell.identifier, for: indexPath)
        if let cell = cell as? TextTableViewCell {
            let item = results[indexPath.section][indexPath.row]
            cell.label.text = "\(item.chapterOffset + 1): \(item.row + 1) \n\(item.verse)"
        }
        return cell
    }
}

// MARK: - Support
extension SearchResultViewController {
    private func setupHeaderSubView(superView: UIView, subView: UIView, verticalOffset: CGFloat? = nil, horizontalOffset: CGFloat? = nil) -> UIView {
        superView.addSubview(subView)
        subView.translatesAutoresizingMaskIntoConstraints = false
        if let verticalOffset = verticalOffset {
            subView.topAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.topAnchor, constant: verticalOffset).isActive = true
            subView.bottomAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.bottomAnchor, constant: -verticalOffset).isActive = true
        } else {
            subView.centerYAnchor.constraint(equalTo: superView.centerYAnchor).isActive = true
        }
        if let horizontalOffset = horizontalOffset {
            subView.leadingAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.leadingAnchor, constant: horizontalOffset).isActive = true
            subView.trailingAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.trailingAnchor, constant: -horizontalOffset).isActive = true
        } else {
            subView.centerXAnchor.constraint(equalTo: superView.centerXAnchor).isActive = true
        }
        return subView
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
