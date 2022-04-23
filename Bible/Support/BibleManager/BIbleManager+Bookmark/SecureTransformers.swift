//
//  ArrayStringSecureTransformer.swift
//  Bible
//
//  Created by Bogdan Grozian on 02.03.2022.
//

import CoreData


final class BibleVersesTransformer: NSSecureUnarchiveFromDataTransformer {
    override class var allowedTopLevelClasses: [AnyClass] {
        return [BibleVerses.self]
    }
    
    static func register() {
        let className = String(describing: BibleVersesTransformer.self)
        let name = NSValueTransformerName(className)
        let transformer = BibleVersesTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
