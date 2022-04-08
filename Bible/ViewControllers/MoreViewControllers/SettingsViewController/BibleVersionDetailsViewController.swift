//
//  BibleVersionDetailsViewController.swift
//  Bible
//
//  Created by Bogdan Grozian on 01.03.2022.
//

import UIKit

final class BibleVersionDetailsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private let bibleManager = BibleManager.shared

    private var version: BibleVersion!
    private var text = [String]()

    @IBOutlet private weak var setVersionButton: UIButton!
    @IBAction private func didTapSetVersion(_ sender: UIButton) {
        guard bibleManager.bibleVersion != version else {
            return
        }
        bibleManager.setBibleVersion(version)
        sender.setTitle("Setted", for: .normal)
    }
}

// MARK: - Life Cycle
extension BibleVersionDetailsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.register(TextTableViewCell.self, forCellReuseIdentifier: TextTableViewCell.identifier)
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setVersionButton.isHidden = bibleManager.bibleVersion == version
        tableView.reloadData()
    }
}

// MARK: - Setup
extension BibleVersionDetailsViewController {
    func setup(version: BibleVersion) {
        self.version = version
        switch version {
        case .Synodal:
            break
        case .kingJamesVersion:
            break
        }
    }
}

// MARK: - UITableViewDataSource
extension BibleVersionDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return text.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TextTableViewCell(components: [])
        cell.label.text = text[indexPath.row]
        return cell
    }
}
