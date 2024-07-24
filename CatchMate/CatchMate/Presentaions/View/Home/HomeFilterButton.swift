//
//  HomeFilterButton.swift
//  CatchMate
//
//  Created by 방유빈 on 6/14/24.
//

import UIKit
import FlexLayout
import PinLayout

final class HomeFilterButton: UIButton {
    private let containerView = UIView()
    private let iconImageView = UIImageView()
    private let filterTitleLabel = UILabel()
    private let valueLabel = UILabel()
    var filterValue: String? {
        didSet {
            setupValue(filterValue)
        }
    }
    private(set) var filterType: Filter
    
    init(icon: UIImage? = UIImage(named: "cm20down_filled"), title: String, filter: Filter) {
        self.filterType = filter
        super.init(frame: .zero)
        setupButton()
        setupData(icon: icon, title: title)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        self.filterType = .none
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.pin.all()
        containerView.flex.layout()
    }
    
    private func setupValue(_ value: String?) {
        valueLabel.text = value
        valueLabel.textColor = .cmPrimaryColor
        valueLabel.applyStyle(textStyle: FontSystem.body03_medium)
        valueLabel.flex.markDirty()
        containerView.flex.layout()
    }
    
    private func setupButton() {
        // 버튼 스타일 설정
        backgroundColor = UIColor.white
        layer.cornerRadius = 20
        tintColor = .cmPrimaryColor
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
            flex.addItem(filterTitleLabel).marginRight(2)
            flex.addItem(valueLabel).marginRight(2)
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
