//
//  InteractiveTextTableViewCell.swift
//  Bible
//
//  Created by Bogdan Grozian on 13.04.2022.
//

import UIKit

final class InteractiveTextTableViewCell: UITableViewCell, Nibable {

    @IBOutlet weak var label: InteractiveLinkLabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
