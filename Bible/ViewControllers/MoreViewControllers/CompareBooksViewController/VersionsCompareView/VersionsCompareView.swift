//
//  VersionsCompareView.swift
//  Bible
//
//  Created by Bogdan Grozian on 19.04.2022.
//

import UIKit

final class VersionsCompareView: UIView {
    
    private let stackView = UIStackView()
    let leftVersionButton = UIButton(type: .system)
    let rightVersionButton = UIButton(type: .system)
    let navigationView = BibleNavigationView(frame: .zero)

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        initialSetupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialSetupView()
    }
}

// MARK: Setup
extension VersionsCompareView {
    private func initialSetupView() {
//        stackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
//        stackView.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor).isActive = true
//        stackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true
//        stackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true

        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 20
        stackView.distribution = .fill

        addSubview(stackView)
        stackView.addArrangedSubview(leftVersionButton)
        stackView.addArrangedSubview(navigationView)
        stackView.addArrangedSubview(rightVersionButton)
        
        // main stack view
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        stackView.safeAreaLayoutGuide.widthAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.widthAnchor, multiplier: 1).isActive = true
        stackView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor, multiplier: 1).isActive = true
        // sub stack view
        navigationView.stackView.widthAnchor.constraint(lessThanOrEqualTo: navigationView.widthAnchor, multiplier: 1).isActive = true
        navigationView.stackView.heightAnchor.constraint(lessThanOrEqualTo: navigationView.heightAnchor, multiplier: 1).isActive = true

        leftVersionButton.translatesAutoresizingMaskIntoConstraints = false
        leftVersionButton.widthAnchor.constraint(equalTo: rightVersionButton.widthAnchor, multiplier: 1).isActive = true
        leftVersionButton.layer.cornerRadius = 5
        leftVersionButton.layer.borderColor = UIColor.label.cgColor
        leftVersionButton.layer.borderWidth = 1
    
        rightVersionButton.layer.cornerRadius = 5
        rightVersionButton.layer.borderColor = UIColor.label.cgColor
        rightVersionButton.layer.borderWidth = 1
    }
}
