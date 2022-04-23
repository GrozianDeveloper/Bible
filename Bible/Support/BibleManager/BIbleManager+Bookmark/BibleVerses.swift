//
//  BibleVerse.swift
//  Bible
//
//  Created by Bogdan Grozian on 06.03.2022.
//

import CoreData

final public class BibleVerse: NSObject, NSSecureCoding {
    public override var description: String {
        return "Verse \(abbrev), \(chapterOffset + 1) : \(row)"
    }
    public static var supportsSecureCoding: Bool = true
    public let abbrev: String
    public let chapterOffset: Int
    public let row: Int
    
    init(abbrev: String, chapterOffset: Int, row: Int) {
        self.abbrev = abbrev
        self.chapterOffset = chapterOffset
        self.row = row
    }
    
    public func encode(with coder: NSCoder) {
        let nsAbbrev = NSString(string: abbrev)
        coder.encode(nsAbbrev, forKey: "abbrev")
        let nsChapter = NSNumber(value: chapterOffset)
        coder.encode(nsChapter, forKey: "chapter")
        let nsRow = NSNumber(value: row)
        coder.encode(nsRow, forKey: "row")
    }
    
    public required convenience init?(coder: NSCoder) {
        guard let nsAbbrev = coder.decodeObject(of: NSString.self, forKey: "abbrev"),
                let nsChapter = coder.decodeObject(of: NSNumber.self, forKey: "chapter"),
                let nsRow = coder.decodeObject(of: NSNumber.self, forKey: "row") else { return nil }
        self.init(abbrev: String(nsAbbrev), chapterOffset: nsChapter.intValue, row: nsRow.intValue)
    }
}

final public class BibleVerses: NSObject, NSSecureCoding {
    public static var supportsSecureCoding: Bool = true
    
    public var verses: [BibleVerse] = []
    
    init(verses: [BibleVerse]) {
        self.verses = verses
        super.init()
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(verses, forKey: "verses")
    }
    
    public required convenience init?(coder: NSCoder) {
        guard let verses = coder.decodeObject(of: [NSArray.self, BibleVerse.self], forKey: "verses") as? [BibleVerse]
        else { return nil }
        self.init(verses: verses)
    }
}
