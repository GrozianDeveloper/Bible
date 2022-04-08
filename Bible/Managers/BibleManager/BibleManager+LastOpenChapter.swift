//
//  BibleManager+LastOpenChapter.swift
//  Bible
//
//  Created by Bogdan Grozian on 06.04.2022.
//

import Foundation

// MARK: - Last Opened Chapter
extension BibleManager {
    func getLastOpenedChapterOffset() -> Int {
        return UserDefaults.standard.integer(forKey: UserDefaultsKey.lastOpenedChapter)
    }

    func setLastOpenedChapter(offset: Int) {
        UserDefaults.standard.set(offset, forKey: UserDefaultsKey.lastOpenedChapter)
    }
}
