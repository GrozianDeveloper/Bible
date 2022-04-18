//
//  BookmarkDetailViewController+VerseCollectionVieww.swift
//  Bible
//
//  Created by Bogdan Grozian on 16.03.2022.
//

import UIKit

// MARK: - UICollectionViewDelegateFlowLayout
extension BookmarkDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let verse = totalVerses[indexPath.row]
        let bibleManager = BibleManager.shared
        bibleManager.openViewController(self, target: .bibleWithAbbrev(abbrev: verse.abbrev, chapter: verse.chapterOffset, rows: [verse.row]))
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let deleteReference = UIAction(title: "Delete reference", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
            if let verse = self?.totalVerses.remove(at: indexPath.row) {
                self?.versesToActiveBook.remove(verse)
                if self?.bibleManager.verseReferenceForActiveBookmark.contains(verse) == false {
                    
                }
                collectionView.deleteItems(at: [indexPath])
            }
        }
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { _ in
            let menu = UIMenu(title: "", image: nil, children: [deleteReference])
            return menu
        })
    }
}

// MARK: - UICollectionViewDataSource
extension BookmarkDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalVerses.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextCollectionViewCell.identifier, for: indexPath) as? TextCollectionViewCell else {
            fatalError()
        }
        cell.label.attributedText = textForCollectionView[indexPath.row]
        return cell
    }
}
