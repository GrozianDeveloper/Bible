//
//  BookmarkDetailViewController+TextEdeding.swift
//  Bible
//
//  Created by Bogdan Grozian on 16.03.2022.
//

import UIKit

extension BookmarkDetailViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let newRange = Range(range) {
            let string = textView.text.substring(with: newRange)
            if string.isEmpty { // adding text
                checkForCreateReference(check: text, at: range.location)
            }
        }
        return true
    }
    
    private func checkForCreateReference(check character: String, at location: Int) {
        let isMinus = character == "-"
        if isMinus || character == "+" {
            // check previous character
            let nsRange = NSRange(location: location - 1, length: 1)
            guard textView.text.hasRange(nsRange), let previousCharacterRange = Range(nsRange) else { return }
            let previousCharacter = textView.text.substring(with: previousCharacterRange)
            if previousCharacter == "v" || previousCharacter == "V" {
                textView.text.deleteCharactersInRange(nsRange)
                commandAtLocation = location
                executingCommand = isMinus ? .reference : .referenceWith
                textView.endEditing(true)
                presentSelector()
            }
        } else if verseSelectorView != nil {
            removeVerseSelector()
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return verseSelectorView == nil
    }
}

extension BookmarkDetailViewController: BibleNavigatorDelegate {
    func didSelectVerse(book: Book, chapterOffset: Int, row: Int) {
        removeVerseSelector()
        if let location = commandAtLocation {
            let range = NSRange(location: location - 2, length: 1)
            if textView.text.hasRange(range), let range = Range(range) {
                let previousCharacter = textView.text.substring(with: range)
                if previousCharacter != " " && previousCharacter != "\n" {
                    let newCharacterRange = NSRange(location: location - 2, length: 1)
                    if let newRange = Range(newCharacterRange) {
                        let index = textView.text.createIndex(range: newRange)
                        textView.text.insert(" ", at: index.upperBound)
                    }
                }
            }
        }
        let verse = BibleVerse(abbrev: book.abbrev, chapterOffset: chapterOffset, row: row)
        if book.abbrev == bibleManager.activeBook?.abbrev {
            versesToActiveBook.insert(verse)
        }
        
        let referenceText = "\(book.name) \(chapterOffset + 1):\(row + 1)"

        textView.text += referenceText
        addVerseReference(verse)
        if executingCommand == .referenceWith {
            let verse = book.chapters[chapterOffset][row]
            textView.text += "\n" + verse
        }
    }
}

// MARK: - VerseSelector
private extension BookmarkDetailViewController {
    private func presentSelector() {
        verseSelectorView = BibleNavigatorViewController(type: .book, options: [
            .presentVerseSelection: true,
            .sameFrame: true,
            .popToSpecificVC: self
        ])
        let selectorView = verseSelectorView!.view!
        textView.addSubview(selectorView)
        selectorView.frame.size = CGSize(width: 200, height: 300)
        selectorView.center.x = textView.center.x
        selectorView.center.y = textView.center.y - selectorView.frame.height / 2
        addChild(verseSelectorView!)
        verseSelectorView!.didMove(toParent: self)
        verseSelectorView?.delegate = self
    }
    
    private func removeVerseSelector() {
        verseSelectorView?.willMove(toParent: nil)
        verseSelectorView?.view.removeFromSuperview()
        verseSelectorView?.removeFromParent()
        verseSelectorView = nil
    }
    
    private func addVerseReference(_ verse: BibleVerse) {
        guard !totalVerses.contains(where: {
            let abbrev = $0.abbrev == verse.abbrev
            let chapter = $0.chapterOffset == verse.chapterOffset
            let row = $0.row == verse.row
            return abbrev && chapter && row
        }) else { return }
        totalVerses.append(verse)
        let oldVerses = totalVerses
        totalVerses = []
        bibleManager.bible.forEach { book in
            let inBookVerses = oldVerses.filter { $0.abbrev == book.abbrev }.map{ $0 }
            inBookVerses.forEach {
                totalVerses.append($0)
            }
        }
        self.textForCollectionView = totalVerses.map(createTextForVerse)
        versesPresenterView.reloadData()
    }
}

// MARK: - Support
private extension BookmarkDetailViewController {
    private func addSpaceIfNeeded(at location: Int) {
        
    }
}

fileprivate extension String {
    func hasRange(_ range: NSRange) -> Bool {
        return Range(range, in: self) != nil
    }

    private func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func createIndex(range: Range<Int>) -> Range<String.Index> {
        let startIndex = index(from: range.lowerBound)
        let endIndex = index(from: range.upperBound)
        return startIndex..<endIndex
    }

    func substring(with range: Range<Int>) -> String {
        let index = createIndex(range: range)
        return String(self[index])
    }

    mutating func deleteCharactersInRange(_ range: NSRange) {
        let mutableSelf = NSMutableString(string: self)
        mutableSelf.deleteCharacters(in: range)
        self = String(mutableSelf)
    }
}
