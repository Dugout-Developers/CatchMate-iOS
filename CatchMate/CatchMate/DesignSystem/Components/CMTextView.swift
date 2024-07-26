//
//  CMTextView.swift
//  CatchMate
//
//  Created by 방유빈 on 6/23/24.
//

import UIKit
import SnapKit

class CMTextView: UITextView {
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grayScale400
        label.numberOfLines = 0
        return label
    }()

    var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
            placeholderLabel.applyStyle(textStyle: FontSystem.body02_semiBold)
            setNeedsLayout()
        }
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupView()
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupUI()
    }

    private func setupView() {
        layer.borderColor = UIColor.cmBorderColor.cgColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 12.0
        
        textContainerInset = UIEdgeInsets(top: 15, left: 12, bottom: 15, right: 12)
        textColor = .cmHeadLineTextColor
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextView.textDidChangeNotification, object: self)
    }
    
    private func setupUI() {
        addSubview(placeholderLabel)
        
        placeholderLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
        }

    }
    override func becomeFirstResponder() -> Bool {
        let didBecomeFirstResponder = super.becomeFirstResponder()
        if didBecomeFirstResponder {
            resignOtherResponders(in: superview, except: self)
            layer.borderColor = UIColor.cmPrimaryColor.cgColor
        }
        return didBecomeFirstResponder
    }
    
    override func resignFirstResponder() -> Bool {
        let didResignFirstResponder = super.resignFirstResponder()
        if didResignFirstResponder {
            layer.borderColor = UIColor.cmBorderColor.cgColor
        }
        return didResignFirstResponder
    }
    
    
    @objc private func textDidChange() {
        placeholderLabel.isHidden = !text.isEmpty
        if let currentText = self.text {
            self.attributedText = NSAttributedString(string: currentText, attributes: FontSystem.body02_medium.getAttributes())
        }
    }
    
    // 다른 응답자 포기
    private func resignOtherResponders(in view: UIView?, except responder: UIResponder) {
        guard let view = view else { return }
        
        for subview in view.subviews {
            if let textView = subview as? UITextView, textView != responder {
                textView.resignFirstResponder()
            } else if let textField = subview as? UITextField, textField != responder {
                textField.resignFirstResponder()
            } else if let pickerview = subview as? CMPickerTextField, pickerview != responder {
                pickerview.unFocusing()
            } else {
                resignOtherResponders(in: subview, except: responder)
            }
        }
    }
    
    // Remove observer
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // Layout subviews
    override func layoutSubviews() {
        super.layoutSubviews()
        placeholderLabel.isHidden = !text.isEmpty
    }
}


class BaseTextView: UITextView {
    var fontSystem: TextStyle = FontSystem.body02_semiBold
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grayScale400
        label.numberOfLines = 0
        return label
    }()
    var isHideenPlaceHolder: Bool = false {
        didSet {
            placeholderLabel.isHidden = isHideenPlaceHolder
        }
    }
    var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
            placeholderLabel.applyStyle(textStyle: fontSystem)
            setNeedsLayout()
        }
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupView()
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupUI()
    }

    private func setupView() {
        textColor = .cmHeadLineTextColor
        textContainerInset = .zero
        textContainer.lineFragmentPadding = 0
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextView.textDidChangeNotification, object: self)
    }
    
    private func setupUI() {
        addSubview(placeholderLabel)
        
        placeholderLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

    }
    override func becomeFirstResponder() -> Bool {
        let didBecomeFirstResponder = super.becomeFirstResponder()
        if didBecomeFirstResponder {
            resignOtherResponders(in: superview, except: self)
        }
        return didBecomeFirstResponder
    }
    
    
    @objc private func textDidChange() {
        placeholderLabel.isHidden = !text.isEmpty
        if let currentText = self.text {
            self.attributedText = NSAttributedString(string: currentText, attributes: FontSystem.body02_medium.getAttributes())
        }
    }
    
    // 다른 응답자 포기
    private func resignOtherResponders(in view: UIView?, except responder: UIResponder) {
        guard let view = view else { return }
        
        for subview in view.subviews {
            if let textView = subview as? UITextView, textView != responder {
                textView.resignFirstResponder()
            } else if let textField = subview as? UITextField, textField != responder {
                textField.resignFirstResponder()
            } else if let pickerview = subview as? CMPickerTextField, pickerview != responder {
                pickerview.unFocusing()
            } else {
                resignOtherResponders(in: subview, except: responder)
            }
        }
    }
    
    // Remove observer
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // Layout subviews
    override func layoutSubviews() {
        super.layoutSubviews()
        placeholderLabel.isHidden = !text.isEmpty
    }
}
