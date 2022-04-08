//
//  BibleNavigatorViewController.swift
//  Bible
//
//  Created by Bogdan Grozian on 27.02.2022.
//

import UIKit

final class BibleNavigatorViewController: UIViewController {

    private var nextNavigationVC: BibleNavigatorViewController?
    private let tableView = UITableView(frame: .zero, style: .grouped)
    init(type: BibleNavigatorType, options: [NavigatorOption: Any] = [:]) {
        self.options = options
        previewType = type
        switch type {
        case .book:
            bible = [BibleManager.shared.oldTestament, BibleManager.shared.newTestament]
        case .chapter(let book):
            let chapter = "Chapter".localized(.ui)
            dataSet = (1...book.chapters.count).map { chapter + " \($0 )"}
        case .verse(let book, let chapterOffset):
            let verse = "Verse".localized(.ui)
            dataSet = (1...book.chapters[chapterOffset].count).map { "\( verse): \($0)"}
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var delegate: BibleNavigatorDelegate?
    private let previewType: BibleNavigatorType
    private let bibleManager = BibleManager.shared
    private var dataSet: [String]?
    private var bible: [[Book]]?
    private let options: [NavigatorOption: Any]
}

// MARK: Life Cycle
extension BibleNavigatorViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupTableView()
        switch previewType {
        case .book:
            title = "Select Book"
        case .chapter(let book):
            title = "\(book.name)"
        case .verse(let book, let chapterOffset):
            title = "\(book.name) \(chapterOffset + 1)"
        }
    }
}

// MARK: - UITableViewDelegate
extension BibleNavigatorViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch previewType {
        case .book:
            guard let book = bible?[indexPath.section][indexPath.row] else { return }
            nextController(.chapter(book: book), backButtonTitle: "Book")
        case .chapter(let book):
            if let bool = options[.presentVerseSelection] as? Bool, bool {
                nextController(.verse(book: book, chapterOffset: indexPath.row), backButtonTitle: "Chapter")
            } else {
                bibleManager.openViewController(self, target: .bible(abbrev: book.abbrev, chapter: indexPath.row, row: nil))
                endSelecting()
            }
        case .verse(let book, let chapterOffset):
            if delegate != nil {
                delegate?.didSelectVerse(book: book, chapterOffset: chapterOffset, row: indexPath.row)
                endSelecting()
            } else {
                bibleManager.openViewController(self, target: .bible(abbrev: book.abbrev, chapter: chapterOffset, row: indexPath.row))
                endSelecting()
            }
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        switch previewType {
        case .book:
            return 2
        default:
            return 1
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch previewType {
        case .book:
            if section == 0 {
                return "Old Testament"
            } else {
                return "New Testament"
            }
        default:
            return nil
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
}

// MARK: - UITableViewDataSource
extension BibleNavigatorViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch previewType {
        case .book:
            return bible![section].count
        default:
            return dataSet!.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TextTableViewCell()
        let text: String
        switch previewType {
        case .book:
            if let string = bible?[indexPath.section][indexPath.row].name {
                text = string
            } else {
                text = "Text"
            }
        default:
            text = dataSet?[indexPath.row] ?? "Text"
        }
        cell.label.text = text
        cell.label.font = .systemFont(ofSize: 20)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

// MARK: - Next Navigation VC
private extension BibleNavigatorViewController {
    private func endSelecting() {
        if let vc = options[.popToSpecificVC] as? UIViewController {
            navigationController?.popToViewController(vc, animated: true)
        } else {
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    private func nextController(_ type: BibleNavigatorType, backButtonTitle: String) {
        nextNavigationVC = BibleNavigatorViewController(type: type, options: options)
        nextNavigationVC!.delegate = delegate
        if let bool = options[.sameFrame] as? Bool, bool {
            let selectorView = nextNavigationVC!.view!
            let button = UIButton(frame: CGRect(origin: CGPoint(x: 5, y: 5), size: CGSize(width: 100, height: 20)))
            button.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
            button.setTitle(backButtonTitle.localized(.ui), for: .normal)
            selectorView.addSubview(button)
            view.addSubview(selectorView)
            selectorView.frame = view.bounds
            addChild(nextNavigationVC!)
            nextNavigationVC!.didMove(toParent: self)
        } else {
            let backItem = UIBarButtonItem()
            backItem.title = backButtonTitle.localized(.ui)
            navigationItem.backBarButtonItem = backItem
            navigationController?.pushViewController(nextNavigationVC!, animated: true)
        }
    }
    
    @objc private func backButtonDidTap() {
        nextNavigationVC?.willMove(toParent: nil)
        nextNavigationVC?.view.removeFromSuperview()
        nextNavigationVC?.removeFromParent()
        nextNavigationVC = nil
    }
}

// MARK: - Setup
extension BibleNavigatorViewController {
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TextTableViewCell.self, forCellReuseIdentifier: TextTableViewCell.identifier)
        tableView.separatorColor = .none
        tableView.showsVerticalScrollIndicator = false
    }
}

// MARK: Models
extension BibleNavigatorViewController {
    enum BibleNavigatorType {
        case book
        case chapter(book: Book)
        case verse(book: Book, chapterOffset: Int)
    }
    
    enum NavigatorOption: Hashable {
        case sameFrame
        case presentVerseSelection
        case popToSpecificVC
    }
}

protocol BibleNavigatorDelegate {
    func didSelectVerse(book: Book, chapterOffset: Int, row: Int)
}
