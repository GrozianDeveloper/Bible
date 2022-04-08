//
//  SliderTableViewCell.swift
//  Bible
//
//  Created by Bogdan Grozian on 02.03.2022.
//

import UIKit

final class SliderTableViewCell: UITableViewCell, Nibable {

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    @IBOutlet weak var slider: UISlider!

    var valueDidChange: ((Float) ->())?
    @IBAction private func sliderValueDidChange(_ sender: UISlider) {
        sender.value = calculateStepSliderValue(sender.value)
        valueDidChange?(sender.value)
    }
    func calculateStepSliderValue(_ value: Float) -> Float {
        let step: Float = 1
        return round(value / step) * step
    }
}
