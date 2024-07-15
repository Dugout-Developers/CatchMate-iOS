//
//  AddViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 6/14/24.
//

import UIKit
import RxSwift
import ReactorKit

extension Reactive where Base: AddViewController {
    var selectedDate: Observable<Gender?> {
        return base._selectedGender.asObservable()
    }
    var selectedAge: Observable<[Int]> {
        return base._selectedAge.asObservable()
    }
}
final class AddViewController: BaseViewController, View {
    private let reactor: AddReactor
    fileprivate var _selectedGender = PublishSubject<Gender?>()
    fileprivate var _selectedAge = PublishSubject<[Int]>()
    private var selectedGenderLabel: PaddingLabel? {
        didSet {
            if selectedGenderLabel == manButton {
                _selectedGender.onNext(.man)
            } else if selectedGenderLabel == womanButton {
                _selectedGender.onNext(.woman)
            } else {
                _selectedGender.onNext(nil)
            }
        }
    }
    private var selectedAges: [Int] = [] {
        didSet {
            _selectedAge.onNext(selectedAges)
        }
    }
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "기본 정보"
        label.textColor = .cmNonImportantTextColor
        label.applyStyle(textStyle: FontSystem.body02_medium)
        return label
    }()
    private let titleTextField = CMTextField(placeHolder: "제목을 입력해주세요.")
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
        label.textColor = .cmNonImportantTextColor
        label.applyStyle(textStyle: FontSystem.body02_medium)
        return label
    }()
    private let datePickerTextField = CMPickerTextField(placeHolder: "날짜 선택", isFlex: true)
    private let teamSelectedContainerView = UIView()
    private let homeTeamPicker = CMPickerTextField(placeHolder: "홈 팀",isFlex: true)
    private let awayTeamPicker = CMPickerTextField(placeHolder: "원정 팀",isFlex: true)
    private let placePicker = CMPickerTextField(placeHolder: "구장 위치", isFlex: true)
    
    private let textInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "추가 정보"
        label.applyStyle(textStyle: FontSystem.body02_medium)
        label.textColor = .cmNonImportantTextColor
        return label
    }()
    
    private let addTextCount: UILabel = {
        let label = UILabel()
        label.text = "0/300"
        label.textColor = .cmNonImportantTextColor
        label.applyStyle(textStyle: FontSystem.body02_medium)
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
    private let noGenderButton: PaddingLabel = PaddingLabel(title: "성별 무관")
    private let womanButton: PaddingLabel = PaddingLabel(title: "여성")
    private let manButton: PaddingLabel = PaddingLabel(title: "남성")
    
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
        ["전연령", "10대", "20대", "30대", "40대", "50대 이상"].enumerated().forEach { i, age in
            let label = PaddingLabel(title: age)
            label.tag = i
            labels.append(label)
        }
        return labels
    }()
    
    private let registerButton = CMDefaultFilledButton(title: "등록")
    init(reactor: AddReactor) {
        self.reactor = reactor
        super.init(nibName: nil, bundle: nil)
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupUI()
        setupPickerView()
        setupRequiredMark()
        setupGenderButton()
        setupAgeButton()
        setupNavigationBar()
        bind(reactor: reactor)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let tabBarController = tabBarController as? TabBarController {
            tabBarController.isAddView = false
            tabBarController.selectedIndex = tabBarController.preViewControllerIndex
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.pin.all(view.pin.safeArea)
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
        datePickerTextField.pickerViewController = DateFilterViewController(reactor: reactor, disposeBag: disposeBag, isAddView: true)
        datePickerTextField.customDetent = BasePickerViewController.returnCustomDetent(height: SheetHeight.medium + 70, identifier: "DateFilter")
        
        // numberPicker Setup
        numberPickerTextField.parentViewController = self
        numberPickerTextField.pickerViewController = NumberPickerViewController()
        numberPickerTextField.customDetent = BasePickerViewController.returnCustomDetent(height: Screen.height / 3.0 + 10.0, identifier: "NumberFilter")
        
        // TeamPicker Setup
        homeTeamPicker.parentViewController = self
        let homeTeamPickerView = TeamFilterViewController(reactor: reactor)
        homeTeamPickerView.isHomeTeam = true
        homeTeamPicker.pickerViewController = homeTeamPickerView
        homeTeamPicker.customDetent = BasePickerViewController.returnCustomDetent(height: SheetHeight.large, identifier: "HomeTeamFilter")
        
        // TeamPicker Setup
        awayTeamPicker.parentViewController = self
        let awayteamPickerView = TeamFilterViewController(reactor: reactor)
        awayteamPickerView.isHomeTeam = false
        awayTeamPicker.pickerViewController = awayteamPickerView
        awayTeamPicker.customDetent = BasePickerViewController.returnCustomDetent(height: SheetHeight.large, identifier: "AwayTeamFilter")
        
        // PlacePicker Setup
        placePicker.parentViewController = self
        placePicker.pickerViewController = PlaceFilterViewController(reactor: reactor)
        placePicker.customDetent = BasePickerViewController.returnCustomDetent(height: SheetHeight.tiny, identifier: "PlaceFilter")
    }
    
    private func setupView() {
        view.backgroundColor = .white
        registerButton.addTarget(self, action: #selector(clickRegisterButton), for: .touchUpInside)
    }
    
    private func setupNavigationBar() {
        customNavigationBar.title = "등록"
        
        let saveButton = UIButton()
        saveButton.setTitle("임시저장", for: .normal)
        saveButton.applyStyle(textStyle: FontSystem.body02_medium)
        saveButton.setTitleColor(.cmHeadLineTextColor, for: .normal)
        saveButton.addTarget(self, action: #selector(clickSaveButton), for: .touchUpInside)
        customNavigationBar.addRightItems(items: [saveButton])
    }
}
// MARK: - Bind
extension AddViewController {
    func bind(reactor: AddReactor) {
        _selectedGender
            .map{Reactor.Action.changeGender($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        _selectedAge
            .map{Reactor.Action.changeAge($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.dateInfoString}
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe { vc, text in
                print(text)
                vc.datePickerTextField.updateDateText(text)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.homeTeam}
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe { vc, team in
                if let team = team {
                    vc.homeTeamPicker.didSelectItem(team.rawValue)
                    vc.placePicker.didSelectItem(team.place?[0] ?? "")
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.awayTeam}
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe { vc, team in
                if let team = team {
                    vc.awayTeamPicker.didSelectItem(team.rawValue)
                }
            }
            .disposed(by: disposeBag)
    }
}
// MARK: - Button
extension AddViewController {
    @objc private func clickSaveButton(_ sender: UIButton) {
        showCMAlert(titleText: "작성 중인 글을 임시저장할까요?", importantButtonText: "임시저장", commonButtonText: "나가기") { [weak self] in
            guard let self = self else { return }
            print("임시저장")
            dismiss(animated: true)
            showToast(message: "임시저장이 완료되었어요", relativeTo: scrollView, using: .flexLayout, anchorPosition: .bottom)
        } commonAction: { [weak self] in
            self?.dismiss(animated: true, completion: {
                self?.navigationController?.popViewController(animated: true)
            })
        }

    }
    
    @objc
    func clickRegisterButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
        print("등록")
    }
    private func setupGenderButton() {
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(clickGenderButton))
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(clickGenderButton))
        let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(clickGenderButton))
        noGenderButton.addGestureRecognizer(tapGesture1)
        womanButton.addGestureRecognizer(tapGesture2)
        manButton.addGestureRecognizer(tapGesture3)
    }
    
    @objc private func clickGenderButton(_ gesture: UITapGestureRecognizer) {
        guard let tappedLabel = gesture.view as? PaddingLabel else { return }
        if tappedLabel == noGenderButton || selectedGenderLabel == tappedLabel {
            // 선택 없음이 곧 전연령?
            selectedGenderLabel = noGenderButton
        } else {
            selectedGenderLabel = tappedLabel
        }
        noGenderButton.isSelected = (selectedGenderLabel == noGenderButton)
        manButton.isSelected = (selectedGenderLabel == manButton)
        womanButton.isSelected = (selectedGenderLabel == womanButton)
    }
    
    private func setupAgeButton() {
        ageButtons.forEach { ageButton in
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(clickAgeButton))
            ageButton.addGestureRecognizer(tapGesture)
        }
    }
    
    @objc private func clickAgeButton(_ gesture: UITapGestureRecognizer) {
        guard let tappedLabel = gesture.view as? PaddingLabel else { return }
        if tappedLabel.tag == 0 {
            selectedAges = []
            ageButtons[0].isSelected = true
            ageButtons[1...].forEach { label in
                label.isSelected = false
            }
        }else {
            ageButtons[0].isSelected = false
            if let index = selectedAges.firstIndex(of: tappedLabel.tag * 10) {
                tappedLabel.isSelected = false
                selectedAges.remove(at: index)
            } else {
                tappedLabel.isSelected = true
                selectedAges.append(tappedLabel.tag * 10)
                if selectedAges.count == 5 {
                    selectedAges = []
                    ageButtons[0].isSelected = true
                    ageButtons[1...].forEach { label in
                        label.isSelected = false
                    }
                }
            }
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
                flex.addItem().direction(.row).justifyContent(.start).alignItems(.center).define { flex in
                    let requiredMark = UIImageView(image: UIImage(named: "requiredMark"))
                    requiredMark.contentMode = .scaleAspectFit
                    flex.addItem(infoLabel).marginRight(3)
                    flex.addItem(requiredMark).size(6)
                }
                flex.addItem(titleTextField).marginVertical(12)
                flex.addItem(numberPickerTextField).marginBottom(32)
                flex.addItem(numberPickerTextField).marginBottom(32)
                
                flex.addItem().direction(.row).justifyContent(.start).alignItems(.center).define { flex in
                    let requiredMark = UIImageView(image: UIImage(named: "requiredMark"))
                    requiredMark.contentMode = .scaleAspectFit
                    flex.addItem(matchInfoLabel).marginRight(3)
                    flex.addItem(requiredMark).size(6)
                }.marginBottom(12)
                flex.addItem(datePickerTextField).marginBottom(8)
                flex.addItem(teamSelectedContainerView).direction(.row).justifyContent(.spaceBetween).alignItems(.center).define { flex in
                    flex.addItem(homeTeamPicker).grow(1).marginRight(9)
                    flex.addItem(awayTeamPicker).grow(1)
                }.marginBottom(8)
                flex.addItem(placePicker).marginBottom(32)
                flex.addItem().direction(.row).justifyContent(.spaceBetween).alignItems(.center).define {flex in
                    flex.addItem().direction(.row).justifyContent(.start).alignItems(.center).define { flex in
                        let requiredMark = UIImageView(image: UIImage(named: "requiredMark"))
                        requiredMark.contentMode = .scaleAspectFit
                        flex.addItem(textInfoLabel).marginRight(3)
                        flex.addItem(requiredMark).size(6)
                    }
                    flex.addItem(addTextCount)
                }.marginBottom(12)
                flex.addItem(textview).height(156).marginBottom(16)
                flex.addItem(genderLabel).marginBottom(12)
                flex.addItem(genderButtonContainer).direction(.row).justifyContent(.start).alignItems(.start).define { flex in
                    flex.addItem(noGenderButton)
                    flex.addItem(womanButton).marginHorizontal(12)
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
