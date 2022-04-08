//
//  Nibable.swift
//  Bible
//
//  Created by Bogdan Grozian on 01.03.2022.
//

import UIKit.UINib

protocol Nibable: NSObject {
    static var identifier: String { get }
    static var nib: UINib? { get }
}

extension Nibable {
    static func getIdentifier() -> String {
        var identifier = Self.description()
        identifier.forEach { _ in
            if identifier.contains(".") { identifier.removeFirst() }
        }
        return identifier
    }

    static var identifier: String {
        return getIdentifier()
    }

    static var nib: UINib? {
        return UINib(nibName: identifier, bundle: Bundle.main)
    }
}

