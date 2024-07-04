//
//  NumberPickerView.swift
//  CatchMate
//
//  Created by 방유빈 on 6/18/24.
//

import UIKit

final class NumberPickerViewController: BasePickerViewController {
    private let picker: UIPickerView = UIPickerView()
    private var selectedNum: Int = 1
    private let numberArr: [Int] = [1,2,3,4,5,6,7,8]

    private let saveButton = CMDefaultFilledButton(title: "저장")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupPicker()
        setupButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disable()
    }
    
    private func setupPicker() {
        picker.delegate = self
        picker.dataSource = self
    }
    
    private func setupButton() {
        saveButton.addTarget(self, action: #selector(clickSaveButton), for: .touchUpInside)
    }
    @objc
    private func clickSaveButton(_ sender: UIButton) {
        itemSelected(String(selectedNum))
    }
}

// MARK: - Picker
extension NumberPickerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return numberArr.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedNum = numberArr[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(numberArr[row])명"
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40.0
    }
}
// MARK: - UI
extension NumberPickerViewController {
    private func setupUI() {
        view.addSubviews(views: [picker, saveButton])
        
        picker.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.leading.trailing.equalToSuperview().inset(12)
        }

        saveButton.snp.makeConstraints { make in
            make.top.equalTo(picker.snp.bottom).offset(30)
            make.leading.trailing.equalTo(picker)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-30)
            make.height.equalTo(50)
        }
    }
}



