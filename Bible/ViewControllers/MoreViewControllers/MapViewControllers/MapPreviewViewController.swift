//
//  MapPreviewViewController.swift
//  Bible
//
//  Created by Bogdan Grozian on 07.03.2022.
//

import UIKit
import SafariServices

final class MapPreviewViewController: UITableViewController {
    
    var mapInformation: [NSAttributedString]? 
    var sections: [Section] = [.map, .originalMapSite]
    let mapType: MapType
    init(mapType: MapType) {
        self.mapType = mapType
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        getAdditionalInfo()
        getMapInfo()
        tabBarController?.tabBar.backgroundColor = .systemBackground
        tableView.register(MapTableViewCell.nib, forCellReuseIdentifier: MapTableViewCell.identifier)
        tableView.register(TextTableViewCell.nib, forCellReuseIdentifier: TextTableViewCell.identifier)
        tableView.register(InteractiveTextTableViewCell.nib, forCellReuseIdentifier: InteractiveTextTableViewCell.identifier)
        tableView.sectionFooterHeight = 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch sections[indexPath.section] {
        case .originalMapSite:
            return 50
        default:
            return UITableView.automaticDimension
        }
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch sections[section] {
        case .originalMapSite, .additionalInfo:
            return 5
        default:
            return 0
        }
    }
}

// MARK: - Delegate
extension MapPreviewViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch sections[indexPath.section] {
        case .originalMapSite:
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            let vc = SFSafariViewController(url: mapType.site, configuration: config)
            present(vc, animated: true)
        default:
            break
        }
    }
}

// MARK: - Data Source
extension MapPreviewViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .map, .originalMapSite:
            return 1
        case .additionalInfo:
            return mapInformation?.count ?? 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch sections[indexPath.section] {
        case .map:
            cell = tableView.dequeueReusableCell(withIdentifier: MapTableViewCell.identifier, for: indexPath)
            if let cell = cell as? MapTableViewCell {
                cell.configure(image: UIImage(named: mapType.imageName))
            }
            cell.selectionStyle = .none
        case .originalMapSite:
            cell = tableView.dequeueReusableCell(withIdentifier: TextTableViewCell.identifier, for: indexPath)
            if let cell = cell as? TextTableViewCell {
                cell.label.text = "Original Map Site"
                cell.label.textAlignment = .center
            }
            cell.separatorInset = .init(top: 0, left: view.frame.width, bottom: 0, right: 0)
        case .additionalInfo:
            cell = tableView.dequeueReusableCell(withIdentifier: InteractiveTextTableViewCell.identifier, for: indexPath)
            if let cell = cell as? InteractiveTextTableViewCell {
                cell.label.attributedText = mapInformation?[indexPath.row]
                cell.label.urlDidTap = mapURLDidTap(_:)
            }
            cell.selectionStyle = .none
            cell.separatorInset = .zero
        }
        return cell
    }
    
    private func mapURLDidTap(_ url: URL) {
        let separeted = url.absoluteString.components(separatedBy: "/")
        guard var abbrev = separeted.first, separeted.indices.contains(1) else  {
             return
        }
        if abbrev.contains("+") {
            abbrev = abbrev.replacingOccurrences(of: "+", with: " ")
        }
        let book = BibleManager.shared.bible.first(where: { $0.abbrev.localized() == abbrev })!
        let chapter = Int(separeted[1])! - 1
        var verses = [Int]()
        if separeted.indices.contains(2) {
            let versesText = separeted[2]
            let separatedVersesText = versesText.components(separatedBy: "-")
            if var verse = Int(separatedVersesText[0]) {
                verse -= 1
                verses.append(verse)
            }
            if separatedVersesText.indices.contains(1) {
                if var verse = Int(separatedVersesText[1]) {
                    verse -= 1
                    verses.append(verse)
                }
            }
        }
        var message = "Do you want to go to \(book.name) \(chapter + 1)"
        if let verse = verses.first {
            message.append(":\(verse + 1)")
            if verses.indices.contains(1) {
                message.append("-\(verses[1] + 1)")
            }
        }
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let goAction = UIAlertAction(title: "Go", style: .default) { _ in
            if verses.isEmpty {
                let chapterRows = book.chapters[chapter]
                verses = Array(0...chapterRows.count - 1)
            }
            BibleManager.shared.openViewController(self, target: .bibleWithBook(book: book, chapter: chapter, rows: verses))
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(goAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
}

// MARK: - Map Info
extension MapPreviewViewController {
    private func getMapInfo() {
        guard let fileName = mapType.additionalInfoFileName else { return }
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let rowText = try decoder.decode([String].self, from: data)
                createAdditionalInfo(rowText)
                sections.append(.additionalInfo)
                tableView.insertSections([2, 0], with: .none)
                // make
            } catch {
                print("error:\(error)")
            }
        }
    }
    
    private func createAdditionalInfo(_ rowText: [String]) {
        let allAbbrevs = BibleManager.shared.bible.map { $0.abbrev.localized() }
        let attributedText = rowText.map { NSMutableAttributedString(string: $0) }
        rowText.enumerated().forEach { line in
            let startIndicesLocations = line.element.indicesOf(string: "(")
            let endIndicesLocations = line.element.indicesOf(string: ")")
            
            startIndicesLocations.enumerated().forEach { startLocation in
                if endIndicesLocations.indices.contains(startLocation.offset) {
                    let startIndex = line.element.index(line.element.startIndex, offsetBy: startLocation.element)
                    let endLocation = endIndicesLocations[startLocation.offset]
                    let endIndex = line.element.index(line.element.startIndex, offsetBy: endLocation)
                    let range = startIndex...endIndex
                    /// All references
                    let rowReferencesString = line.element[range]
                    let separatedReferences = rowReferencesString.components(separatedBy: ",")
                    let patternForOnlyChatper = #"\d+"#
                    let chapterExpression = try! NSRegularExpression(pattern: patternForOnlyChatper)
                    let patternForFirstVerse = #":\d+"#
                    let firstVerseExpression = try! NSRegularExpression(pattern: patternForFirstVerse)
                    let patternForLastVerse = #"[\p{Pd}]\d+"#
                    let lastVerseExpression = try! NSRegularExpression(pattern: patternForLastVerse)
                    separatedReferences.forEach { reference in
                        allAbbrevs.forEach { abbrev in
                            if let abbrevRange = reference.range(of: "\(abbrev) ") {
                                let wholeReferenceRange = NSRange(location: 0, length: reference.count)
                                var linkEndIndex: String.Index!
                                let chapter: Int = {
                                    var string = reference
                                    string.removeSubrange(abbrevRange)
                                    let rangeOfChapter = chapterExpression.rangeOfFirstMatch(in: string, range: NSRange(location: 0, length: string.count))
                                    let range = convertRangeToIndex(rangeOfChapter, in: string)
                                    linkEndIndex = range.upperBound
                                    let text = string[range]
                                    return Int(text) ?? 0
                                }()
                                let verses: [Int] = {
                                    var returningValue: [Int] = []
                                    let startVerseRange = firstVerseExpression.rangeOfFirstMatch(in: reference, range: wholeReferenceRange)
                                    if startVerseRange.location != NSNotFound {
                                        let minRangeIndex = convertRangeToIndex(startVerseRange, in: reference)
                                        var minString = String(reference[minRangeIndex])
                                        minString.removeFirst()
                                        let min = Int(minString)!
                                        returningValue.append(min)
                                        linkEndIndex = minRangeIndex.upperBound
                                    }
                                    let endVerseRange = lastVerseExpression.rangeOfFirstMatch(in: reference, range: wholeReferenceRange)
                                    if endVerseRange.location != NSNotFound {
                                        let maxRangeIndex = convertRangeToIndex(endVerseRange, in: reference)
                                        var maxString = String(reference[maxRangeIndex])
                                        maxString.removeFirst()
                                        let max = Int(maxString)!
                                        returningValue.append(max)
                                        linkEndIndex = maxRangeIndex.upperBound
                                    }
                                    return returningValue
                                }()
                                let linkRange: NSRange = {
                                    let linkStartLocationInReference: Int = reference.distance(from: reference.startIndex, to: abbrevRange.lowerBound)
                                    let linkStartIndexInLine = line.element.index(line.element.startIndex, offsetBy: linkStartLocationInReference)
                                    let linkText = String(reference[linkStartIndexInLine..<linkEndIndex])
                                    let indexRangeInLine = line.element.range(of: linkText)!
                                    let startLocationInLine = line.element.distance(from: line.element.startIndex, to: indexRangeInLine.lowerBound)
                                    let endLocationInLine = line.element.distance(from: line.element.startIndex, to: indexRangeInLine.upperBound)
                                    let lenght = endLocationInLine - startLocationInLine
                                    let attributeRange = NSRange(location: startLocationInLine, length: lenght)
                                    return attributeRange
                                }()
                                let attribute = createLinkAttrbiute(abbrev: abbrev, chapter: chapter, verses: verses)
                                attributedText[line.offset].addAttributes(attribute, range: linkRange)
                            }
                        }
                    }
                }
            }
        }
        mapInformation = attributedText.map { $0.copy() as! NSAttributedString }
    }
    
    private func convertIndexToInt(_ index: String.Index, in string: String) -> Int {
        return string.distance(from: string.startIndex, to: index)
    }
    private func convertRangeToIndex(_ range: NSRange, in string: String) -> Range<String.Index>{
        let startIndex = convertIntToIndex(range.lowerBound, in: string)
        let endIndex = convertIntToIndex(range.upperBound, in: string)
        return startIndex..<endIndex
    }
    private func convertIntToIndex(_ location: Int, in string: String) -> String.Index {
        return string.index(string.startIndex, offsetBy: location)
    }
    
    private func createLinkAttrbiute(abbrev: String, chapter: Int, verses: [Int]) -> [NSAttributedString.Key: Any] {
        var linkString = "\(abbrev)/\(chapter)"
        if !verses.isEmpty {
            if verses.count > 0, let min = verses.min() {
                linkString.append(contentsOf: "/\(min)")
            }
            if verses.count > 1, let max = verses.max() {
                linkString.append(contentsOf: "-\(max)")
            }
        }
        let linkAllowedString = linkString.replacingOccurrences(of: " ", with: "+")
        let link = URL(string: linkAllowedString)
        let attribute: [NSAttributedString.Key: Any] = [.link: link as Any]
        return attribute
    }

    enum Section: CaseIterable {
        case map
        case originalMapSite
        case additionalInfo
    }
}

fileprivate extension String {
    func indicesOf(string: String) -> [Int] {
        var indices = [Int]()
        var searchStartIndex = self.startIndex
        while searchStartIndex < self.endIndex,
            let range = self.range(of: string, range: searchStartIndex..<self.endIndex),
            !range.isEmpty {
            let index = distance(from: self.startIndex, to: range.lowerBound)
            indices.append(index)
            searchStartIndex = range.upperBound
        }
        return indices
    }
}
