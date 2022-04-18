//
//  SearchViewController.swift
//  Bible
//
//  Created by Bogdan Grozian on 04.03.2022.
//

import UIKit

final class MasterSearchViewController: UIViewController {
    
    private lazy var searchViewController = UISearchController(searchResultsController: searchResultViewController)
    let searchResultViewController = SearchResultViewController()
    let bibleManager = BibleManager.shared
    var booksForSearch = [Book]()
    var selectedBooksCollectionView: UICollectionView? = nil
    
    var bookSelectorView: BibleNavigatorViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchViewController()
        subscribeForNotification(#selector(setupBible), name: BibleManager.bibleDidChangeNotification)
        setupBible()
        searchViewController.searchBar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(searchBarDidTap)))
    }
    
    @objc private func searchBarDidTap() {
        if searchType == .custom, selectedBooksCollectionView == nil {
            setupSelectedBooksCollectionView()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchViewController.searchBar.becomeFirstResponder()
        if searchType == .custom {
            setupSelectedBooksCollectionView()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeSelectedBooksCollectionView()
    }
    
    private var searchType: SearchBookType = .bible {
        willSet {
            if searchType == .custom, newValue != .custom {
                removeSelectionView()
                removeSelectedBooksCollectionView()
            }
        }
        didSet {
            setupBooksForSearch()
        }
    }
}

// MARK: - UISearchResultsUpdating
extension MasterSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchViewController.searchBar.text, text != "" else { return }
        updateSearchResults()
    }
}

// MARK: - UISearchBarDelegate
extension MasterSearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        searchType = SearchBookType(rawValue: selectedScope) ?? .bible
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        removeSelectionView()
        removeSelectedBooksCollectionView()
    }
}

// MARK: - Search in bible && SearchResultHandler
extension MasterSearchViewController: SearchResultHandler {
    /// Get text from searchVC.searchBar and searching in booksForSearch
    func updateSearchResults() {
        guard let text = searchViewController.searchBar.text, text != "" else { return }
        let lText = text.lowercased()
        var results = [[SearchResultItem]]()
        booksForSearch.forEach { book in
            var items: [SearchResultItem] = []
            book.chapters.enumerated().forEach { chapter in
                chapter.element.enumerated().forEach { row in
                    if let range = row.element.lowercased().range(of: lText) {
                        let item = SearchResultItem(bookName: book.name, abbrev: book.abbrev, chapterOffset: chapter.offset, row: row.offset, verse: row.element, range: range)
                        items.append(item)
                    }
                }
            }
            results.append(items)
        }
        searchResultViewController.results = results
    }

    func didSelectResult(item: SearchResultItem) {
        let bibleManager = BibleManager.shared
        bibleManager.openViewController(self, target: .bibleWithAbbrev(abbrev: item.abbrev, chapter: item.chapterOffset, rows: [item.row]))
    }
}

// MARK: - Setup & Updates
extension MasterSearchViewController {
    private func setupSearchViewController() {
        searchResultViewController.delegate = self
        searchViewController.loadViewIfNeeded()
        navigationItem.searchController = searchViewController
        searchViewController.searchResultsUpdater = self
        searchViewController.searchBar.enablesReturnKeyAutomatically = false
        searchViewController.searchBar.returnKeyType = .done
        navigationItem.hidesSearchBarWhenScrolling = false
        searchViewController.searchBar.delegate = self
        searchViewController.searchBar.showsCancelButton = false
        searchViewController.searchBar.scopeButtonTitles = SearchBookType.allCases.map(\.title)
    }
    
    @objc private func setupBible() {
        switch searchType {
        case .custom:
            let abbrevs = booksForSearch.map(\.abbrev)
            booksForSearch = bibleManager.bible.filter { abbrevs.contains($0.abbrev) }
        default:
            setupBooksForSearch()
        }
    }

    private func setupBooksForSearch() {
        switch searchType {
        case .bible:
            booksForSearch = bibleManager.bible
        case .old:
            booksForSearch = bibleManager.oldTestament
        case .new:
            booksForSearch = bibleManager.newTestament
        case .custom:
            booksForSearch = []
            presentBookSelector()
            setupSelectedBooksCollectionView()
        }
    }
}

// MARK: - SelectionView
extension MasterSearchViewController: BibleNavigatorDelegate {
    func didSelect(book: Book, chapterOffset: Int?, verse: Int?) {
        booksForSearch.append(book)
        let oldBooksSequence = Set(booksForSearch)
        booksForSearch = []
        bibleManager.bible.forEach { bibleBook in
            if oldBooksSequence.contains(bibleBook) {
                booksForSearch.append(bibleBook)
            }
        }
        selectedBooksCollectionView?.reloadData()
        updateSearchResults()
    }

    func doneButtonDidTap() {
        removeSelectionView()
    }

    func didDeselect(book: Book, chapterOffset: Int?, verse: Int?) {
        if booksForSearch.contains(book), let index = booksForSearch.enumerated().first(where: { $0 .element == book } )?.offset {
            booksForSearch.remove(at: index)
            selectedBooksCollectionView?.reloadItems(at: [[0, index]])
        }
        updateSearchResults()
    }
    
    func presentBookSelector() {
        bookSelectorView = BibleNavigatorViewController(type: .book, options: [
            .multipleSelection,
            .createDoneLeftBarButton
        ])
        bookSelectorView?.delegate = self
        bookSelectorView?.isModalInPresentation = true
        let navigationController = UINavigationController(rootViewController: bookSelectorView!)
        if let presentationController = navigationController.presentationController as? UISheetPresentationController {
            presentationController.detents = [.medium()]
        }
        self.present(navigationController, animated: true)
    }
    
    private func removeSelectionView() {
        bookSelectorView?.navigationController?.dismiss(animated: true)
        bookSelectorView = nil
    }
}

// MARK: - Models
private extension MasterSearchViewController {
    private enum SearchBookType: Int, CaseIterable {
        case bible
        case old
        case new
        case custom
        
        var title: String {
            switch self {
            case .bible:
                return "Bible"
            case .old:
                return "Old Testament"
            case .new:
                return "New Testament"
            case .custom:
                return "Select Books"
            }
        }
    }
}
