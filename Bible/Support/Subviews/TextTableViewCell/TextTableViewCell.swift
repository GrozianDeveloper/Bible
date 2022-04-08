//
//  TextTableViewCell.swift
//  Bible
//
//  Created by Bogdan Grozian on 01.03.2022.
//

import UIKit

/// By default set selecitonStyle = .none
final class TextTableViewCell: UITableViewCell, Nibable {
    
    static var nib: UINib? { return nil }

    let label = UILabel()
    private(set) var rightImageView: UIImageView?
    private(set) var leftImageView: UIImageView?
    private(set) var leftLabel: UILabel?

    init() {
        super.init(style: .default, reuseIdentifier: TextTableViewCell.identifier)
        setup(components: [])
        selectionStyle = .none
    }
    /// If empy ->  only text
    init(components: Set<TextTableViewStyle> = []) {
        super.init(style: .default, reuseIdentifier: TextTableViewCell.identifier)
        setup(components: components)
        selectionStyle = .none
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup(components: [])
    }
     
    var accessoryTypeWhenSelected: UITableViewCell.AccessoryType? = nil
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        guard let accessoryType = accessoryTypeWhenSelected else { return }
        self.accessoryType = selected ? accessoryType : .none
    }

    private(set) var wholeViewLeadingConstaint: NSLayoutConstraint!

    var fontType: FontType? {
        didSet {
            switch fontType {
            case .standartBible, .boldBible:
                NotificationCenter.default.addObserver(self, selector: #selector(fontDidUpdate), name: BibleManager.fontPointSizeDidChangeNotification, object: nil)
                fontDidUpdate()
            case .none:
                break
            }
        }
    }
    
    @objc private func fontDidUpdate() {
        let standartFont = BibleManager.shared.font
        switch fontType {
        case .standartBible:
            label.font = standartFont
        case .boldBible:
            label.font = .boldSystemFont(ofSize: standartFont.pointSize)
        default:
            break
        }
    }
}

// MARK: Setup
private extension TextTableViewCell {
    
    // MARK: - Only Text
    private func setupOnlyTextStyle() {
        wholeViewLeadingConstaint = label.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 5)
        wholeViewLeadingConstaint.isActive = true
        label.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -5).isActive = true
    }

    // MARK: - Right Image VIew
    /// Label leading anchor is not setuped
    private func setupRightImageView() {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .secondaryLabel
        rightImageView = imageView
        addSubview(rightImageView!)
        
        rightImageView!.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.trailingAnchor.constraint(equalTo: rightImageView!.safeAreaLayoutGuide.trailingAnchor, constant: -5),

            rightImageView!.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            rightImageView!.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -15),
            rightImageView!.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: 0.4),
            rightImageView!.widthAnchor.constraint(equalTo: rightImageView!.safeAreaLayoutGuide.heightAnchor, multiplier: 0.8)
        ])
    }

    // MARK: - Left Image View
    /// Label leading anchor is not setuped
    private func setupLeftImageView() {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.left")
        imageView.tintColor = .secondaryLabel
        leftImageView = imageView
        addSubview(leftImageView!)
        
        leftImageView!.translatesAutoresizingMaskIntoConstraints = false
        wholeViewLeadingConstaint = leftImageView!.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 5)
        NSLayoutConstraint.activate([
            wholeViewLeadingConstaint,
            leftImageView!.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            leftImageView!.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: 0.5),
            leftImageView!.widthAnchor.constraint(equalTo: leftImageView!.safeAreaLayoutGuide.heightAnchor, multiplier: 1),

            label.leadingAnchor.constraint(equalTo: leftImageView!.safeAreaLayoutGuide.trailingAnchor, constant: 5)
        ])
    }
    
    private func setupLeftLabel() {
        leftLabel = UILabel()
        leftLabel?.translatesAutoresizingMaskIntoConstraints = false
        addSubview(leftLabel!)
        leftLabel?.centerYAnchor.constraint(equalTo: label.safeAreaLayoutGuide.centerYAnchor).isActive = true
        leftLabel?.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor).isActive = true
        leftLabel?.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true
    }
}

private extension TextTableViewCell {
    private func setup(components: Set<TextTableViewStyle>) {
        basicLabelSetup()
        guard !components.isEmpty else  {
            setupOnlyTextStyle()
            return
        }
        var labelTrailingAnchor = false
        var labelLeadingAnchor = false
        if components.contains(.rightImageView) {
            setupRightImageView()
            labelTrailingAnchor = true
        }
        if components.contains(.leftImageVIew) {
            setupLeftImageView()
            labelLeadingAnchor = true
        }
        if components.contains(.leftLabel) {
            setupLeftLabel()
        }
        if !labelLeadingAnchor {
            wholeViewLeadingConstaint = label.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 5)
            wholeViewLeadingConstaint.isActive = true
        }
        if !labelTrailingAnchor {
            label.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -5).isActive = true
        }
    }
    
    private func basicLabelSetup() {
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
}

// MARK: - Models
extension TextTableViewCell {
    enum TextTableViewStyle {
        case rightImageView
        case leftImageVIew
        /// Do not connected in main cell view but additinal on top
        case leftLabel
    }
    
    enum FontType {
        case standartBible
        case boldBible
    }
}
