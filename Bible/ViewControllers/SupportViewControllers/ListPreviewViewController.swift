//
//  ItemSelectorView.swift
//  Bible
//
//  Created by Bogdan Grozian on 17.04.2022.
//

import UIKit

class ListPreviewViewController: UIViewController {
    
    var dataSource: [[String]] = []
    var sectionTitles: [String?]? = nil

    init(dataSoruce: [[String]] = [], sectionTitles: [String?]? = nil, tableViewStyle: UITableView.Style = .insetGrouped) {
        tableView = UITableView(frame: .zero, style: tableViewStyle)
        self.dataSource = dataSoruce
        self.sectionTitles = sectionTitles
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("ItemSelectorViewController do not created for being main controller")
    }

    let tableView: UITableView
    var simpleDidSelectItemAt: ((IndexPath) -> ())?
}

// MARK: - Life Cycle
extension ListPreviewViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.register(TextTableViewCell.nib, forCellReuseIdentifier: TextTableViewCell.identifier)
        tableView.separatorColor = .none
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension ListPreviewViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        simpleDidSelectItemAt?(indexPath)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title: String? = nil
        if let bool = sectionTitles?.indices.contains(section), bool {
            title = sectionTitles?[section]
        }
        return title
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    }
}

extension ListPreviewViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        dataSource.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TextTableViewCell.identifier, for: indexPath)
        if let cell = cell as? TextTableViewCell {
            cell.label.text = dataSource[indexPath.section][indexPath.row]
        }
        return cell
    }
}

