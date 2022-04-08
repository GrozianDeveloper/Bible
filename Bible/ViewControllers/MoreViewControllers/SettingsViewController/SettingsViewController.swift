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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    private var cellTextPreviewer: TextTableViewCell?
    private var textPreviewerText = BibleManager.shared.bible[0].chapters[0][0]
    private var currentPointSize = BibleManager.shared.font.pointSize

    private func updateTextPreviewerFont(point: Float) {
        guard let cell = cellTextPreviewer else { return }
        currentPointSize = CGFloat(point)
        cell.label.font = .systemFont(ofSize: CGFloat(point))
        cell.label.text = "\(Int(point)) " + textPreviewerText
    }
}

// MARK: Life Cycle
extension SettingsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(TextTableViewCell.self, forCellReuseIdentifier: TextTableViewCell.identifier)
        tableView.register(SliderTableViewCell.nib, forCellReuseIdentifier: SliderTableViewCell.identifier)
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
            let detailVC = BibleVersionDetailsViewController()
            detailVC.setup(version: bibleVersions[indexPath.row])
            navigationController?.pushViewController(detailVC, animated: true)
        case .font:
            break
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch sections[indexPath.section] {
        case .bibleVersion:
            return 40
        case .font:
            switch fontSettings[indexPath.row] {
            case .textPresenter:
                return 40
            case .slider:
                return 60
            }
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
}

// MARK: - Data Source
extension SettingsViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
        case .bibleVersion:
            let cell = TextTableViewCell(components: [.rightImageView])
            cell.label.text = bibleVersions[indexPath.row].title
            if BibleManager.shared.bibleVersion == bibleVersions[indexPath.row] {
                cell.rightImageView?.image = UIImage(systemName: "circle.fill")
            }
            cell.wholeViewLeadingConstaint.constant += 5
            return cell
        case .font:
            switch fontSettings[indexPath.row] {
            case .textPresenter:
                let cell = TextTableViewCell()
                cellTextPreviewer = cell
                cell.wholeViewLeadingConstaint.constant += 5
                let font = BibleManager.shared.font
                cell.label.font = font
                cell.label.text = "\(Int(round(font.pointSize))) " + textPreviewerText
                cell.label.numberOfLines = 1
                return cell
            case .slider:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: SliderTableViewCell.identifier) as? SliderTableViewCell else { return UITableViewCell() }
                cell.slider.minimumValue = 14
                cell.slider.maximumValue = 44
                let stepedValue = cell.calculateStepSliderValue(Float(currentPointSize))
                cell.slider.value = stepedValue
                cell.selectionStyle = .none
                cell.valueDidChange = updateTextPreviewerFont(point:)
                return cell
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .bibleVersion:
            return bibleVersions.count
        case .font:
            return fontSettings.count
        }
    }
}

// MARK: - Models
extension SettingsViewController {
    private enum SettingType: CaseIterable {
        case bibleVersion
        case font
        
        var title: String {
            switch self {
            case .bibleVersion:
                return "Bible Versions".localized(.ui)
            case .font:
                return "Fonts".localized(.ui)
            }
        }
    }

    private enum FontSettingType: CaseIterable {
        case textPresenter
        case slider
    }
}
