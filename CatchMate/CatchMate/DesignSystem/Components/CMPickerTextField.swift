//
//  CMPickerTextField.swift
//  CatchMate
//
//  Created by 방유빈 on 6/17/24.
//

import UIKit

final class CMPickerTextField: UITextField {
    private let padding = UIEdgeInsets(top: 17, left: 16, bottom: 17, right: 30)
    
    private let rightAccessoryView: UIView
    weak var parentViewController: UIViewController?
    var pickerViewController: BasePickerViewController?
    var customDetent: UISheetPresentationController.Detent?
    
    init(rightAccessoryView: UIView) {
        self.rightAccessoryView = rightAccessoryView
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        isEnabled = true
        layer.cornerRadius = 8.0
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.lightGray.cgColor
        textColor = .black
        backgroundColor = .white
        font = UIFont.systemFont(ofSize: 16)
        
        attributedPlaceholder = NSAttributedString(string: placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        rightView = rightAccessoryView
        rightViewMode = .always
        
        inputView = UIView()
        
        addTarget(self, action: #selector(textFieldTapped), for: .editingDidBegin)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    @objc private func textFieldTapped() {
        layer.borderColor = UIColor.cmPrimaryColor.cgColor
        showPicker()
    }
    
    private func showPicker() {
        guard let pickerViewController = pickerViewController else { return }
        pickerViewController.delegate = self
        pickerViewController.modalPresentationStyle = .pageSheet
        if let customDetent = customDetent {
            if let sheet = pickerViewController.sheetPresentationController {
                sheet.detents = [customDetent]
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            }
        }
        parentViewController?.present(pickerViewController, animated: true, completion: nil)
    }
}

extension CMPickerTextField: BasePickerViewControllerDelegate {
    func didSelectItem(_ item: String) {
        self.text = item
        layer.borderColor = UIColor.lightGray.cgColor
    }
}
