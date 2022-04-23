//
//  ToggleTableViewCell.swift
//  Bible
//
//  Created by Bogdan Grozian on 16.04.2022.
//

import UIKit

final class ToggleTableViewCell: UITableViewCell, Nibable {
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var switchToggle: UISwitch!
    
    var cellIndex: IndexPath!

    var valueChanged: ((IndexPath, Bool) -> ())?

    @IBAction func SwitchValueChanged(_ sender: UISwitch) {
        valueChanged?(cellIndex, sender.isOn)
    }
}
