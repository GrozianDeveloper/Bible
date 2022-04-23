//
//  TextTableViewCell.swift
//  Bible
//
//  Created by Bogdan Grozian on 01.03.2022.
//

import UIKit


final class TextTableViewCell1: UITableViewCell, Nibable {
    
    static var nib: UINib? { return nil }

    let label = UILabel()

    init() {
        super.init(style: .default, reuseIdentifier: TextTableViewCell1.identifier)
        setup()
        selectionStyle = .none
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
        
    }

//    private(set) var wholeViewLeadingConstaint: NSLayoutConstraint!
}

// MARK: Setup
private extension TextTableViewCell1 {
    // MARK: - Only Text
    private func setupOnlyTextStyle() {
        label.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        label.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -5).isActive = true
    }
}

private extension TextTableViewCell1 {
    private func setup() {
        basicLabelSetup()
        setupOnlyTextStyle()
    }
    
    private func basicLabelSetup() {
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
}

// MARK: - Models
extension TextTableViewCell1 {
//    enum TextTableViewStyle {
//        case rightImageView
        /// Do not connected in main cell view but additinal on top
//        case leftLabel
//    }
    
//    enum FontType {
//        case standartBible
//        case boldBible
//    }
}
