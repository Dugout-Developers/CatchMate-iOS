//
//  HomeFilterButton.swift
//  CatchMate
//
//  Created by 방유빈 on 6/14/24.
//

import UIKit
import FlexLayout
import PinLayout

final class OptionButtonView: UIButton {
    private let containerView = UIView()
    private let iconImageView = UIImageView()
    private let titleText: String
    private let filterTitleLabel = UILabel()
    var filterValue: String? {
        didSet {
            updateView(filterValue)
        }
    }
    private(set) var filterType: Filter
    
    init(icon: UIImage? = UIImage(named: "cm20down_filled"), title: String, filter: Filter) {
        self.filterType = filter
        self.titleText = title
        super.init(frame: .zero)
        setupButton()
        setupData(icon: icon, title: title)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        self.filterType = .none
        self.titleText = ""
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let value = filterValue, !value.isEmpty {
            filterTitleLabel.textColor = .white
        } else {
            filterTitleLabel.textColor = .cmBodyTextColor
        }
        containerView.pin.all()
        containerView.flex.layout()
    }
    
    private func updateView(_ value: String?) {
        if let value = value, !value.isEmpty {
            filterTitleLabel.text = value
            filterTitleLabel.textColor = .white
            filterTitleLabel.applyStyle(textStyle: FontSystem.body03_medium)
            iconImageView.image = UIImage(named: "cm20down_filled")?.withTintColor(.white, renderingMode: .alwaysOriginal)
            backgroundColor = .cmPrimaryColor
        } else {
            filterTitleLabel.text = titleText
            filterTitleLabel.textColor = .cmBodyTextColor
            filterTitleLabel.applyStyle(textStyle: FontSystem.body03_medium)
            iconImageView.image = UIImage(named: "cm20down_filled")?.withTintColor(.cmBodyTextColor, renderingMode: .alwaysOriginal)
            backgroundColor = .white
        }
        filterTitleLabel.flex.markDirty()
        containerView.flex.layout()
    }
    
    private func setupButton() {
        // 버튼 스타일 설정
        backgroundColor = UIColor.white
        layer.cornerRadius = 8
        self.addTarget(self, action: #selector(buttonPressed), for: [.touchDown, .touchDragInside])
        self.addTarget(self, action: #selector(buttonReleased), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    private func setupData(icon: UIImage?, title: String) {
        // 아이콘 설정
        iconImageView.image = icon?.withTintColor(.grayScale700, renderingMode: .alwaysOriginal)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .grayScale700
        
        // 타이틀 설정
        filterTitleLabel.text = title
        filterTitleLabel.textColor = .cmHeadLineTextColor
        filterTitleLabel.applyStyle(textStyle: FontSystem.body03_medium)
    }
    
    private func setupUI() {
        addSubview(containerView)
        containerView.isUserInteractionEnabled = false
        containerView.flex.direction(.row).alignItems(.center).paddingHorizontal(16).paddingVertical(12).define { flex in
            flex.addItem(filterTitleLabel).marginRight(4)
            flex.addItem(iconImageView).size(20)
        }
    }
    
    @objc 
    private func buttonPressed() {
        iconImageView.tintColor = .cmPrimaryColor // 눌렸을 때 색상
        filterTitleLabel.textColor = .cmPrimaryColor
    }
    
    @objc 
    private func buttonReleased() {
        iconImageView.tintColor = .grayScale700 // 기본 상태로 복원
        filterTitleLabel.textColor = .black
    }
    
}
