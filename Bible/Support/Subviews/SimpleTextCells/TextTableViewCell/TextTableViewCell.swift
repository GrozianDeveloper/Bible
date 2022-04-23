//
//  TextTableViewCell.swift
//  Bible
//
//  Created by Bogdan Grozian on 17.04.2022.
//

import UIKit

/// By default selecitonStyle = .none
final class TextTableViewCell: UITableViewCell, Nibable {
    
    @IBOutlet weak var label: UILabel!
    
    var selectionColor: UIColor = .systemBackground
    private var previousBackgroundColor: UIColor?
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            previousBackgroundColor = backgroundColor
            backgroundColor = selectionColor
        } else {
            backgroundColor = previousBackgroundColor
        }
    }
}
