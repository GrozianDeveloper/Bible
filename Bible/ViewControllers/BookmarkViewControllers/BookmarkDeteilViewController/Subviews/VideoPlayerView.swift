//
//  VideoPlayerView.swift
//  Bible
//
//  Created by Bogdan Grozian on 15.04.2022.
//

import UIKit
import AVKit.AVPlayerViewController

final class VideoPlayerView: UIView {
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }

    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}
