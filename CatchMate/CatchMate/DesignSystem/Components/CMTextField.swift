//
//  CMTextField.swift
//  CatchMate
//
//  Created by 방유빈 on 6/16/24.
//

import UIKit

/// reactor 에 text 값을 state로 관리하여 state와 바인딩하여 applyStyle 호출해야함.
class CMTextField: UITextField {
    private let padding = UIEdgeInsets(top: 17, left: 16, bottom: 17, right: 36)
    private let clearButtonSize = CGSize(width: 20, height: 20)
    var cmPlaceholder: String?
    var isRequiredMark: Bool = false {
        didSet {
            updatePlaceholder()
        }
    }
    init(frame: CGRect = .zero, placeHolder: String?) {
        self.cmPlaceholder = placeHolder
        super.init(frame: frame)
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        layer.cornerRadius = 8.0
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.cmBorderColor.cgColor
        textColor = .cmHeadLineTextColor
        backgroundColor = .white
        placeholder = cmPlaceholder
        applyStyle(textStyle: FontSystem.body02_semiBold, placeholdeAttr: [NSAttributedString.Key.foregroundColor: UIColor.grayScale400])
        // Clear button
        clearButtonMode = .never
        
        // Add target for editing changed
        addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        addTarget(self, action: #selector(textFieldDidBeginEditing), for: .editingDidBegin)
        addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
    }
    // Text Rect
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    // Editing Rect
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    // Placeholder Rect
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
            var rightViewRect = super.rightViewRect(forBounds: bounds)
            rightViewRect.origin.x -= 16;
            return rightViewRect
    }
    
    @objc private func textFieldDidChange() {
        updateClearButtonVisibility()
        updateTextStyle()
    }
    
    func updateTextStyle() {
        if let currentText = self.text {
            self.attributedText = NSAttributedString(string: currentText, attributes: FontSystem.body02_semiBold.getAttributes())
        }
    }
    
    @objc private func textFieldDidBeginEditing() {
        layer.borderColor = UIColor.cmPrimaryColor.cgColor
        updateClearButtonVisibility()
        resignOtherResponders(in: superview, except: self)
    }
    
    @objc private func textFieldDidEndEditing() {
        layer.borderColor = UIColor.cmBorderColor.cgColor
        updateClearButtonVisibility()
        if let currentText = self.text {
            self.attributedText = NSAttributedString(string: currentText, attributes: FontSystem.body02_semiBold.getAttributes())
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
    
    private func updateClearButtonVisibility() {
        if let text = text, !text.isEmpty {
            rightView = createClearButton()
            rightViewMode = .always
        } else {
            rightView = nil
            rightViewMode = .never
        }
    }
    
    private func createClearButton() -> UIButton {
        let clearButton = UIButton(type: .custom)
        if let image = UIImage(named: "close")?.withRenderingMode(.alwaysTemplate) {
            clearButton.setImage(image, for: .normal)
        }
        clearButton.tintColor = .grayScale500
        clearButton.frame = CGRect(x: 0, y: 0, width: clearButtonSize.width, height: clearButtonSize.height)
        clearButton.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        
        clearButton.imageView?.contentMode = .scaleAspectFit
        
        return clearButton
    }
    
    @objc private func clearButtonTapped() {
        text = ""
        sendActions(for: .editingChanged)
    }
    
    private func updatePlaceholder() {
        let placeholderText = placeholder ?? ""
        var fontAtrribute = FontSystem.body02_semiBold.getAttributes()
        fontAtrribute[.foregroundColor] = UIColor.grayScale400
        let attributedString = NSAttributedString(string: placeholderText, attributes: fontAtrribute)
        if isRequiredMark {
            let requiredMark = NSMutableAttributedString(string: " *", attributes: [NSAttributedString.Key.foregroundColor: UIColor.cmPrimaryColor])
            requiredMark.insert(attributedString, at: 0)
            attributedPlaceholder =  requiredMark
        }
    }
}

