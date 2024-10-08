//
//  CMPopupViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 7/11/24.
//

import UIKit
import FlexLayout
import PinLayout

final class CMPopupViewController: UIViewController {
    var messageText: String = ""
    var importantButtonText: String = "OK"
    var commonButtonText: String = "Cancel"
    var importantAction: (() -> Void)?
    var commonAction: (() -> Void)?
    
    private let verticalTextPadding = 36.0
    private let horizontalTextPadding = 24.0
    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = .opacity400
        return view
    }()
    
    private let alertView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = .white
        view.layer.masksToBounds = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmHeadLineTextColor
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let importantButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.tintColor = .clear
        return button
    }()
    
    private let commonButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.cmHeadLineTextColor, for: .normal)
        button.tintColor = .clear
        return button
    }()
    
    private let horizontralDivider = UIView()
    private let verticalDivider = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupUI()
        setupButtons()
    }
    
    private func setupView() {
        view.backgroundColor = .clear
        titleLabel.text = messageText
        titleLabel.applyStyle(textStyle: FontSystem.body02_medium)
        importantButton.setTitle(importantButtonText, for: .normal)
        importantButton.setTitleColor(.cmPrimaryColor, for: .normal)
        importantButton.applyStyle(textStyle: FontSystem.body02_medium)
        commonButton.setTitle(commonButtonText, for: .normal)
        commonButton.setTitleColor(.cmHeadLineTextColor, for: .normal)
        commonButton.applyStyle(textStyle: FontSystem.body02_medium)
        titleLabel.textAlignment = .center
    }
    private func setupButtons() {
        importantButton.addTarget(self, action: #selector(clickedImportantButton), for: .touchUpInside)
        commonButton.addTarget(self, action: #selector(clickedCommonButton), for: .touchUpInside)
    }
    
    @objc func clickedImportantButton(_ sender: UIButton) {
        self.dismiss(animated: true) { [weak self] in
            self?.importantAction?()
        }
    }
    
    @objc func clickedCommonButton(_ sender: UIButton) {
        self.dismiss(animated: true) { [weak self] in
            self?.commonAction?()
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        dimView.pin.all()
        dimView.flex.layout()
    }
    private func setupUI() {
        view.addSubview(dimView)
        
        dimView.flex.direction(.column).alignItems(.center).justifyContent(.center).paddingHorizontal(50).define { flex in
            flex.addItem(alertView).direction(.column).justifyContent(.start).width(100%).alignItems(.center).define { flex in
                flex.addItem(titleLabel).marginVertical(verticalTextPadding).marginHorizontal(horizontalTextPadding)
                flex.addItem(horizontralDivider).width(100%).height(1).backgroundColor(.grayScale100)
                flex.addItem().direction(.row).justifyContent(.start).alignItems(.center).width(100%).paddingTop(16).paddingBottom(24).paddingHorizontal(24).define { flex in
                    flex.addItem(commonButton).grow(1).shrink(0)
                    flex.addItem(verticalDivider).width(1).height(18).backgroundColor(.grayScale100).marginHorizontal(10)
                    flex.addItem(importantButton).grow(1).shrink(0)
                }
            }
        }
    }
}


extension UIViewController {
    func showCMAlert(
        titleText: String,
        importantButtonText: String,
        commonButtonText: String,
        importantAction: (() -> Void)? = nil,
        commonAction: (() -> Void)? = nil) {
            let alertView = CMPopupViewController()
            alertView.modalPresentationStyle = .overFullScreen
            
            alertView.modalTransitionStyle = .crossDissolve
            alertView.messageText = titleText
            alertView.commonButtonText = commonButtonText
            alertView.importantButtonText = importantButtonText
            alertView.importantAction = importantAction
            alertView.commonAction = commonAction
            self.present(alertView, animated: true, completion: nil)
        }
}
