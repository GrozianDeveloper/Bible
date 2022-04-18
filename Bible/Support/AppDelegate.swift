//
//  AppDelegate.swift
//  Bible
//
//  Created by Bogdan Grozian on 27.02.2022.
//

import UIKit.UIApplication
import CoreData.NSPersistentContainer

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "BibleModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                 fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        BibleManager.registerDefaults()
        BibleVersesTransformer.register()
        if !UserDefaults.standard.bool(forKey: "isSetupedFirstBibleVersion") {
            setupBibleVersion()
            UserDefaults.standard.set(true, forKey: "isSetupedFirstBibleVersion")
        }
        return true
    }
}

// MARK: Support
extension AppDelegate {
    private func setupBibleVersion() {
        var code: String? = nil
        if let language = Locale.current.languageCode {
            code = language
        } else if let language = Locale.preferredLanguages.first?.prefix(2) {
            code = String(language)
        }
        let bibleManager = BibleManager.shared
        switch code {
        case "en":
            bibleManager.setBibleVersion(.kingJamesVersion)
        case "ru":
            bibleManager.setBibleVersion(.Synodal)
        default:
            break
        }
    }
}
