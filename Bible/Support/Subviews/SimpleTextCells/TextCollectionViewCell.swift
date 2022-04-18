//
//  VerseReferenceCollectionViewCell.swift
//  Bible
//
//  Created by Bogdan Grozian on 09.03.2022.
//

import UIKit

final class TextCollectionViewCell: UICollectionViewCell, Nibable {
    
    static var nib: UINib? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    let label = UILabel()
    
    private func setup() {
        addSubview(label)
        label.font = .systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        self.updateConstraintsIfNeeded()
        return super.preferredLayoutAttributesFitting(layoutAttributes)
    }
}
