//
//  ChatingInputField.swift
//  CatchMate
//
//  Created by 방유빈 on 7/25/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

extension Reactive where Base: ChatingInputField {
    var sendTap: ControlEvent<String?> {
        let source = base.sendButton.rx.tap
            .map { [weak base] in
                return base?.textField.text
            }
        return ControlEvent(events: source)
    }
}
final class ChatingInputField: UIView {
    private let disposeBag = DisposeBag()
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .grayScale50
        view.layer.cornerRadius = 22
        view.clipsToBounds = true
        return view
    }()
    let textField: BaseTextView = {
        let textview = BaseTextView()
        textview.fontSystem = FontSystem.body02_medium
        textview.textColor = .cmHeadLineTextColor
        textview.placeholder = "내용을 입력해주세요"
        textview.backgroundColor = .clear
        textview.isScrollEnabled = false
        return textview
    }()
    fileprivate let sendButton = SendButton()
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        setupUI()
        sendButton.tag = 999
        bind()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func clearText() {
        textField.text = ""
        textField.isHideenPlaceHolder = false
    }
    private func setupUI() {
        addSubview(backgroundView)
        backgroundView.addSubviews(views: [textField, sendButton])
        backgroundView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
            make.top.bottom.equalToSuperview().inset(4)
        }
        textField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.height.lessThanOrEqualTo(90)
        }
        sendButton.snp.makeConstraints { make in
            make.size.equalTo(32)
            make.leading.equalTo(textField.snp.trailing).offset(20)
            make.bottom.trailing.equalToSuperview().inset(6)
        }
    }
    
    private func bind() {
        textField.rx.text
            .compactMap { $0 }
            .withUnretained(self)
            .subscribe(onNext: { vc, text in
                vc.textField.attributedText = NSAttributedString(string: text, attributes: FontSystem.body02_medium.getAttributes())
                vc.sendButton.setButtonActive(!text.isEmpty)
            })
            .disposed(by: disposeBag)
    }
}


final class SendButton: UIButton {
    private var isButtonActive: Bool = true
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        layer.cornerRadius = bounds.size.width / 2
        layer.masksToBounds = true
        updateButtonAppearance()
    }
    
    func setButtonActive(_ isActive: Bool) {
        isButtonActive = isActive
        updateButtonAppearance()
    }
    
    private func updateButtonAppearance() {
        if isButtonActive {
            backgroundColor = .cmPrimaryColor
            setImage(UIImage(named: "send")?.withRenderingMode(.alwaysTemplate), for: .normal)
            tintColor = .white
        } else {
            backgroundColor = .white
            setImage(UIImage(named: "send")?.withRenderingMode(.alwaysTemplate), for: .normal)
            tintColor = .grayScale200
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.size.width / 2
    }
}
