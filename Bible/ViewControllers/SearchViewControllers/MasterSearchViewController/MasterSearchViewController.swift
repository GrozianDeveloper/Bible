//
//  SearchViewController.swift
//  Bible
//
//  Created by Bogdan Grozian on 04.03.2022.
//

import UIKit

final class MasterSearchViewController: UIViewController {
    
    private lazy var searchViewController = UISearchController(searchResultsController: searchResultViewController)
    private let searchResultViewController = SearchResultViewController()
    private let bibleManager = BibleManager.shared
    private var booksForSearch = [Book]()
    
    private var bookSelectorView: BooksSelectorView? = nil
    
    @objc private func endSelectingButtonDidTap() {
        removeSelectionView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchViewController()
        subscribeForNotification(#selector(setupBible), name: BibleManager.bibleDidChangeNotification)
        setupBible()
    }

    
    private var searchType: SearchBookType = .bible {
        willSet {
            if searchType == .custom, newValue != .custom {
                removeSelectionView()
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
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if searchType == .custom {
            setupSelectionView()
        }
    }
}

// MARK: - Search in bible && SearchResultHandler
extension MasterSearchViewController: SearchResultHandler {
    /// Get text from searchVC.searchBar and searching in booksForSearch
    private func updateSearchResults() {
        guard let text = searchViewController.searchBar.text, text != "" else { return }
        let lText = text.lowercased()
        var results = [SearchResultItem]()
        booksForSearch.forEach { book in
            book.chapters.enumerated().forEach { chapter in
                chapter.element.enumerated().forEach { row in
                    if let range = row.element.lowercased().range(of: lText) {
                        let item = SearchResultItem(bookName: book.name, abbrev: book.abbrev, chapterOffset: chapter.offset, row: row.offset, verse: row.element, range: range)
                        results.append(item)
                    }
                }
            }
        }
        searchResultViewController.results = results
    }

    func didSelectResult(item: SearchResultItem) {
        let bibleManager = BibleManager.shared
        bibleManager.openViewController(self, target: .bible(abbrev: item.abbrev, chapter: item.chapterOffset, row: item.row))
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
        searchViewController.searchBar.scopeButtonTitles = ["Bible", "Old Testament", "New Testament", "Select Books"]
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
            setupSelectionView()
        }
    }
}

// MARK: - SelectionView
extension MasterSearchViewController: BookSelectorDelegate {
    func didSelectBook(_ book: Book) {
        var oldBooksSequence = Set(booksForSearch)
        oldBooksSequence.insert(book)
        booksForSearch = []
        bibleManager.bible.forEach { bibleBook in
            if oldBooksSequence.contains(bibleBook) {
                booksForSearch.append(bibleBook)
            }
        }
        updateSearchResults()
    }
    
    func didDeselectBook(_ book: Book) {
        if booksForSearch.contains(book), let index = booksForSearch.enumerated().first(where: { $0 .element == book } )?.offset {
            booksForSearch.remove(at: index)
        }
        updateSearchResults()
    }
    
    func didTapDoneButton() {
        removeSelectionView()
    }
    
    private func setupSelectionView() {
        guard bookSelectorView == nil else { return }
        let controller = BooksSelectorView(nibName: "BooksSelectorView", bundle: nil)
        self.bookSelectorView = controller
        let selectorView = controller.view!
        searchViewController.view.addSubview(selectorView)
        selectorView.translatesAutoresizingMaskIntoConstraints = false
        selectorView.topAnchor.constraint(equalTo: searchViewController.view.safeAreaLayoutGuide.topAnchor).isActive = true
        selectorView.backgroundColor = .clear
        selectorView.trailingAnchor.constraint(equalTo: searchViewController.view.safeAreaLayoutGuide.trailingAnchor, constant: -5).isActive = true
        selectorView.widthAnchor.constraint(equalToConstant: 240).isActive = true
        selectorView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        let mask = UIImageView(image: UIImage(named: "bookSelectorStroke"))
        mask.frame = CGRect(origin: .zero, size: CGSize(width: 240, height: 300))
//        selectorView.mask = mask
        selectorView.addSubview(mask)
        controller.delegate = self
        searchViewController.addChild(controller)
        controller.didMove(toParent: self)
    }
    
    private func removeSelectionView() {
        bookSelectorView?.willMove(toParent: nil)
        bookSelectorView?.view.removeFromSuperview()
        bookSelectorView?.removeFromParent()
        bookSelectorView = nil
    }
}

// MARK: - Models
private extension MasterSearchViewController {
    private enum SearchBookType: Int {
        case bible
        case old
        case new
        case custom
    }
}
