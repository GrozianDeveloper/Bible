//
//  MapTableViewCell.swift
//  Bible
//
//  Created by Bogdan Grozian on 07.03.2022.
//

import UIKit

final class MapTableViewCell: UITableViewCell, Nibable {

    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var mapImageView: UIImageView!
    
    func configure(image: UIImage?) {
        guard let image = image else { return }
        mapImageView.image = image
        scrollView.contentSize = image.size
    }
}
