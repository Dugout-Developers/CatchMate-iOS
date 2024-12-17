//
//  SignSelectedButton.swift
//  CatchMate
//
//  Created by 방유빈 on 6/26/24.
//

import UIKit
import FlexLayout
import PinLayout

final class TeamSelectButton: UIView {
    let item: Team
    var isSelected: Bool = false {
        willSet {
            updateFocus(newValue)
        }
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.cmPrimaryColor.cgColor
        view.backgroundColor = .grayScale50
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let itemImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .cmBodyTextColor
        return label
    }()
    
    init(item: Team) {
        self.item = item
        super.init(frame: .zero)
        setupData()
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.pin.all()
        containerView.flex.layout(mode: .adjustHeight)
    }
    
    func updateFocus(_ isSelected: Bool) {
        if isSelected {
            containerView.layer.borderWidth = 1
            titleLabel.textColor = .cmPrimaryColor
        } else {
            titleLabel.textColor = .cmBodyTextColor
            containerView.layer.borderWidth = 0
        }
    }
    
    private func setupData() {
        titleLabel.text = item.rawValue
        titleLabel.applyStyle(textStyle: FontSystem.body01_medium)
        itemImage.image = item.getLogoImage
    }
    private func setupUI() {
        addSubview(containerView)
        containerView.flex.direction(.column).justifyContent(.start).alignItems(.center).paddingTop(7).paddingBottom(16).paddingHorizontal(7).define { flex in
            flex.addItem(itemImage).width(100%).aspectRatio(1).marginBottom(4)
            flex.addItem(titleLabel)
        }
    }
}

final class CheerStyleButton: UIView {
    var item: CheerStyles?
    var isSelected: Bool = false {
        willSet {
            updateFocus(newValue)
        }
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.cmPrimaryColor.cgColor
        view.clipsToBounds = true
        view.backgroundColor = .grayScale50
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let itemImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .cmHeadLineTextColor
        return label
    }()
    private let subInfoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .cmNonImportantTextColor
        return label
    }()
    
    init(item: CheerStyles?) {
        self.item = item
        super.init(frame: .zero)
        setupData()
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.pin.all()
        containerView.flex.layout(mode: .adjustHeight)
    }
    
    func updateFocus(_ isSelected: Bool) {
        if isSelected {
            containerView.layer.borderWidth = 1
            titleLabel.textColor = .cmPrimaryColor
        } else {
            titleLabel.textColor = .cmBodyTextColor
            containerView.layer.borderWidth = 0
        }
    }
    
    func updateData(_ item: CheerStyles) {
        self.item = item
        setupData()
        titleLabel.flex.markDirty()
        subInfoLabel.flex.markDirty()
        itemImage.flex.markDirty()
        containerView.flex.layout()
    }
    
    private func setupData() {
        if let item {
            titleLabel.text = item.rawValue + " 스타일"
            titleLabel.applyStyle(textStyle: FontSystem.body01_medium)
            subInfoLabel.text = item.subInfo
            subInfoLabel.applyStyle(textStyle: FontSystem.body03_medium)
            itemImage.image = item.iconImage
        } else {
            titleLabel.text = "스타일"
            titleLabel.applyStyle(textStyle: FontSystem.body01_medium)
            subInfoLabel.text = "스타일을 선택해주세요."
            subInfoLabel.applyStyle(textStyle: FontSystem.body03_medium)
            itemImage.image = UIImage(named: "logo")
        }

    }
    private func setupUI() {
        addSubview(containerView)
        containerView.flex.direction(.column).justifyContent(.start).alignItems(.start).paddingVertical(20).paddingHorizontal(16).define { flex in
            flex.addItem(titleLabel).marginBottom(6)
            flex.addItem(subInfoLabel).marginBottom(29)
            flex.addItem(itemImage).size(72).cornerRadius(6).alignSelf(.end)
        }
    }
}
