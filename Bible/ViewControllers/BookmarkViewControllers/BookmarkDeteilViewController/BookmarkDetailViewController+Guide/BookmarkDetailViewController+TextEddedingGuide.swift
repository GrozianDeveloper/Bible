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
        let videoPlayer = VideoPlayerView()
        videoPlayer.alpha = 0
        let url = type.getURL(forDarkMode: traitCollection.userInterfaceStyle == .dark)
        let player = AVPlayer(url: url)
        player.actionAtItemEnd = .pause
        videoPlayer.player = player
        self.view.addSubview(videoPlayer)
        videoPlayer.translatesAutoresizingMaskIntoConstraints = false
        videoPlayer.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        videoPlayer.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        videoPlayer.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.6).isActive = true
        let aspectRatio = aspectRatioOfVideo(with: url)
        videoPlayer.heightAnchor.constraint(equalTo: videoPlayer.widthAnchor, multiplier: aspectRatio).isActive = true
        self.videoPlayer = videoPlayer
        
        NotificationCenter.default.addObserver(self, selector: #selector(videoFinished), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        let touchRecognizer = UITapGestureRecognizer(target: self, action: #selector(removePlayerView))
        textView.addGestureRecognizer(touchRecognizer)
        videoPlayer.clipsToBounds = true
        UIView.animate(withDuration: 0.2) {
            videoPlayer.alpha = 1
            videoPlayer.layer.cornerRadius = 15
            videoPlayer.layer.borderColor = UIColor.label.cgColor
            videoPlayer.layer.borderWidth = 3
        } completion: { _ in
            videoPlayer.player?.play()
        }
    }
    
    private func aspectRatioOfVideo(with url: URL) -> Double {
        guard let track = AVURLAsset(url: url).tracks(withMediaType: AVMediaType.video).first else { return 1 }
        let size = track.naturalSize.applying(track.preferredTransform)
        let resolution =  CGSize(width: abs(size.width), height: abs(size.height))
        let width = resolution.width
        let height = resolution.height
        return Double(height / width)
    }

    
    @objc private func didTapOnTextView(_ sender: UITapGestureRecognizer? = nil) {
        removePlayerView()
    }
    
    @objc private func videoFinished(_ sender: NSNotification? = nil) {
        removePlayerView()
    }
    
    @objc private func removePlayerView(withAnimation: Bool = true) {
        let removeVideoPlayer: ((_ bool: Bool) -> ()) = { [weak self] _ in
            self?.videoPlayer?.removeFromSuperview()
            self?.videoPlayer = nil
        }
        
        if withAnimation {
            let animation: (() -> ()) = { [weak self] in
                self?.videoPlayer?.alpha = 0
            }
            UIView.animate(withDuration: 0.5, delay: 0, options: .allowAnimatedContent, animations: animation, completion: removeVideoPlayer)
        } else {
            removeVideoPlayer(true)
        }
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        videoPlayer?.layer.borderColor = UIColor.label.cgColor
    }
}

extension BookmarkDetailViewController {
    enum GuideType {
        case referenceToVerbe
        case addVerbe
        
        
        func getURL(forDarkMode isDark: Bool = false) -> URL {
            let mode = isDark ? "Dark" : "Light"
            switch self {
            case .addVerbe:
                return URL(fileURLWithPath: Bundle.main.path(forResource: "V-Guide\(mode)", ofType:"mov")!)
            case .referenceToVerbe:
                return URL(fileURLWithPath: Bundle.main.path(forResource: "V+Guide\(mode)", ofType:"mov")!)
            }
        }
    }
}
