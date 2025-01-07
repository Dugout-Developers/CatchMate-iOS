//
//  NotiViewTableViewCell.swift
//  CatchMate
//
//  Created by 방유빈 on 6/17/24.
//

import UIKit
import PinLayout
import FlexLayout
import SwiftUI

enum NotiType {
    case arrive
    case accept
}

final class NotiViewTableViewCell: UITableViewCell {
    private let containerView: UIView = UIView()
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "profile")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    private let labelContainerView: UIView = UIView()
    private let notiLabel: UILabel = {
        let label = UILabel()
        label.text = "망글곰님의 직관 신청이 도착했어요"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .cmTextGray
        return label
    }()
    private let subinfoLabel: UILabel = {
        let label = UILabel()
        label.text = "06.09 | 17:00 | 잠실"
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor(hex: "#9f9f9f")
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        setUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configData(noti: NotificationList) {
        containerView.backgroundColor = noti.read ? .grayScale50 : .white
        notiLabel.text = noti.title
        subinfoLabel.text = noti.gameInfo
        ProfileImageHelper.loadImage(profileImageView, pictureString: noti.imgUrl)
        
        notiLabel.applyStyle(textStyle: FontSystem.body01_medium)
        subinfoLabel.applyStyle(textStyle: FontSystem.body02_semiBold)
        
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
}

// MARK: - UI
extension NotiViewTableViewCell {
    private func setUI() {
        addSubview(containerView)
        
        containerView.flex.direction(.row).justifyContent(.start).alignContent(.center).paddingHorizontal(18).paddingVertical(16).define { flex in
            flex.addItem(profileImageView).size(48).cornerRadius(24).marginRight(12)
            flex.addItem(labelContainerView).direction(.column).justifyContent(.start).alignContent(.start).define { flex in
                flex.addItem(notiLabel).marginBottom(4)
                flex.addItem(subinfoLabel)
            }
        }
    }
}

