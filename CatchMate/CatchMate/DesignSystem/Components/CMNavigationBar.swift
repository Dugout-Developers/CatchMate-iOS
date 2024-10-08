//
//  CMNavigationBar.swift
//  CatchMate
//
//  Created by 방유빈 on 7/13/24.
//

import UIKit
import SnapKit

final class CMNavigationBar: UIView {
    private let leftStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 12
        return stackView
    }()
    
    private let rightStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 12
        return stackView
    }()

    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "cm20left")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()

    var isBackButtonHidden: Bool = false {
        didSet {
            backButton.isHidden = isBackButtonHidden
            configureItems(stackView: leftStackView, items: leftItems, includeBackButton: true)
        }
    }
    
    var isRightItemsHidden: Bool = false {
        didSet {
            rightStackView.isHidden = isRightItemsHidden
        }
    }
    
    private var leftItems: [UIView] = [] {
        didSet {
            configureItems(stackView: leftStackView, items: leftItems, includeBackButton: true)
        }
    }
    
    private var rightItems: [UIView] = [] {
        didSet {
            configureItems(stackView: rightStackView, items: rightItems)
        }
    }
    
    init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(leftStackView)
        addSubview(rightStackView)
        
        leftStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(18)
            make.centerY.equalToSuperview()
            make.height.equalTo(27)
        }
        rightStackView.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(leftStackView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-18)
            make.centerY.equalToSuperview()
            make.height.equalTo(27)
        }
    }
    
    private func configureItems(stackView: UIStackView, items: [UIView], includeBackButton: Bool = false) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if includeBackButton && !isBackButtonHidden {
            stackView.addArrangedSubview(backButton)
            backButton.snp.makeConstraints { make in
                make.size.equalTo(20)
            }
        }
        items.forEach { stackView.addArrangedSubview($0) }
    }
    
    func setBackButtonAction(target: Any?, action: Selector) {
        backButton.addTarget(target, action: action, for: .touchUpInside)
    }
    
    func addLeftItems(items: [UIView]) {
        self.leftItems = items
    }
    
    func addRightItems(items: [UIView]) {
        self.rightItems = items
    }
}
