//
//  BibleNavigatiorViewController2.swift
//  Bible
//
//  Created by Bogdan Grozian on 17.04.2022.
//

import UIKit

final class BibleNavigatorViewController: ListPreviewViewController {
    private let navigationOptions: Set<NavigationOption>
    private let navigationType: NavigationType
    private let controllerToPop: UIViewController?

    private let bibleManager = BibleManager.shared
    init(type: NavigationType, options: Set<NavigationOption> = [], popToSpeficController: UIViewController? = nil) {
        controllerToPop = popToSpeficController
        self.navigationOptions = options
        self.navigationType = type
        let bibleManager = BibleManager.shared
        let dataSource: [[String]]
        let sectionTitles: [String?]?
        switch type {
        case .book:
            let newTestament = bibleManager.newTestament.map(\.name)
            let oldTestament = bibleManager.oldTestament.map(\.name)
            dataSource = [oldTestament, newTestament]
            sectionTitles = ["Old Testament", "New Testament"]
        case .chapter(let book):
            let chapter = "Chapter".localized(.ui)
            dataSource = [(1...book.chapters.count).map { chapter + " \($0 )"}]
            sectionTitles = nil
        case .verse(let book, let chapterOffset):
            let verse = "Verse".localized(.ui)
            dataSource = [(1...book.chapters[chapterOffset].count).map { "\( verse): \($0)"}]
            sectionTitles = nil
        }
        super.init(dataSoruce: dataSource, sectionTitles: sectionTitles)
        tableView.separatorColor = .none
    }

    required init?(coder: NSCoder) {
        fatalError("BibleNavigatorViewController2 do not supporting xib")
    }

    var delegate: BibleNavigatorDelegate? = nil
    
    private var isNowTogglingTestament = false
    
    @objc private func doneButtonDidTap() {
        delegate?.doneButtonDidTap()
    }
    
    var viewDidApearCompletion: (() -> ())?
}

// MARK: Life Cycle
extension BibleNavigatorViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemGroupedBackground
        setupTableView()
        setupTestamentToggleBarButton()
        setupControllerTitle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewDidApearCompletion?()
    }
}

// MARK: Testament Bar Button
extension BibleNavigatorViewController {
    private func setupTestamentToggleBarButton() {
        let barButton = UIBarButtonItem(title: "Old", style: .plain, target: self, action: #selector(testamentToggleDidTap))
        navigationItem.setRightBarButton(barButton, animated: true)
    }

    @objc private func testamentToggleDidTap() {
        guard let title = navigationItem.rightBarButtonItem?.title else { return }
        isNowTogglingTestament = true
        if title == "Old" {
            tableView.scrollToRow(at: [1, 0], at: .top, animated: true)
            navigationItem.rightBarButtonItem?.title = "New"
        } else if title == "New" {
            tableView.scrollToRow(at: [0, 0], at: .top, animated: true)
            navigationItem.rightBarButtonItem?.title = "Old"
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard !isNowTogglingTestament, let visibleCellsIndexs = tableView.indexPathsForVisibleRows, !visibleCellsIndexs.isEmpty else { return }
        let middleIndex = Int(Double(visibleCellsIndexs.count) / 2)
        let section = visibleCellsIndexs[middleIndex].section
        if section == 0 {
            navigationItem.rightBarButtonItem?.title = "Old"
        } else  {
            navigationItem.rightBarButtonItem?.title = "New"
        }
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        isNowTogglingTestament = false
    }
}

// MARK: TableView
extension BibleNavigatorViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let cell = cell as? TextTableViewCell {
            cell.label.font = .systemFont(ofSize: UIFont.systemFontSize * 1.4)
            cell.accessoryType = .disclosureIndicator
            if navigationOptions.contains(.multipleSelection) {
                cell.selectionStyle = .blue
            }
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !tableView.allowsMultipleSelection else {
            let (book, chapter, verse) = getBibleNavigationAttributesForIndexPath(indexPath)
            if let book = book {
                delegate?.didSelect(book: book, chapterOffset: chapter, verse: verse)
            }
            return
        }
        switch navigationType {
        case .book:
            let item = dataSource[indexPath.section][indexPath.row]
            let book = bibleManager.bible.first(where: { $0.name == item })
            if let book = book {
                if navigationOptions.contains(.notPresentChapters)  {
                    delegate?.didSelect(book: book, chapterOffset: nil, verse: nil)
                    popNavigator()   
                } else {
                    nextController(.chapter(book: book), backButtonTitle: "Book")
                }
            }
        case .chapter(let book):
            if navigationOptions.contains(.presentVerses) {
                nextController(.verse(book: book, chapterOffset: indexPath.row), backButtonTitle: "Chapters")
            } else {
                delegate?.didSelect(book: book, chapterOffset: indexPath.row, verse: nil)
                popNavigator()
            }
        case .verse(let book, let chapterOffset):
            delegate?.didSelect(book: book, chapterOffset: chapterOffset, verse: indexPath.row)
        }
    }
    
    private func getBibleNavigationAttributesForIndexPath(_ indexPath: IndexPath) -> (Book?, Int?, Int?) {
        let book: Book?
        var chapter: Int?
        var verse: Int?
        switch navigationType {
        case .book:
            let item = dataSource[indexPath.section][indexPath.row]
            book = bibleManager.bible.first(where: { $0.name == item })
        case .chapter(let book1):
            book = book1
            chapter = indexPath.row
        case .verse(let book1, let chapterOffset):
            book = book1
            chapter = chapterOffset
            verse = indexPath.row
        }
        return (book, chapter, verse)
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let (book, chapter, verse) = getBibleNavigationAttributesForIndexPath(indexPath)
        if let book = book {
            delegate?.didDeselect(book: book, chapterOffset: chapter, verse: verse)
        }
    }
    
    private func popNavigator() {
        if let vc = controllerToPop {
            navigationController?.popToViewController(vc, animated: true)
        } else {
            navigationController?.popToRootViewController(animated: true)
        }
    }
}

// MARK: - Setup
private extension BibleNavigatorViewController {
    private func setupTableView() {
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .secondarySystemGroupedBackground
        if navigationOptions.contains(.multipleSelection) {
            tableView.allowsMultipleSelection = true
            tableView.allowsMultipleSelectionDuringEditing = true
            tableView.isEditing = true
        }
    }

    private func setupControllerTitle() {
        navigationItem.titleView?.backgroundColor = .clear
        switch navigationType {
        case .book:
            title = "Select Book"
            setupTestamentToggleBarButton()
        case .chapter(let book):
            title = "\(book.name)"
        case .verse(let book, let chapterOffset):
            title = "\(book.name) \(chapterOffset + 1)"
        }
        if navigationOptions.contains(.createDoneLeftBarButton) {
            let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonDidTap))
            navigationItem.setLeftBarButton(doneButton, animated: false)
        }
    }
}

// MARK: - Support
extension BibleNavigatorViewController {
    private func nextController(_ type: NavigationType, backButtonTitle: String) {
        let vc = BibleNavigatorViewController(type: type, options: navigationOptions, popToSpeficController: controllerToPop)
        vc.delegate = delegate
        let backItem = UIBarButtonItem()
        backItem.title = backButtonTitle.localized(.ui)
        navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Models
extension BibleNavigatorViewController {
    enum NavigationType {
        case book
        case chapter(book: Book)
        case verse(book: Book, chapterOffset: Int)
    }
    
    enum NavigationOption {
        case multipleSelection
        case createDoneLeftBarButton
        case notPresentChapters
        case presentVerses
    }
}

protocol BibleNavigatorDelegate {
    func didSelect(book: Book, chapterOffset: Int?, verse: Int?)
    func didDeselect(book: Book, chapterOffset: Int?, verse: Int?)
    func doneButtonDidTap()
}

extension BibleNavigatorDelegate {
    func didDeselect(book: Book, chapterOffset: Int?, verse: Int?) { }
    func doneButtonDidTap() { }
}
