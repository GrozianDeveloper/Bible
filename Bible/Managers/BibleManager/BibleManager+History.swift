//
//  BibleManager+History.swift
//  Bible
//
//  Created by Bogdan Grozian on 06.04.2022.
//

import Foundation

extension BibleManager {
    func addChaptersToHistory(items: [BibleHistoryItem]) {
        guard !items.isEmpty else { return }
        var newHistory: [BibleHistoryItem] = items.reversed()
        newHistory += getHistory()
        while newHistory.count > 100 {
            newHistory.removeLast()
        }
        newHistory.removeDuplicateInSequence()
        // save
        let encoder = JSONEncoder()
        let data = try? encoder.encode(newHistory)
        userDefaults.set(data, forKey: UserDefaultsKey.readingHistory)
        garanteeMainThread {
            postNotification(BibleManager.historyDidChangeNotification)
        }
    }

    func getHistory() -> [BibleHistoryItem] {
        guard let encodedData = userDefaults.data(forKey: UserDefaultsKey.readingHistory) else { return [] }
        let decoder = JSONDecoder()
        let history = try? decoder.decode([BibleHistoryItem].self, from: encodedData)
        return history ?? []
    }
    
    func removeHistory() {
        userDefaults.removeObject(forKey: UserDefaultsKey.readingHistory)
        garanteeMainThread {
            postNotification(BibleManager.historyDidChangeNotification)
        }
    }
}
