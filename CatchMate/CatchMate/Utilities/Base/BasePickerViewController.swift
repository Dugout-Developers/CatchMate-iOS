//
//  BasePickerViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 6/17/24.
//

import UIKit

protocol BasePickerViewControllerDelegate: AnyObject {
    func didSelectItem(_ item: String)
}

class BasePickerViewController: UIViewController {
    weak var delegate: BasePickerViewControllerDelegate?
    
    func itemSelected(_ item: String) {
        delegate?.didSelectItem(item)
        dismiss(animated: true, completion: nil)
    }
}

extension BasePickerViewController {
    static func returnCustomDetent(height: CGFloat, identifier: String) -> UISheetPresentationController.Detent {
        let detentIdentifier = UISheetPresentationController.Detent.Identifier(identifier)
        let customDetent = UISheetPresentationController.Detent.custom(identifier: detentIdentifier) { _ in
            return height
        }
        return customDetent
    }
}

