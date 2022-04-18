//
//  MapListViewController.swift
//  Bible
//
//  Created by Bogdan Grozian on 07.03.2022.
//

import UIKit

final class MapListViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.showsVerticalScrollIndicator = false
        tableView.register(TextTableViewCell.nib, forCellReuseIdentifier: TextTableViewCell.identifier)
    }
}

// MARK: - Delegate
extension MapListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mapVC = MapPreviewViewController(mapType: MapType.allCases[indexPath.row])
        navigationController?.pushViewController(mapVC, animated: true)
    }
}

// MARK: - Data Source
extension MapListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MapType.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TextTableViewCell.identifier, for: indexPath)
        if let cell = cell as? TextTableViewCell {
            cell.label.text = MapType.allCases[indexPath.row].title
            cell.label.font = .systemFont(ofSize: UIFont.systemFontSize * 1.4)
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }
}

// MARK: - Models
enum MapType: Int, CaseIterable {
    case phisicalMapOfTheHolyLand
    case israilsExodusFromEgyptAndEntryIntoCananan
    case divisionOf12Tribes
    case empiteOfDavidAndSolomon
    case assyrianEmpire
    case babylonianAndEgypt
    case persian
    case roman
    case oldTestament
    case canaanInOldTestamentTimes
    case holeLandNewTestamentTimes
    case jerusalemJesusTime
    case paulsJourneys
    case holeLandElevations
    
    var additionalInfoFileName: String? {
        switch self {
        case .canaanInOldTestamentTimes, .israilsExodusFromEgyptAndEntryIntoCananan, .jerusalemJesusTime, .holeLandNewTestamentTimes, .paulsJourneys, .oldTestament:
            return self.title
        default:
            return nil
        }
    }
    
    var title: String {
        switch self {
        case .phisicalMapOfTheHolyLand:
            return "Physical map of the holy land"
        case .israilsExodusFromEgyptAndEntryIntoCananan:
            return "Israils exodus from Egypt and entry into Cananan"
        case .divisionOf12Tribes:
            return "The division of the 12 tribes"
        case .empiteOfDavidAndSolomon:
            return "The empire of David and Solomon"
        case .assyrianEmpire:
            return "The Assyrian empire"
        case .babylonianAndEgypt:
            return "The new Babylonian empire and the kingdom of Egypt"
        case .persian:
            return "The Persian empire"
        case .roman:
            return "The Roman empire"
        case .oldTestament:
            return "The world of the old testament"
        case .canaanInOldTestamentTimes:
            return "Canaan in old testament times"
        case .holeLandNewTestamentTimes:
            return "The hole land in new testament times"
        case .jerusalemJesusTime:
            return "Jerusalem at the time of Jesus"
        case .paulsJourneys:
            return "The missionary journey of the apostole Paul"
        case .holeLandElevations:
            return "Holy land elevations"
        }
    }
    var site: URL {
        let lang: String = {
            switch BibleManager.shared.bibleVersion {
            case .kingJamesVersion:
                return "eng"
            case .Synodal:
                return "rus"
            }
        }()
        var string: String = "https://abn.churchofjesuschrist.org/study/scriptures/bible-maps"
        string.append(contentsOf: "/map-\(self.rawValue + 1)")
        string.append(contentsOf: "?lang=\(lang)")
        let url = URL(string: string)
        return url!
    }

    var imageName: String {
        switch self {
        case .phisicalMapOfTheHolyLand:
            return "PhisicalMapOfTheHolyLand"
        case .israilsExodusFromEgyptAndEntryIntoCananan:
            return "ISRAEL’S EXODUS FROM EGYPT AND ENTRY INTO CANAAN"
        case .divisionOf12Tribes:
            return "THE DIVISION OF THE 12 TRIBES"
        case .empiteOfDavidAndSolomon:
            return "THE EMPIRE OF DAVID AND SOLOMON"
        case .assyrianEmpire:
            return "THE ASSYRIAN EMPIRE"
        case .babylonianAndEgypt:
            return "THE NEW BABYLONIAN EMPIRE AND THE KINGDOM OF EGYPT"
        case .persian:
            return "THE PERSIAN EMPIRE"
        case .roman:
            return "THE ROMAN EMPIRE"
        case .oldTestament:
            return "THE WORLD OF THE OLD TESTAMENT"
        case .canaanInOldTestamentTimes:
            return "CANAAN IN OLD TESTAMENT TIMES"
        case .holeLandNewTestamentTimes:
            return "THE HOLY LAND IN NEW TESTAMENT TIMES"
        case .jerusalemJesusTime:
            return "JERUSALEM AT THE TIME OF JESUS"
        case .paulsJourneys:
            return "THE MISSIONARY JOURNEYS OF THE APOSTLE PAUL"
        case .holeLandElevations:
            return "HOLY LAND ELEVATIONS"
        }
    }
}
