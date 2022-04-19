//
//  BibleNavigationButton.swift
//  Bible
//
//  Created by Bogdan Grozian on 27.02.2022.
//

import UIKit

final class BibleNavigationView: UIView {
    @IBOutlet private var contentView: UIView!

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var bookButton: UIButton!
    @IBOutlet weak var chapterButton: UIButton!

    var bookButtonDidTapCallBack: (() -> ())?
    var chapterButtonDidTapCallBack: (() -> ())?
    
    var isSetuped = false
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        stackView.layer.borderColor = UIColor.secondaryLabel.cgColor
    }
}

// MARK: Handle Actions
extension BibleNavigationView {
    @IBAction private func bookButtonDidTap(_ sender: Any) {
        bookButtonDidTapCallBack?()
    }
    @IBAction private func chapterDidTap(_ sender: Any) {
        chapterButtonDidTapCallBack?()
    }
}

// MARK: Setup
private extension BibleNavigationView {
    private func setupView() {
        Bundle.main.loadNibNamed("BibleNavigationView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        clipsToBounds = true

        let color = UIColor.secondaryLabel
        stackView.layer.cornerRadius = 5
        stackView.layer.borderWidth = 1
        stackView.layer.borderColor = color.cgColor
        bookButton.setTitleColor(color, for: .normal)
        chapterButton.setTitleColor(color, for: .normal)
    }
}
