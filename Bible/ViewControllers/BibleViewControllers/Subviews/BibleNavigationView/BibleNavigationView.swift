//
//  BibleNavigationButton.swift
//  Bible
//
//  Created by Bogdan Grozian on 27.02.2022.
//

import UIKit

final class BibleNavigationView: UIView {

    @IBOutlet private var contentView: UIView!

    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet weak var bookButton: UIButton!
    @IBOutlet weak var chapterButton: UIButton!

    var bookButtonDidTapCallBack: (() -> ())?
    var chapterButtonDidTapCallBack: (() -> ())?
    private var middleLineLayer: CALayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBookButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupBookButton()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        stackView.layer.cornerRadius = 5
        stackView.layer.borderWidth = middleLineLayer.borderWidth
        stackView.layer.borderColor = middleLineLayer.borderColor
        
        middleLineLayer.frame.size.height = stackView.layer.frame.height
        middleLineLayer.frame.origin.x = stackView.layer.bounds.midX
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
    private func setupBookButton() {
        Bundle.main.loadNibNamed("BibleNavigationView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        clipsToBounds = true
        
        middleLineLayer = CALayer()
        middleLineLayer.borderWidth = 1
        middleLineLayer.frame.size.width = 1
        middleLineLayer.borderColor = UIColor.secondarySystemBackground.cgColor
        stackView.layer.addSublayer(middleLineLayer)
    }
}
