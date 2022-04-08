//
//  BookmarkDetailViewController+Export.swift
//  Bible
//
//  Created by Bogdan Grozian on 03.04.2022.
//

import UIKit

extension BookmarkDetailViewController {
    func createPDF(title: String) -> Data {
        // Create PDF
        let pdfMetaData = [
            kCGPDFContextCreator: "Bible",
            kCGPDFContextTitle: title
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        // Size
        // US
//        let pageWidth = 8.5 * 72.0
//        let pageHeight = 11 * 72.0
//        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        // Europe
        let pageRect = CGRect(x: 0, y: 0, width: 595.276, height: 841.89)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        // Bookmark Note
        let data = renderer.pdfData { (context) in
            // 5
            context.beginPage()
            // 6
            let titleBottom = addTitle(title: title, pageRect: pageRect)
            addBodyText(pageRect: pageRect, textTop: titleBottom + 14)
        }
        
        return data
    }
}

// MARK: PDF Export Support
extension BookmarkDetailViewController {
    /// Add title to pdf context and returns its bottom Y
    /// - Returns: Title maxY
    private func addTitle(title: String, pageRect: CGRect) -> CGFloat {
        let fontSize = bibleManager.font.pointSize + 6
        let titleFont = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        let titleAttributes: [NSAttributedString.Key: Any] =
          [NSAttributedString.Key.font: titleFont]
        let attributedTitle = NSAttributedString(string: title, attributes: titleAttributes)
        let titleStringSize = attributedTitle.size()
        let titleStringRect = CGRect(
            x: (pageRect.width - titleStringSize.width) / 2.0,
            y: 36,
            width: titleStringSize.width,
            height: titleStringSize.height)
        // add to context
        attributedTitle.draw(in: titleStringRect)
        return titleStringRect.origin.y + titleStringRect.size.height
    }
    
    private func addBodyText(pageRect: CGRect, textTop: CGFloat) {
        let textFont = bibleManager.font
        // 2
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .natural
        paragraphStyle.lineBreakMode = .byWordWrapping
        // 3
        let textAttributes = [
          NSAttributedString.Key.paragraphStyle: paragraphStyle,
          NSAttributedString.Key.font: textFont
        ]
        let noteText = NSMutableAttributedString(attributedString: textView.attributedText)
        let textRange = NSRange(noteText.string) ?? NSRange(location: 0, length: noteText.length)
        noteText.addAttributes(textAttributes, range: textRange)
        // 4
        let textRect = CGRect(x: 10, y: textTop, width: pageRect.width - 20,
                              height: pageRect.height - textTop - pageRect.height / 5.0)
        noteText.draw(in: textRect)
    }
}
// MARK: Get
extension BookmarkDetailViewController {
    func getCurrentBookmarkTitle(checkBookmarkTitle: Bool = false) -> String {
        let bookmarkTitle: String
        if let textField = navigationItem.titleView as? UITextField, let text = textField.text, !text.isEmpty{
                bookmarkTitle = text
        } else if checkBookmarkTitle, let title = bookmark.title, !title.isEmpty {
            bookmarkTitle = title
        } else {
            let date = Date()
            let formater = DateFormatter()
            formater.dateFormat = "MMM d"
            bookmarkTitle = "Created: " + formater.string(from: date)
        }
        return bookmarkTitle
    }
    
    func getDocumentURL() -> URL {
        let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return docURL[0]
    }
}
