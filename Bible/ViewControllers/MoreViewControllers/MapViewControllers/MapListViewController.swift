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
        tableView.register(TextTableViewCell.self, forCellReuseIdentifier: TextTableViewCell.identifier)
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
        let cell = TextTableViewCell(components: [.leftLabel])
        cell.leftLabel?.text = MapType.allCases[indexPath.row].rawValue
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

// MARK: - Models
enum MapType: String, CaseIterable {
    case phisicalMapOfTheHolyLand = "Physical map of the holy land"
    case israilsExodusFromEgyptAndEntryIntoCananan = "Israils exodus from Egypt and entry into Cananan"
    case divisionOf12Tribes = "The division of the 12 tribes"
    case empiteOfDavidAndSolomon = "The empire of David and Solomon"
    case assyrianEmpire = "The Assyrian empire"
    case babylonianAndEgypt = "The new Babylonian empire and the kingdom of Egypt"
    case persian = "The Persian empire"
    case roman = "The Roman empire"
    case oldTestament = "The world of the old testament"
    case canaanInOldTestamentTimes = "Canaan in old testament times"
    case holeLandNewTestamentTimes = "THE HOLY LAND IN NEW TESTAMENT TIMES"
    case jerusalemJesusTime = "Jerusalem at the time of Jesus"
    case paulsJourneys = "The missionary journey of the apostole Paul"
    case holeLandElevations = "Holy land elevations"
    
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
