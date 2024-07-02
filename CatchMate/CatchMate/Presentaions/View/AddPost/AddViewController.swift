//
//  AddViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 6/14/24.
//

import UIKit

final class AddViewController: BaseViewController {
    private var selectedGenderLabel: PaddingLabel?
    private var seletedAgeLabel: PaddingLabel?
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleTextField: CMTextField = {
        let textField = CMTextField()
        textField.placeholder = "제목을 입력해주세요."
        return textField
    }()
    private let numberPickerTextField = CMPickerTextField(rightAccessoryView: {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.text = "명"
        label.textColor = UIColor.lightGray
        return label
    }(), placeHolder: "최대 8", isFlex: true)
    
    private let matchInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "경기 정보"
        label.textColor = .cmTextGray
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    private let datePickerTextField = CMPickerTextField(rightAccessoryView: UIImageView(image: UIImage(systemName: "calendar")), placeHolder: "날짜 선택", isFlex: true)
    private let teamSelectedContainerView = UIView()
    private let homeTeamPicker = CMPickerTextField(placeHolder: "홈 팀",isFlex: true)
    private let vsLabel: UILabel = {
        let label = UILabel()
        label.text = "VS"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .lightGray
        return label
    }()
    private let awayTeamPicker = CMPickerTextField(placeHolder: "원정 팀",isFlex: true)
    private let placePicker = CMPickerTextField(placeHolder: "위치", isFlex: true)
    
    private let textInfoLabel: UILabel = {
        let label = UILabel()
        let text = "추가 정보 *"
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 16), range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(.foregroundColor, value: UIColor.cmTextGray, range: NSRange(location: 0, length: text.count-1))
        if let lastCharacterRange = text.range(of: String(text.last!)) {
            let nsRange = NSRange(lastCharacterRange, in: text)
            attributedString.addAttribute(.foregroundColor, value: UIColor.cmPrimaryColor, range: nsRange)
        }
        label.attributedText = attributedString
        return label
    }()
    private let textview: CMTextView = {
        let textView = CMTextView()
        textView.placeholder = "내용을 입력해주세요."
        return textView
    }()
    
    private let genderLabel: UILabel = {
        let label = UILabel()
        label.text = "선호 성별"
        label.textColor = .cmTextGray
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    private let genderButtonContainer = UIView()
    private let womanButton: PaddingLabel = {
        let label = PaddingLabel()
        label.backgroundColor = UIColor(hex: "#F7F8FA")
        label.textColor = .cmTextGray
        label.text = "여성"
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.layer.cornerRadius = 15
        label.clipsToBounds = true
        label.isUserInteractionEnabled = true
        return label
    }()
    private let manButton: PaddingLabel = {
        let label = PaddingLabel()
        label.backgroundColor = UIColor(hex: "#F7F8FA")
        label.textColor = .cmTextGray
        label.text = "남성"
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.layer.cornerRadius = 15
        label.clipsToBounds = true
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let ageLabel: UILabel = {
        let label = UILabel()
        label.text = "선호 나이대"
        label.textColor = .cmTextGray
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    private let ageContainer = UIView()
    private let ageButtons: [PaddingLabel] = {
        var labels = [PaddingLabel]()
        ["10대", "20대", "30대", "40대", "50대 이상"].forEach { age in
            let label = PaddingLabel()
            label.backgroundColor = UIColor(hex: "#F7F8FA")
            label.textColor = .cmTextGray
            label.text = age
            label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            label.layer.cornerRadius = 15
            label.clipsToBounds = true
            label.isUserInteractionEnabled = true
            labels.append(label)
        }
        return labels
    }()
    
    private let registerButton: CMDefaultFilledButton = {
        let button = CMDefaultFilledButton()
        button.setTitle("등록", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupUI()
        setupPickerView()
        setupRequiredMark()
        setupGenderButton()
        setupAgeButton()
        setupNavigationBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.pin.all()
        contentView.pin.top().left().right()
        
        contentView.flex.layout(mode: .adjustHeight)
        scrollView.contentSize = contentView.frame.size
    }
    
    private func setupRequiredMark() {
        titleTextField.isRequiredMark = true
        numberPickerTextField.isRequiredMark = true
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
    
    private func setupView() {
        view.backgroundColor = .white
        registerButton.addTarget(self, action: #selector(clickRegisterButton), for: .touchUpInside)
    }
    
    private func setupNavigationBar() {
        let saveButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.down"), style: .plain, target: self, action: #selector(clickSaveButton))
        title = "등록"
        navigationItem.rightBarButtonItem = saveButton
    }
}
// MARK: - Button
extension AddViewController {
    @objc
    private func clickSaveButton(_ sender: UIBarButtonItem) {
        print("임시 저장")
    }
    
    @objc
    func clickRegisterButton(_ sender: UIButton) {
        print("등록")
    }
    private func setupGenderButton() {
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(clickGenderButton))
        womanButton.addGestureRecognizer(tapGesture1)
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(clickGenderButton))
        manButton.addGestureRecognizer(tapGesture2)
    }
    
    @objc private func clickGenderButton(_ gesture: UITapGestureRecognizer) {
        guard let tappedLabel = gesture.view as? PaddingLabel else { return }
        
        if selectedGenderLabel != nil {
            selectedGenderLabel?.backgroundColor = UIColor(hex: "#F7F8FA")
            selectedGenderLabel?.textColor = .cmTextGray
        }
        
        if selectedGenderLabel == tappedLabel {
            selectedGenderLabel = nil
        } else {
            tappedLabel.backgroundColor = .cmPrimaryColor
            tappedLabel.textColor = .white
            selectedGenderLabel = tappedLabel
        }
    }
    
    private func setupAgeButton() {
        ageButtons.forEach { ageButton in
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(clickGenderButton))
            ageButton.addGestureRecognizer(tapGesture)
        }
    }
    
    @objc private func clicAgeButton(_ gesture: UITapGestureRecognizer) {
        guard let tappedLabel = gesture.view as? PaddingLabel else { return }
        
        if selectedGenderLabel != nil {
            selectedGenderLabel?.backgroundColor = UIColor(hex: "#F7F8FA")
            selectedGenderLabel?.textColor = .cmTextGray
        }
        
        if selectedGenderLabel == tappedLabel {
            selectedGenderLabel = nil
        } else {
            tappedLabel.backgroundColor = .cmPrimaryColor
            tappedLabel.textColor = .white
            selectedGenderLabel = tappedLabel
        }
    }
}
// MARK: - UI
extension AddViewController {
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.flex.paddingHorizontal(18).define { flex in
            flex.addItem().direction(.column).define { flex in
                flex.addItem(titleTextField).marginVertical(12)
                flex.addItem(numberPickerTextField).marginBottom(32)
                flex.addItem(numberPickerTextField).marginBottom(32)
                
                flex.addItem(matchInfoLabel).marginBottom(16)
                flex.addItem(datePickerTextField).marginBottom(12)
                flex.addItem(teamSelectedContainerView).direction(.row).justifyContent(.spaceBetween).alignItems(.center).define { flex in
                    flex.addItem(homeTeamPicker).grow(1)
                    flex.addItem(vsLabel).marginHorizontal(17)
                    flex.addItem(awayTeamPicker).grow(1)
                }.marginBottom(32)
                flex.addItem(textInfoLabel).marginBottom(12)
                flex.addItem(textview).height(156).marginBottom(16)
                flex.addItem(genderLabel).marginBottom(12)
                flex.addItem(genderButtonContainer).direction(.row).justifyContent(.start).alignItems(.start).define { flex in
                    flex.addItem(womanButton).marginRight(12)
                    flex.addItem(manButton)
                }.marginBottom(32)
                flex.addItem(ageLabel).marginBottom(12)
                flex.addItem(ageContainer).direction(.row).wrap(.wrap).justifyContent(.start).define { flex in
                    ageButtons.forEach { ageButton in
                        flex.addItem(ageButton).marginRight(12).marginBottom(12)
                    }
                }.marginBottom(60)
                flex.addItem(registerButton).height(50).marginBottom(27)
            }
        }
    }
}
