//
//  RemoveDuplicateInSequence.swift
//  Bible
//
//  Created by Bogdan Grozian on 02.03.2022.
//

import Foundation

extension Array {
    mutating func removeDuplicateInSequence() where Self.Element: Equatable {
        self = self.enumerated().compactMap { item -> Element? in
            if self.indices.contains(item.offset + 1) {
                let nextItem = self[item.offset + 1]
                if item.element == nextItem {
                    return nil
                } else {
                    return item.element
                }
            } else {
                return item.element
            }
        }
    }
}
