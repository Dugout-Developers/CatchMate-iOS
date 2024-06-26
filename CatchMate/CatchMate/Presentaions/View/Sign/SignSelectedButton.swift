//
//  SignSelectedButton.swift
//  CatchMate
//
//  Created by 방유빈 on 6/26/24.
//

import UIKit
import FlexLayout
import PinLayout

final class SignSelectedButton<T: CaseIterable>: UIView {
    let item: T
    var contentHeight: CGFloat?
    var isSelected: Bool = false {
        willSet {
            updateFocus(newValue)
        }
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.cmPrimaryColor.cgColor
        view.clipsToBounds = true
        return view
    }()
    
    private let itemImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .cmBodyTextColor
        label.numberOfLines = 0
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.text = "팀명"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        return label
    }()
    
    init(item: T) {
        self.item = item
        super.init(frame: .zero)
        setupView(with: item)
        setupUI()
    }
    
    @available (*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func updateFocus(_ isSelected: Bool) {
        if isSelected {
            containerView.layer.borderWidth = 1
            label.textColor = .cmPrimaryColor
        } else {
            label.textColor = .cmBodyTextColor
            containerView.layer.borderWidth = 0
        }
    }
    private func setupView(with item: T) {
        if let team = item as? Team {
            itemImage.image = team.getLogoImage
            label.text = team.rawValue
            contentHeight = 140
        } else if let cheerStyle = item as? CheerStyles {
            itemImage.image = cheerStyle.iconImage
            label.text = cheerStyle.subInfo
            contentHeight = 180
        }
    }
    private func setupUI() {
        addSubview(containerView)
        containerView.flex.backgroundColor(.grayScale50).cornerRadius(8).direction(.column).justifyContent(.start).alignItems(.center).define { flex in
            flex.addItem(itemImage).marginTop(15).marginBottom(5).marginHorizontal(7).shrink(1)
            flex.addItem(label).marginBottom(30)
        }.height(contentHeight)
    }
}
