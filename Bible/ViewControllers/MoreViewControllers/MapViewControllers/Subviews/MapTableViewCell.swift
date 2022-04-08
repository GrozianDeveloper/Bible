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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        scrollView.maximumZoomScale = 3
        scrollView.minimumZoomScale = 1
        scrollView.delegate = self
    }
    
    func configure(image: UIImage?) {
        guard let image = image else { return }
        mapImageView.image = image
        scrollView.contentSize = image.size
    }
}

extension MapTableViewCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return mapImageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale > 1, let image = mapImageView.image {
            let imageViewSize = mapImageView.frame.size
            let ratioWidth = imageViewSize.width / image.size.width
            let ratioHeight = imageViewSize.height / image.size.height
            let ratio = min(ratioWidth, ratioHeight)
            
            let newWidth = image.size.width * ratio
            let newHeight = image.size.height * ratio
            
            let conditionLeft = newWidth * scrollView.zoomScale > imageViewSize.width
            let left = 0.5 * (conditionLeft ? newWidth - imageViewSize.width : (scrollView.frame.width - scrollView.contentSize.width))

            let conditionTop = newHeight * scrollView.zoomScale > imageViewSize.height
            let top = 0.5 * (conditionTop ? newHeight - imageViewSize.height : (scrollView.frame.height - scrollView.contentSize.height))
            scrollView.contentInset = .init(top: top, left: left, bottom: top, right: left)
        } else {
            scrollView.contentInset = .zero
        }
    }
}
