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
    
    private let datePickerTextField = CMPickerTextField(rightAccessoryView: UIImageView(image: UIImage(systemName: "calendar")), placeHolder: "날짜 선택")
    
    private let teamSelectedLabel: UILabel = {
        let label = UILabel()
        label.text = "응원 구단"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .cmTextGray
        return label
    }()
    
    private let teamCollectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private let peopleNumLabel: UILabel = {
        let label = UILabel()
        label.text = "모집 인원 수"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .cmTextGray
        return label
    }()
    
    private let numberPickerTextField = CMPickerTextField(rightAccessoryView: {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.text = "명"
        label.textColor = UIColor.lightGray
        return label
    }(), placeHolder: "최대 8")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .cmBackgroundColor
        setupUI()
        setupPickerView()
        setupToolBar()
        teamCollectionView.backgroundColor = .red
    }
    
    private func setupToolBar() {
        let saveButton = UIBarButtonItem(title: "저장", style: .plain, target: self, action: #selector(clickSaveButton))
        saveButton.tintColor = .cmPrimaryColor
        navigationItem.rightBarButtonItem = saveButton
    }
    
    private func setupPickerView() {
        // datePicker Setup
        datePickerTextField.parentViewController = self
        datePickerTextField.pickerViewController = DateFilterViewController()
        datePickerTextField.customDetent = BasePickerViewController.returnCustomDetent(height: Screen.height / 2.0 + 50.0, identifier: "DateFilter")
        
        // numberPicker Setup
        numberPickerTextField.parentViewController = self
        numberPickerTextField.pickerViewController = NumberPickerViewController()
        numberPickerTextField.customDetent = BasePickerViewController.returnCustomDetent(height: Screen.height / 3.0 + 10.0, identifier: "NumberFilter")
    }
    
    @objc
    private func clickSaveButton(_ sender: UIBarButtonItem) {
        print("저장")
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UI
extension AllFilterViewController {
    private func setupUI() {
        view.addSubviews(views: [dateLabel, datePickerTextField, teamSelectedLabel, teamCollectionView, peopleNumLabel, numberPickerTextField])
        
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
        teamCollectionView.snp.makeConstraints { make in
            make.top.equalTo(teamSelectedLabel.snp.bottom).offset(16)
            make.leading.trailing.equalTo(dateLabel)
            make.height.equalTo(270)
        }
        peopleNumLabel.snp.makeConstraints { make in
            make.top.equalTo(teamCollectionView.snp.bottom).offset(40)
            make.leading.trailing.equalTo(dateLabel)
        }
        numberPickerTextField.snp.makeConstraints { make in
            make.top.equalTo(peopleNumLabel.snp.bottom).offset(16)
            make.leading.trailing.equalTo(dateLabel)
        }
    }
}
