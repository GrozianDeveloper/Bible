//
//  PostNotification.swift
//  Bible
//
//  Created by Bogdan Grozian on 05.04.2022.
//

import Foundation

func postNotification(_ name: Notification.Name, object: Any? = nil) -> () {
    NotificationCenter.default.post(name: name, object: object)
}
