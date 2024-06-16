//
//  DateFilterViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 6/15/24.
//

import UIKit
import SnapKit

final class DateFilterViewController: UIViewController {
    private let datePicker = UIDatePicker()
    private let saveButton: UIButton = {
        let button = UIButton(configuration: .plain())
        button.layer.cornerRadius = 4
        button.backgroundColor = .cmPrimaryColor
        button.setTitleColor(.white, for: .normal)
        button.setTitle("저장", for: .normal)
        button.tintColor = .clear
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupDatePicker()
    }
    private func setupDatePicker() {
        datePicker.tintColor = .cmPrimaryColor
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
    }
}

// MARK: - UI
extension DateFilterViewController {
    private func setupUI() {
        view.addSubviews(views: [datePicker, saveButton])
        
        datePicker.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.leading.trailing.equalToSuperview().inset(12)
        }
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(datePicker.snp.bottom).offset(30)
            make.leading.trailing.equalTo(datePicker)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-30)
            make.height.equalTo(50)
        }
    }
}
