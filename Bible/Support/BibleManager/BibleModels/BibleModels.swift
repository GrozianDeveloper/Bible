//
//  Models.swift
//  Bible
//
//  Created by Bogdan Grozian on 26.09.2021.
//

import Foundation

final class BibleHistoryItem: Codable, Equatable {
    init(abbrev: String, chapterOffset: Int) {
        self.abbrev = abbrev
        self.chapterOffset = chapterOffset

        let date = Date()
        let formater = DateFormatter()
        formater.dateFormat = "d MMM H:MM"
        creationDate = formater.string(from: date)
    }

    var abbrev: String
    var chapterOffset: Int
    let creationDate: String

    static func == (lhs: BibleHistoryItem, rhs: BibleHistoryItem) -> Bool {
        return lhs.abbrev == rhs.abbrev && lhs.chapterOffset == rhs.chapterOffset
    }
}

struct Book: Codable, Equatable, Hashable {
    let abbrev: String
    let name: String
    let chapters: [[String]]

    private init() {
        self.abbrev = ""
        self.name = ""
        self.chapters = [[""]]
    }

    init(from decoder: Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            abbrev = try container.decode(String.self, forKey: CodingKeys.abbrev)
            chapters = try container.decode([[String]].self, forKey: CodingKeys.chapters)
            let name = try container.decode(String.self, forKey: CodingKeys.name)
            self.name = name.localized()
        }
        catch {
            fatalError()
        }
    }
    static func ==(lhs: Book, rhs: Book) -> Bool {
        return lhs.name == rhs.name
    }
}

enum BibleVersion: String, CaseIterable {
    /// English
    case kingJamesVersion = "en"
    /// Russian
    case Synodal = "ru"

    var title: String {
        switch self {
        case .kingJamesVersion: return "King James Version"
        case .Synodal: return "Синодальный"
        }
    }
}
