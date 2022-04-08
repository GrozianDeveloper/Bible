//
//  ViewControllers+SubscribeForNotifications.swift
//  Bible
//
//  Created by Bogdan Grozian on 06.04.2022.
//

import UIKit

extension UIViewController {
    func subscribeForNotification(_ selector: Selector, name: Notification.Name, object: Any? = nil) {
        NotificationCenter.default.addObserver(self, selector: selector, name: name, object: object)
    }
}
