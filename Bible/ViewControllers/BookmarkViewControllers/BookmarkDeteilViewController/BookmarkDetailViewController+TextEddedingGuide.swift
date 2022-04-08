//
//  BookmarkDetailViewController+TextEddedingGuide.swift
//  Bible
//
//  Created by Bogdan Grozian on 16.03.2022.
//

import UIKit
import AVKit

extension BookmarkDetailViewController {
    func playGuideVideo(_ type: GuideType) {
        print("play guide do not implemented")
    }
    
    private func playVideo(from file:String) {
        let file = file.components(separatedBy: ".")

        guard let path = Bundle.main.path(forResource: file[0], ofType:file[1]) else {
            debugPrint( "\(file.joined(separator: ".")) not found")
            return
        }
        let player = AVPlayer(url: URL(fileURLWithPath: path))

        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.bounds
        self.view.layer.addSublayer(playerLayer)
        player.play()
    }
}

extension BookmarkDetailViewController {
    enum GuideType {
        case referenceToVerbe
        case addVerbe
        
        var url: URL {
            switch self {
            default:
                fatalError("video url not added")
            }
        }
    }
}
