//
//  SettingsViewController.swift
//  Bible
//
//  Created by Bogdan Grozian on 01.03.2022.
//

import UIKit

final class SettingsViewController: UITableViewController {
    
    private let sections = SettingType.allCases
    private let bibleVersions = BibleVersion.allCases
    private let fontSettings = FontSettingType.allCases
    private let simpleSettings = BibleManager.SwitchableSettings.allCases
    
    private let bibleManager = BibleManager.shared
    
    private var cellTextPreviewer: TextTableViewCell?
    private var textPreviewerText = BibleManager.shared.bible[0].chapters[0][0]
    private var currentPointSize = BibleManager.shared.font.pointSize
}

// MARK: Life Cycle
extension SettingsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(TextTableViewCell.nib, forCellReuseIdentifier: TextTableViewCell.identifier)
        tableView.register(SliderTableViewCell.nib, forCellReuseIdentifier: SliderTableViewCell.identifier)
        tableView.register(ToggleTableViewCell.nib, forCellReuseIdentifier: ToggleTableViewCell.identifier)
        subscribeForNotification(#selector(updateTextPreviewerText), name: BibleManager.bibleDidChangeNotification)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        BibleManager.shared.setBibleFont(pointSize: currentPointSize)
    }
}

// MARK: - Delegate
extension SettingsViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch sections[indexPath.section] {
        case .bibleVersion:
            let previousVersion = bibleManager.bibleVersion
            bibleManager.setBibleVersion(bibleVersions[indexPath.row])
            if let offset = bibleVersions.enumerated().first(where: { $0.element == previousVersion })?.offset {
                tableView.reloadRows(at: [indexPath, [indexPath.section, offset]], with: .none)
            } else {
                tableView.reloadSections([indexPath.section], with: .none)
            }
        default:
            break
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch sections[indexPath.section] {
        case .simpleSettings:
            return UITableView.automaticDimension
        case .font:
            switch fontSettings[indexPath.row] {
            case .textPresenter:
                return 40
            case .slider:
                return 40
            }
        case .bibleVersion:
            return 40
        }
    }
}

// MARK: - Data Source
extension SettingsViewController {
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch sections[indexPath.section] {
        case .simpleSettings:
            cell = tableView.dequeueReusableCell(withIdentifier: ToggleTableViewCell.identifier, for: indexPath)
            if let cell = cell as? ToggleTableViewCell {
                let item = simpleSettings[indexPath.row]
                cell.label.text = item.title
                cell.cellIndex = indexPath
                if let key = item.userDefaultKey {
                    cell.switchToggle.isOn = UserDefaults.standard.bool(forKey: key)
                }
                cell.valueChanged = handleSimpleSettignsValueChanged(for:_:)
            }
        case .font:
            switch fontSettings[indexPath.row] {
            case .textPresenter:
                cell = tableView.dequeueReusableCell(withIdentifier: TextTableViewCell.identifier, for: indexPath)
                if let cell = cell as? TextTableViewCell {
                    cellTextPreviewer = cell
                    cell.label.font = .systemFont(ofSize: currentPointSize)
                    cell.label.text = "\(Int(round(currentPointSize))) " + textPreviewerText
                    cell.label.numberOfLines = 1
                }
            case .slider:
                cell = tableView.dequeueReusableCell(withIdentifier: SliderTableViewCell.identifier, for: indexPath)
                if let cell = cell as? SliderTableViewCell {
                    cell.slider.minimumValue = 14
                    cell.slider.maximumValue = 33
                    let stepedValue = cell.calculateStepSliderValue(Float(currentPointSize))
                    cell.slider.value = stepedValue
                    cell.valueDidChange = updateTextPreviewerFont(point:)
                }
            }
            cell.separatorInset = .init(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
        case .bibleVersion:
            cell = tableView.dequeueReusableCell(withIdentifier: "LabelAndRightImageCell", for: indexPath)
            cell.separatorInset = .init(top: 0, left: 15, bottom: 0, right: 15)

            let label = cell.viewWithTag(1) as? UILabel
            label?.text = bibleVersions[indexPath.row].title

            let imageView = cell.viewWithTag(2) as? UIImageView
            imageView?.image = BibleManager.shared.bibleVersion == bibleVersions[indexPath.row] ? UIImage(systemName: "circle.fill") : nil
        }
        cell.selectionStyle = .none
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .simpleSettings:
            return simpleSettings.count
        case .font:
            return fontSettings.count
        case .bibleVersion:
            return bibleVersions.count
        }
    }
}

// MARK: Support
extension SettingsViewController {
    private func updateTextPreviewerFont(point: Float) {
        guard let cell = cellTextPreviewer else { return }
        currentPointSize = CGFloat(point)
        cell.label.font = .systemFont(ofSize: CGFloat(point))
        cell.label.text = "\(Int(point)) " + textPreviewerText
    }
    
    @objc private func updateTextPreviewerText() {
        textPreviewerText = BibleManager.shared.bible[0].chapters[0][0]
        updateTextPreviewerFont(point: Float(currentPointSize))
    }

    private func handleSimpleSettignsValueChanged(for index: IndexPath, _ bool: Bool) {
        let item = simpleSettings[index.row]
        if let key = item.userDefaultKey {
            UserDefaults.standard.set(bool, forKey: key)
        }
    }
}

// MARK: - Models
extension SettingsViewController {
    private enum SettingType: CaseIterable {
        /// Toggles
        case simpleSettings
        case font
        case bibleVersion
        
        var title: String {
            switch self {
            case .simpleSettings:
                return "Simple Settings"
            case .font:
                return "Fonts".localized(.ui)
            case .bibleVersion:
                return "Bible Versions".localized(.ui)
            }
        }
    }

    private enum FontSettingType: CaseIterable {
        case textPresenter
        case slider
    }
}
