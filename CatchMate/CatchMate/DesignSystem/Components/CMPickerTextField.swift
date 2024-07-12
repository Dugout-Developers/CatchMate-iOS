//
//  CMPickerTextField.swift
//  CatchMate
//
//  Created by 방유빈 on 6/17/24.
//

import UIKit

final class CMPickerTextField: UIView {
    private let padding = UIEdgeInsets(top: 17, left: 16, bottom: 17, right: 16)
    private let isFlexLayout: Bool
    var isRequiredMark: Bool = false {
        didSet {
            updatePlaceholder()
        }
    }
    
    private let rightAccessoryView: UIView?
    weak var parentViewController: UIViewController?
    var pickerViewController: BasePickerViewController?
    var customDetent: UISheetPresentationController.Detent?
    
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.isEnabled = false
        return textField
    }()
    
    private let borderView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = .white
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.cmBorderColor.cgColor
        view.clipsToBounds = true
        return view
    }()
    
    init(rightAccessoryView: UIView? = nil, placeHolder: String = "", isFlex: Bool = false) {
        self.rightAccessoryView = rightAccessoryView
        self.textField.placeholder = placeHolder
        self.isFlexLayout = isFlex
        super.init(frame: .zero)
        textField.applyStyle(textStyle: FontSystem.body02_semiBold, placeholdeAttr: [NSAttributedString.Key.foregroundColor: UIColor.grayScale400])
        if isFlex {
            setupFlexUI()
        } else {
            setupUI()
        }
        setupGesture()
    }
    
    func updateDateText(_ text: String) {
        textField.text = text
        textField.textColor = .cmHeadLineTextColor
        borderView.layer.borderColor = UIColor.cmBorderColor.cgColor
        if let currentText = self.textField.text {
            self.textField.attributedText = NSAttributedString(string: currentText, attributes: FontSystem.body02_medium.getAttributes())
        }
    }
    
    func unFocusing() {
        borderView.layer.borderColor = UIColor.cmBorderColor.cgColor
//        pickerViewController?.disable()
    }
    @available (*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc private func textFieldTapped() {
        borderView.layer.borderColor = UIColor.cmPrimaryColor.cgColor
        resignOtherResponders(in: superview, except: self)
        showPicker()
    }
    
    private func showPicker() {
        guard let pickerViewController = pickerViewController else { return }
        resignOtherResponders(in: superview, except: self)
        pickerViewController.delegate = self
        pickerViewController.modalPresentationStyle = .pageSheet
        
        if let sheet = pickerViewController.sheetPresentationController {
            sheet.detents = customDetent != nil ? [customDetent!] : [.medium(), .large()]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        
        parentViewController?.present(pickerViewController, animated: true, completion: nil)
    }
    
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(textFieldTapped))
        addGestureRecognizer(tapGesture)
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
}

// MARK: - UI
extension CMPickerTextField {
    private func setupFlexUI() {
        addSubview(borderView)
        borderView.flex.direction(.row).justifyContent(.spaceBetween).alignItems(.center).define { flex in
            flex.addItem(textField).margin(padding).grow(1)
            if let accessoryView = rightAccessoryView {
                flex.addItem(accessoryView).size(24).marginHorizontal(padding.right)
            }
        }
    }
    private func setupUI() {
        addSubviews(views: [borderView, textField])
        if let accessoryView = rightAccessoryView {
            addSubview(accessoryView)
        }

        borderView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        textField.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(padding.top)
            make.bottom.equalToSuperview().inset(padding.bottom)
            make.leading.equalToSuperview().inset(padding.left)
            if let rightAccessoryView = rightAccessoryView {
                make.trailing.equalTo(rightAccessoryView.snp.leading).offset(-padding.right)
            } else {
                make.trailing.equalToSuperview().inset(padding.right)
            }
        }
        
        rightAccessoryView?.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(padding.right)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
    }
    
    private func updatePlaceholder() {
        let placeholderText = textField.placeholder ?? ""
        var fontAtrribute = FontSystem.body02_semiBold.getAttributes()
        fontAtrribute[.foregroundColor] = UIColor.grayScale400
        let attributedString = NSAttributedString(string: placeholderText, attributes: fontAtrribute)
        if isRequiredMark {
            let requiredMark = NSMutableAttributedString(string: " *", attributes: [NSAttributedString.Key.foregroundColor: UIColor.cmPrimaryColor])
            requiredMark.insert(attributedString, at: 0)
            textField.attributedPlaceholder =  requiredMark
        }
    }
}

// MARK: - Base Picker View Delegate
extension CMPickerTextField: BasePickerViewControllerDelegate {
    func disable() {
        borderView.layer.borderColor = UIColor.cmBorderColor.cgColor
    }
    
    func didSelectItem(_ item: String) {
        textField.text = item
        textField.textColor = .cmHeadLineTextColor
        borderView.layer.borderColor = UIColor.cmBorderColor.cgColor
        if let currentText = self.textField.text {
            self.textField.attributedText = NSAttributedString(string: currentText, attributes: FontSystem.body02_medium.getAttributes())
        }
    }
}
