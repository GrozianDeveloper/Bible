//
//  MasterSearchViewController+SelectedBooksCollectionView.swift
//  Bible
//
//  Created by Bogdan Grozian on 14.04.2022.
//

import UIKit

extension MasterSearchViewController {
    func setupSelectedBooksCollectionView() {
        let searchController = navigationItem.searchController!
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        searchController.view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: searchController.searchBar.safeAreaLayoutGuide.bottomAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: searchController.view.safeAreaLayoutGuide.leadingAnchor, constant: 15).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: searchController.view.safeAreaLayoutGuide.trailingAnchor, constant: -15).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        collectionView.contentInset = .init(top: 0, left: 10, bottom: 0, right: 10)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TextCollectionViewCell.self, forCellWithReuseIdentifier: TextCollectionViewCell.identifier)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .secondarySystemBackground
        collectionView.layer.cornerRadius = 10
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "Footer")
        selectedBooksCollectionView = collectionView
        searchResultViewController.tableViewTopConstraint.constant = 50
        searchResultViewController.headerTopCornersCurved = false
    }
    
    func removeSelectedBooksCollectionView() {
        selectedBooksCollectionView?.removeFromSuperview()
        selectedBooksCollectionView = nil
        searchResultViewController.tableViewTopConstraint.constant = 0
        searchResultViewController.headerTopCornersCurved = true
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MasterSearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let deleteReference = UIAction(title: "Remove Book", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
            self?.booksForSearch.remove(at: indexPath.row)
            self?.updateSearchResults()
            collectionView.deleteItems(at: [indexPath])
        }
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { _ in
            let menu = UIMenu(title: "", image: nil, children: [deleteReference])
            return menu
        })
    }
}

// MARK: - UICollectionViewDataSource
extension MasterSearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return booksForSearch.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "Footer", for: indexPath)
        let button = UIButton()
        header.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.topAnchor.constraint(equalTo: header.safeAreaLayoutGuide.topAnchor).isActive = true
        button.leadingAnchor.constraint(equalTo: header.safeAreaLayoutGuide.leadingAnchor).isActive = true
        button.trailingAnchor.constraint(equalTo: header.safeAreaLayoutGuide.trailingAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: header.safeAreaLayoutGuide.bottomAnchor).isActive = true
        button.addTarget(self, action: #selector(plusButtonDidTap), for: .touchUpInside)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .link
        return header
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: 40, height: 40)
    }
    
    @objc private func plusButtonDidTap() {
        presentBookSelector()
        let names = booksForSearch.map(\.name)
        var indexes: Set<IndexPath> = []
        bookSelectorView?.dataSource.enumerated().forEach({ section in
            section.element.enumerated().forEach { name in
                if names.contains(name.element) {
                    let indexPath = IndexPath(row: name.offset, section: section.offset)
                    indexes.insert(indexPath)
                    let cell = bookSelectorView?.tableView.cellForRow(at: indexPath)
                    print(cell)
                    bookSelectorView?.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                }
            }
        })
        bookSelectorView?.viewDidApearCompletion = { [weak self] in
            indexes.forEach {
                self?.bookSelectorView?.tableView.selectRow(at: $0, animated: false, scrollPosition: .none)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextCollectionViewCell.identifier, for: indexPath) as? TextCollectionViewCell else {
            fatalError()
        }
        cell.label.text = booksForSearch[indexPath.row].name
        if booksForSearch.indices.contains(indexPath.row + 1) {
            cell.label.text? += ","
        }
        cell.label.adjustsFontSizeToFitWidth = true
        cell.label.minimumScaleFactor = 0.2
        return cell
    }
}
