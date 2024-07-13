//
//  CMNavigationBar.swift
//  CatchMate
//
//  Created by 방유빈 on 7/13/24.
//

import UIKit

final class CMNavigationBar: UIView {
    private let leftStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        return stackView
    }()
    
    private let rightStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .cmHeadLineTextColor
        label.applyStyle(textStyle: FontSystem.headline03_reguler)
        return label
    }()
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "cm20left")?.withRenderingMode(.alwaysOriginal), for: .normal)
//        button.tintColor = .clear
        return button
    }()
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    var isBackButtonHidden: Bool = false {
        didSet {
            backButton.isHidden = isBackButtonHidden
            configureItems(stackView: leftStackView, items: leftItems, includeBackButton: true)
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
        addSubview(titleLabel)
        
        leftStackView.translatesAutoresizingMaskIntoConstraints = false
        rightStackView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            leftStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            leftStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            leftStackView.heightAnchor.constraint(equalToConstant: 27),
            
            rightStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            rightStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            rightStackView.heightAnchor.constraint(equalToConstant: 27),
            
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leftStackView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: rightStackView.leadingAnchor, constant: -12)
        ])
    }
    
    private func configureItems(stackView: UIStackView, items: [UIView], includeBackButton: Bool = false) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if includeBackButton && !isBackButtonHidden {
            stackView.addArrangedSubview(backButton)
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
