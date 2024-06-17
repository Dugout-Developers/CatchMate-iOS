//
//  TeamFilterTableViewCell.swift
//  CatchMate
//
//  Created by 방유빈 on 6/16/24.
//

import UIKit
import PinLayout
import FlexLayout
import SwiftUI

final class TeamFilterTableViewCell: UITableViewCell {
    private let containerView = UIView()
    private let teamImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let teamNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .black
        label.textAlignment = .left
        return label
    }()
    private let checkButton: UIButton = {
        let button = UIButton(configuration: .plain())
        button.setImage(UIImage(systemName: "circle"), for: .normal)
        return button
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.pin.all()
        containerView.flex.layout()
    }
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        containerView.pin.width(size.width)
        containerView.flex.layout(mode: .adjustHeight)
        return CGSize(width: size.width, height: containerView.frame.height)
    }
    
    func setupData(team: Team) {
        teamImageView.image = team.getDefaultsImage
        teamNameLabel.text = team.rawValue
    }
}

// MARK: - UI
extension TeamFilterTableViewCell {
    private func setUI() {
        addSubview(containerView)
        
        containerView.flex.direction(.row).justifyContent(.spaceBetween).alignContent(.center).padding(10).define { flex in
            flex.addItem(teamImageView).size(48)
            flex.addItem(teamNameLabel).marginHorizontal(16).grow(1)
            flex.addItem(checkButton).size(20).alignSelf(.center)
        }
    }
}


