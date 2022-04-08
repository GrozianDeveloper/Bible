//
//  String.swift
//  Bible
//
//  Created by Bogdan Grozian on 08.03.2022.
//

import Foundation

extension String {
    func localized(_ type: LocalizationType = .bible) -> String {
        return NSLocalizedString(self, tableName: type.rawValue, bundle: BibleManager.shared.localizationBundle, value: self, comment: "")
    }
    
    enum LocalizationType: String {
        case ui = "UILocolization"
        case bible = "Bible"
    }
}
