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
        return base._selectedAges.asObservable()
    }
}
final class AddViewController: BaseViewController, View {
    override var useSnapKit: Bool {
        return false
    }
    override var buttonContainerExists: Bool {
        return true
    }
    private let reactor: AddReactor
    private var isSaved: Bool = false
    private var placeCount = 0 {
        didSet {
            placePicker.customDetent = BasePickerViewController.returnCustomDetent(height: SheetHeight.tiny - CGFloat((2-placeCount)*50), identifier: "PlaceFilter")
        }
    }
    fileprivate var _selectedGender = PublishSubject<Gender?>()
    fileprivate var _selectedAges = PublishSubject<[Int]>()
    private var selectedGenderLabel: PaddingLabel? {
        didSet {
            if selectedGenderLabel == manButton {
                _selectedGender.onNext(.man)
            } else if selectedGenderLabel == womanButton {
                _selectedGender.onNext(.woman)
            } else if selectedGenderLabel == noGenderButton {
                _selectedGender.onNext(Gender.none)
            } else {
                _selectedGender.onNext(nil)
            }
        }
    }
    private var selectedAges: [Int] = [] {
        didSet {
            _selectedAges.onNext(selectedAges)
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
    private let titleTextField = CMTextField(placeHolder: "제목을 입력해주세요 (20자 제한)")
    private let numberPickerTextField = CMPickerTextField(rightAccessoryView: {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.text = "명"
        label.textColor = UIColor.lightGray
        return label
    }(), placeHolder: "본인 포함 인원", isFlex: true)
    
    private let matchInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "경기 정보"
        label.textColor = .cmNonImportantTextColor
        label.applyStyle(textStyle: FontSystem.body02_medium)
        return label
    }()
    private let datePickerTextField = CMPickerTextField(placeHolder: "경기 날짜 및 시간을 입력해주세요", isFlex: true)
    private let teamSelectedContainerView = UIView()
    private let homeTeamPicker = CMPickerTextField(placeHolder: "홈 구단",isFlex: true)
    private let awayTeamPicker = CMPickerTextField(placeHolder: "원정 구단",isFlex: true)
    private let cheerTeamPicker = CMPickerTextField(placeHolder: "응원 구단 선택", isFlex: true)
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
        textView.placeholder = "내용을 입력해주세요"
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
    private let buttonContainer = UIView()
    private let registerButton = CMDefaultFilledButton(title: "작성 완료")
    
    private let editPost: Post?
    init(reactor: AddReactor, editPost: Post? = nil) {
        self.reactor = reactor
        self.editPost = editPost
        super.init(nibName: nil, bundle: nil)
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if !isSaved{
            reactor.action.onNext(.loadUser)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isSaved {
            isSaved.toggle()
            navigationController?.popViewController(animated: false)
        }
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
        if let editPost = editPost {
            reactor.action.onNext(.setupEditPost(post: editPost))
        } else {
            reactor.action.onNext(.loadTempPost)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let tabBarController = tabBarController as? TabBarController, !isSaved {
            tabBarController.isAddView = false
            tabBarController.selectedIndex = tabBarController.preViewControllerIndex
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.pin.left().right().top(view.pin.safeArea).above(of: buttonContainer)
        buttonContainer.pin.left().right().bottom(view.pin.safeArea).height(72)
        contentView.pin.top().left().right()
        contentView.flex.layout(mode: .adjustHeight)
        buttonContainer.flex.layout()
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
        datePickerTextField.customDetent = BasePickerViewController.returnCustomDetent(height: SheetHeight.dateFilter+90, identifier: "DateFilter")
        
        // numberPicker Setup
        numberPickerTextField.parentViewController = self
        let currentPerson: Int? = editPost == nil ? nil : editPost!.currentPerson - 1
        numberPickerTextField.pickerViewController = NumberPickerViewController(reactor: reactor, disableMaxNumber: currentPerson)
        numberPickerTextField.customDetent = BasePickerViewController.returnCustomDetent(height: SheetHeight.numberFilter, identifier: "NumberFilter")
        
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
    
    func cheerTeamPickerSetup(homeTeam: Team, awayTeam: Team) {
        // PlacePicker Setup
        cheerTeamPicker.parentViewController = self
        cheerTeamPicker.pickerViewController = CheerTeamPickerViewController(reactor: reactor, home: homeTeam, away: awayTeam)
        cheerTeamPicker.customDetent = BasePickerViewController.returnCustomDetent(height: SheetHeight.tiny+65, identifier: "CheerTeamFilter")
    }
    
    private func setupView() {
        view.backgroundColor = .white
    }
    
    private func setupNavigationBar() {
        if editPost == nil {
            let saveButton = UIButton()
            saveButton.setTitle("임시저장", for: .normal)
            saveButton.applyStyle(textStyle: FontSystem.body02_medium)
            saveButton.setTitleColor(.cmHeadLineTextColor, for: .normal)
            saveButton.addTarget(self, action: #selector(clickSaveButton), for: .touchUpInside)
            customNavigationBar.addRightItems(items: [saveButton])
        }
    }
}
// MARK: - Bind
extension AddViewController {
    private func updateAddTextCount(_ count: Int) {
        addTextCount.text = "\(count)/300"
        addTextCount.applyStyle(textStyle: FontSystem.body02_medium)
        addTextCount.flex.markDirty()
        contentView.flex.layout(mode: .adjustHeight)
    }
    func bind(reactor: AddReactor) {
        _selectedGender
            .map{Reactor.Action.changeGender($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        _selectedAges
            .map{Reactor.Action.changeAge($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        registerButton.rx.tap
            .throttle(.seconds(3), latest: false, scheduler: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                if vc.editPost != nil {
                    reactor.action.onNext(.updateEditPost)
                } else {
                    reactor.action.onNext(.updatePost)
                }
            })
            .disposed(by: disposeBag)
        
        titleTextField.rx.text.orEmpty
            .distinctUntilChanged()
            .withUnretained(self)
            .map { vc, text in
                let string = String(text.prefix(20))
                vc.titleTextField.text = string
                return Reactor.Action.changeTitle(string)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        
        textview.rx.text.orEmpty
            .distinctUntilChanged()
            .map { text in
                let string = String(text.prefix(300))
                return string
            }
            .map { Reactor.Action.changeAddText($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.savePostResult}
            .distinctUntilChanged()
            .compactMap{$0}
            .withUnretained(self)
            .subscribe { vc, postId in
                vc.postSavedSuccessfully(postId: "\(postId)")
            }
            .disposed(by: disposeBag)

        reactor.state.map{$0.dateInfoString}
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe { vc, text in
                vc.datePickerTextField.updateDateText(text)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.homeTeam}
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe { vc, team in
                if let team = team {
                    vc.placePicker.isDisable = false
                    vc.homeTeamPicker.didSelectItem(team.rawValue)
                    vc.placePicker.didSelectItem(team.place?[0] ?? "")
                    if let count = team.place?.count{
                        vc.placeCount = count
                    }
                } else {
                    vc.placePicker.isDisable = true
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
        
        reactor.state.map{$0.cheerTeam}
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe { vc, team in
                if let team = team {
                    vc.cheerTeamPicker.didSelectItem(team.rawValue)
                } else {
                    vc.cheerTeamPicker.didSelectItem("")
                }
            }
            .disposed(by: disposeBag)
        reactor.state.map{$0.isDisableCheerTeamPicker}
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe { vc, state in
                vc.cheerTeamPicker.isDisable = state
                if let home = reactor.currentState.homeTeam, let away = reactor.currentState.awayTeam {
                    vc.cheerTeamPickerSetup(homeTeam: home, awayTeam: away)
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.place}
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe { vc, place in
                if let place = place {
                    vc.placePicker.didSelectItem(place)
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.partyNumber}
            .compactMap{$0}
            .withUnretained(self)
            .subscribe { vc, num in
                vc.numberPickerTextField.didSelectItem(String(num))
            }
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.validationMemberCount}
            .distinctUntilChanged()
            .filter{$0}
            .withUnretained(self)
            .subscribe { vc, _ in
                vc.showToast(message: "현재 참여한 인원보다 적은 인원은 선택할 수 없어요", buttonContainerExists: true)
            }
            .disposed(by: disposeBag)

        reactor.state.map{$0.editPost}
            .distinctUntilChanged()
            .compactMap{$0?.title}
            .withUnretained(self)
            .subscribe(onNext: { vc, title in
                vc.titleTextField.text = title
                vc.titleTextField.updateTextStyle()
            })
            .disposed(by: disposeBag)
        Observable.merge(
            reactor.state
                .map { $0.title }
                .distinctUntilChanged()
                .compactMap { $0 }
                .map { _ in }, // 값은 필요 없고 이벤트만 넘기기 위해 Void로 변환

            titleTextField.rx.endEditing
                .map { _ in } // Void 이벤트로 맞춰줌
        )
        .withUnretained(self)
        .subscribe { vc, _ in
            vc.titleTextField.updateTextStyle()
        }
        .disposed(by: disposeBag)
        
        reactor.state.map{$0.addText}
            .compactMap{$0}
            .withUnretained(self)
            .subscribe { vc, text in
                vc.textview.text = text
                vc.textview.updateTextStyle()
                vc.updateAddTextCount(text.count)
                
            }
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.selectedAge}
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe { vc, ages in
                vc.ageButtons.forEach { label in
                    label.isSelected = ages.contains(label.tag * 10)
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.selectedGender}
            .distinctUntilChanged()
            .compactMap{$0}
            .withUnretained(self)
            .subscribe { vc, gender in
                switch gender {
                case .woman:
                    vc.noGenderButton.isSelected = false
                    vc.manButton.isSelected = false
                    vc.womanButton.isSelected = true
                case .man:
                    vc.noGenderButton.isSelected = false
                    vc.manButton.isSelected = true
                    vc.womanButton.isSelected = false
                case .none:
                    vc.noGenderButton.isSelected = true
                    vc.manButton.isSelected = false
                    vc.womanButton.isSelected = false
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.tempPostResult}
            .compactMap{$0}
            .withUnretained(self)
            .subscribe { vc, _ in
                vc.dismiss(animated: true) { [weak self] in
                    guard let self = self else { return }
                    showToast(message: "임시저장이 완료되었어요", buttonContainerExists: true) { [weak self] in
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }
            .disposed(by: disposeBag)
        reactor.state.map{$0.error}
            .compactMap{$0}
            .withUnretained(self)
            .subscribe { vc, error in
                vc.handleError(error)
            }
            .disposed(by: disposeBag)
        reactor.state.map{ $0.loadTempPost != nil }
            .distinctUntilChanged()
            .filter { $0 }
            .withUnretained(self)
            .subscribe { vc, _ in
                vc.showCMAlert(titleText: "임시저장된 글을 불러올까요?", importantButtonText: "불러오기", commonButtonText: "새로작성", importantAction:  { [weak self] in
                    self?.reactor.action.onNext(.setTempPost)
                })
            }
            .disposed(by: disposeBag)
    }
    
    // 작성 완료 후 호출되는 메소드
    private func postSavedSuccessfully(postId: String) {
        let postDetailVC = PostDetailViewController(postID: postId, isAddView: true)
        if let navigationController = self.navigationController {
            isSaved = true
            if reactor.currentState.editPost != nil {
                var viewControllers = navigationController.viewControllers
                if let index = viewControllers.firstIndex(where: { $0 is AddViewController }), let detail = viewControllers.firstIndex(where: { $0 is PostDetailViewController }) {
                    viewControllers.remove(at: index)
                    viewControllers.remove(at: detail)
                }
                navigationController.viewControllers = viewControllers
            }
            navigationController.pushViewController(postDetailVC, animated: true)
        }
    }
}
// MARK: - Button
extension AddViewController {
    @objc private func clickSaveButton(_ sender: UIButton) {
        showCMAlert(titleText: "작성 중인 글을 임시저장할까요?", importantButtonText: "임시저장", commonButtonText: "나가기") { [weak self] in
            self?.reactor.action.onNext(.tempPost)
        } commonAction: { [weak self] in
            self?.dismiss(animated: true, completion: {
                self?.navigationController?.popViewController(animated: true)
            })
        }
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
        if tappedLabel == selectedGenderLabel {
            selectedGenderLabel = nil
        } else {
            selectedGenderLabel = tappedLabel
        }
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
            if ageButtons[0].isSelected {
                selectedAges = []
                ageButtons[0].isSelected = false
            } else {
                selectedAges = [0]
                ageButtons[0].isSelected = true
                ageButtons[1...].forEach { label in
                    label.isSelected = false
                }
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
        view.addSubviews(views: [scrollView, buttonContainer])
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
                flex.addItem(cheerTeamPicker).marginBottom(8)
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
            }
        }
        buttonContainer.flex.direction(.row).marginHorizontal(ButtonGridSystem.getMargin()).alignItems(.center).justifyContent(.center).paddingBottom(34).define { flex in
            flex.addItem(registerButton).grow(1).height(52)
        }
    }
}
