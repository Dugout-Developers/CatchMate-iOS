//
//  AllFilterViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 6/17/24.
//

import UIKit
import SnapKit

final class AllFilterViewController: UIViewController {
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "날짜"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .cmTextGray
        return label
    }()
    
    private let datePickerTextField = CMPickerTextField(rightAccessoryView: UIImageView(image: UIImage(systemName: "calendar")))
    
    private let teamSelectedLabel: UILabel = {
        let label = UILabel()
        label.text = "응원 구단"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .cmTextGray
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .cmBackgroundColor
        setupUI()
        setupPickerView()
    }
    
    private func setupPickerView() {
        datePickerTextField.placeholder = "날짜 선택"
        datePickerTextField.parentViewController = self
        datePickerTextField.pickerViewController = DateFilterViewController()
        datePickerTextField.customDetent = BasePickerViewController.returnCustomDetent(height: Screen.height / 2.0 + 50.0, identifier: "DateFilter")
    }
}

// MARK: - UI
extension AllFilterViewController {
    private func setupUI() {
        view.addSubviews(views: [dateLabel, datePickerTextField, teamSelectedLabel])
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        datePickerTextField.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(16)
            make.leading.trailing.equalTo(dateLabel)
        }
        teamSelectedLabel.snp.makeConstraints { make in
            make.top.equalTo(datePickerTextField.snp.bottom).offset(40)
            make.leading.trailing.equalTo(dateLabel)
        }
    }
}
