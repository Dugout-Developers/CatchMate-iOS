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
    private let textLabel = UILabel()
    private(set) var filterType: Filter
    
    init(icon: UIImage?, title: String, filter: Filter) {
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
    
    private func setupButton() {
        // 버튼 스타일 설정
        backgroundColor = UIColor.white
        layer.cornerRadius = 8
        tintColor = .cmPrimaryColor
        self.addTarget(self, action: #selector(buttonPressed), for: [.touchDown, .touchDragInside])
        self.addTarget(self, action: #selector(buttonReleased), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    private func setupData(icon: UIImage?, title: String) {
        // 아이콘 설정
        iconImageView.image = icon
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .gray
        
        // 타이틀 설정
        textLabel.text = title
        textLabel.textColor = .black
        textLabel.font = UIFont.systemFont(ofSize: 14)
    }
    
    private func setupUI() {
        addSubview(containerView)
        containerView.isUserInteractionEnabled = false
        containerView.flex.direction(.row).alignItems(.center).paddingHorizontal(10).paddingVertical(11).define { flex in
            flex.addItem(iconImageView).size(20)
            flex.addItem(textLabel).marginLeft(8)
        }
    }
    
    @objc 
    private func buttonPressed() {
        iconImageView.tintColor = .cmPrimaryColor // 눌렸을 때 색상
        textLabel.textColor = .cmPrimaryColor
    }
    
    @objc 
    private func buttonReleased() {
        iconImageView.tintColor = .gray // 기본 상태로 복원
        textLabel.textColor = .black
    }
    
}
