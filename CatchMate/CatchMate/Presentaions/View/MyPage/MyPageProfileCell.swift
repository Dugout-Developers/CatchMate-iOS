//
//  ProfileCell.swift
//  CatchMate
//
//  Created by 방유빈 on 8/1/24.
//

import UIKit
import Kingfisher
import PinLayout
import FlexLayout

final class MyPageProfileCell: UITableViewCell {
    private var skeletonLayers: [CALayer] = []
    
    private let containerView = UIView()
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.cmStrokeColor.cgColor
        return imageView
    }()
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmHeadLineTextColor
        label.numberOfLines = 1
        return label
    }()
    private let tagContainer = UIView()
    private var tags: [DefaultsPaddingLabel] = []
    private let indicatorImageButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "cm20right")?.withTintColor(.grayScale500, renderingMode: .alwaysOriginal), for: .normal)
        return button
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        contentView.addSubview(containerView)
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.pin.all()
        containerView.flex.layout(mode: .adjustHeight)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        containerView.pin.width(size.width)
        containerView.flex.layout(mode: .adjustHeight)
        return CGSize(width: size.width, height: containerView.frame.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
        nicknameLabel.text = ""
        tags = []
        indicatorImageButton.isHidden = true
        containerView.flex.layout(mode: .adjustHeight)
    }
    
    func configData(_ user: User) {
        indicatorImageButton.isHidden = false
        if let image = user.profilePicture, let url = URL(string: image) {
            profileImageView.kf.setImage(with: url)
        } else {
            profileImageView.image = UIImage(named: "tempProfile")
        }
        nicknameLabel.text = user.nickName
        tags = []
        tags.append(makePaddingLabel(color: .white, backgroundColor: user.team.getTeamColor, text: user.team.rawValue))
        if let cheerStyle = user.cheerStyle {
            tags.append(makePaddingLabel(color: .white, backgroundColor: .cmPrimaryColor, text: cheerStyle.rawValue))
        }
        tags.append(makePaddingLabel(color: .cmNonImportantTextColor, backgroundColor: .grayScale100, text: user.gener.rawValue))
        let ageDecade = (user.age / 10) * 10
        tags.append(makePaddingLabel(color: .cmNonImportantTextColor, backgroundColor: .grayScale100, text: "\(ageDecade)대"))
        
        nicknameLabel.applyStyle(textStyle: FontSystem.body02_semiBold)
        setupUI()
        tagContainer.flex.direction(.row).justifyContent(.start).alignItems(.center).define { flex in
            tags.forEach { label in
                flex.addItem(label).marginRight(4)
            }
        }
        containerView.flex.layout(mode: .adjustHeight)
    }
    
    func configNotuser() {
        indicatorImageButton.isHidden = false
        profileImageView.image = UIImage(named: "EmptyPrimary")
        nicknameLabel.text = "로그인이 필요해요"
        setupUI()
        let label = makePaddingLabel(color: .grayScale500, backgroundColor: .grayScale100, text: "로그인하고 캐치메이트에서 직관 친구를 찾아보세요")
        tagContainer.flex.direction(.row).justifyContent(.start).alignItems(.center).define { flex in
            flex.addItem(label)
        }
        containerView.flex.layout(mode: .adjustHeight)
    }
    
    private func makePaddingLabel(color: UIColor, backgroundColor: UIColor, text: String) -> DefaultsPaddingLabel {
        let label = DefaultsPaddingLabel(padding: UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4))
        label.text = text
        label.textColor = color
        label.layer.cornerRadius = 2
        label.backgroundColor = backgroundColor
        label.applyStyle(textStyle: FontSystem.caption01_medium)
        return label
    }
}


extension MyPageProfileCell {
    private func setupUI() {
       
        containerView.flex.direction(.row).justifyContent(.start).alignItems(.center).paddingVertical(16).paddingHorizontal(18).define { flex in
            flex.addItem(profileImageView).size(56).cornerRadius(56/2).marginRight(12)
            flex.addItem().direction(.column).justifyContent(.start).alignItems(.start).define { flex in
                flex.addItem(nicknameLabel).marginBottom(6)
                flex.addItem(tagContainer)
            }.grow(1)
            flex.addItem(indicatorImageButton).size(20).marginLeft(40)
        }
        containerView.flex.layout(mode: .adjustHeight)
    }
}
