//
//  CMPickerTextField.swift
//  CatchMate
//
//  Created by 방유빈 on 6/17/24.
//

import UIKit

final class CMPickerTextField: UIView {
    private let padding = UIEdgeInsets(top: 17, left: 16, bottom: 17, right: 16)
    
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
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.clipsToBounds = true
        return view
    }()
    
    init(rightAccessoryView: UIView, placeHolder: String = "") {
        self.rightAccessoryView = rightAccessoryView
        self.textField.placeholder = placeHolder
        super.init(frame: .zero)
        setupUI()
    }
    
    @available (*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc private func textFieldTapped() {
        borderView.layer.borderColor = UIColor.cmPrimaryColor.cgColor
        showPicker()
    }
    
    private func showPicker() {
        guard let pickerViewController = pickerViewController else { return }
        
        pickerViewController.delegate = self
        pickerViewController.modalPresentationStyle = .pageSheet
        
        if let sheet = pickerViewController.sheetPresentationController {
            sheet.detents = customDetent != nil ? [customDetent!] : [.medium(), .large()]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        
        parentViewController?.present(pickerViewController, animated: true, completion: nil)
    }
}

// MARK: - UI
extension CMPickerTextField {
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(textFieldTapped))
        addGestureRecognizer(tapGesture)
    }
}

// MARK: - Base Picker View Delegate
extension CMPickerTextField: BasePickerViewControllerDelegate {
    func disable() {
        borderView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func didSelectItem(_ item: String) {
        textField.text = item
        borderView.layer.borderColor = UIColor.lightGray.cgColor
    }
}
