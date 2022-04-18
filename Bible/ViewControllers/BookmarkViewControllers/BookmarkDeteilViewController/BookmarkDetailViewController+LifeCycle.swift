//
//  BookmarkDetailViewController+LifeCycle.swift
//  Bible
//
//  Created by Bogdan Grozian on 03.04.2022.
//

import UIKit

// MARK: - Life Cycle
extension BookmarkDetailViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupTitleView()
        setupTextPresent()
        setupRightNavigationButtons()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        bookmark.title = getCurrentBookmarkTitle(checkBookmarkTitle: true)
        bookmark.note = textView.text
        bookmark.verses = .init(verses: totalVerses)
        if let book = bibleManager.activeBook {
            bibleManager.updateBookmarkReferencesToBook(book: book)
        }
        versesToActiveBook = []
        
        bookmarkWasChanged?(bookmark.id)
        super.viewWillDisappear(animated)
    }
}

// MARK: - Setup Navigation
extension BookmarkDetailViewController {
    private func setupTitleView() {
        let textField = UITextField()
        textField.autocorrectionType = .no
        if (bookmark.title?.isEmpty) ?? true {
            bookmark.title = "Bookmark Name"
        }
        textField.text = bookmark.title
        navigationItem.titleView = textField
    }
    
    private func setupRightNavigationButtons() {
        let guideButton = createGuideBarButton()
        let shareButton = createExportBarButton()
        navigationItem.setRightBarButtonItems([guideButton, shareButton], animated: false)
    }

    private func createGuideBarButton()  -> UIBarButtonItem {
        let referenceToVerbe = UIAction(title: "Reference to verbe", image: UIImage(systemName: "book.closed")) { [weak self] _ in
            self?.playGuideVideo(.referenceToVerbe)
        }
        let addVerbe = UIAction(title: "Add verbe", image: UIImage(systemName: "character.book.closed")) { [weak self] _ in
            self?.playGuideVideo(.addVerbe)
        }
        let guideMenu = UIMenu(title: "Guide", image: nil, children: [referenceToVerbe, addVerbe])
        let guideButton = UIBarButtonItem(image: UIImage(systemName: "questionmark"), menu: guideMenu)
        return guideButton
    }
    
    private func createExportBarButton() -> UIBarButtonItem {
        let shareImage = UIImage(systemName: "square.and.arrow.up")
        let exportAsPDF = UIAction(title: "Export as PDF", image: shareImage /*Change to pdf icon*/) { [weak self] _ in
            let title = self?.getCurrentBookmarkTitle(checkBookmarkTitle: true)
            if let title = title, let pdfData = self?.createPDF(title: title) {
                let docURL = self!.getDocumentURL()
                let pdfURL = docURL.appendingPathComponent("\(title).pdf")
                do {
                    try pdfData.write(to: pdfURL)
                    let vc = UIActivityViewController(activityItems: [pdfURL], applicationActivities: [])
                    self?.present(vc, animated: true, completion: nil)
                } catch {
                    print(error)
                }
            }
        }
        let exportASText = UIAction(title: "Export as Text", image: shareImage /*Change to txt icon*/) { [weak self] _ in
            guard let title = self?.getCurrentBookmarkTitle(checkBookmarkTitle: true),
                  let body = self?.textView.text,
                  let docURL = self?.getDocumentURL() else {
                return
            }
            let textURL = docURL.appendingPathComponent("\(title).txt")
            let textString = """
            \(title)
            \(body)
            """
            do {
                try textString.write(to: textURL, atomically: true, encoding: .utf8)
                let vc = UIActivityViewController(activityItems: [textURL], applicationActivities: [])
                self?.present(vc, animated: true, completion: nil)
            } catch {
                print(error)
            }
        }
        let shareMenu = UIMenu(title: "Export", image: nil, children: [exportAsPDF, exportASText])
        let shareButton = UIBarButtonItem(title: nil, image: shareImage, primaryAction: nil, menu: shareMenu)
        return shareButton
    }
}

// MARK: - Setup Text View
extension BookmarkDetailViewController {
    private func setupTextPresent() {
        let text = bookmark.note ?? "Text"
        textView.text = text
        updateTextViewFont()
        textView.autocorrectionType = .no
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        versesPresenterView.translatesAutoresizingMaskIntoConstraints = false
        versesPresenterView.backgroundColor = .systemGroupedBackground
        versesPresenterView.layer.cornerRadius = 15
        view.addSubview(versesPresenterView)
        NSLayoutConstraint.activate([
            versesPresenterView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            versesPresenterView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            versesPresenterView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            versesPresenterView.heightAnchor.constraint(equalToConstant: 50),

            textView.topAnchor.constraint(equalTo: versesPresenterView.safeAreaLayoutGuide.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 2),
            textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 2),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        textView.delegate = self
        versesPresenterView.delegate = self
        versesPresenterView.dataSource = self
    }
}

// MARK: - Notifications
extension BookmarkDetailViewController {
    private func setupNotifications() {
        subscribeForNotification(#selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification)
        subscribeForNotification(#selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification)
        subscribeForNotification(#selector(updateTextViewFont), name: BibleManager.fontPointSizeDidChangeNotification)
    }

    @objc private func adjustForKeyboard(notitication: Notification) {
        guard let keyboardValue = notitication.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let screenEndFrame = keyboardValue.cgRectValue
        let viewEndFrame = view.convert(screenEndFrame, to: view.window)
        let bottomInset = viewEndFrame.height - view.safeAreaInsets.bottom
        if notitication.name == UIResponder.keyboardWillHideNotification{
            textView.contentInset = .zero
        } else {
            textView.contentInset = .init(top: 0,
                                          left: 0,
                                          bottom: bottomInset,
                                          right: 0)
        }
        textView.scrollIndicatorInsets = textView.contentInset
        
        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
    }
    
    @objc private func updateTextViewFont() {
        textView.font = bibleManager.font
    }
}
