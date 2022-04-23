//
//  String.swift
//  Bible
//
//  Created by Bogdan Grozian on 08.03.2022.
//

import Foundation
import UIKit

extension String {
    func localized(_ type: LocalizationType = .bible) -> String {
        let bundle = type == .bible ? BibleManager.shared.localizationBundle! : .main
        return NSLocalizedString(self, tableName: type.rawValue, bundle: bundle, value: self, comment: "")
    }
    
    enum LocalizationType: String {
        case ui = "UILocolization"
        case bible = "Bible"
    }
}
