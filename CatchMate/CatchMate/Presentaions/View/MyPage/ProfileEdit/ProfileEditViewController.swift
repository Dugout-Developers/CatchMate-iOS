//
//  ProfileEditViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 8/2/24.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import FlexLayout
import PinLayout

final class ProfileEditViewController: BaseViewController, View {
    private var initImageStr: String?
    let imgPicker = UIImagePickerController()
    override var useSnapKit: Bool {
        return false
    }
    override var buttonContainerExists: Bool {
        return true
    }
    var reactor: ProfileEditReactor
    private let containerView = UIView()
    private let section1 = UIView()
    private let profileImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "profile"))
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    private let imageEditButton = ProfileImageEditButton()
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임"
        label.applyStyle(textStyle: FontSystem.body02_medium)
        label.textColor = .cmNonImportantTextColor
        return label
    }()
    private let nicknameVaildateLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.applyStyle(textStyle: FontSystem.caption01_semiBold)
        return label
    }()
    
    private let nicknameCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0/10"
        label.applyStyle(textStyle: FontSystem.body02_medium)
        label.textColor = .cmNonImportantTextColor
        return label
    }()
    private let nicknameTextField = CMTextField(placeHolder: "닉네임을 입력해주세요")
    
    private let teamSection = UIView()
    private let teamLabel: UILabel = {
        let label = UILabel()
        label.text = "나의 응원 구단"
        label.applyStyle(textStyle: FontSystem.body02_medium)
        label.textColor = .cmNonImportantTextColor
        return label
    }()
    private let teamPicker = CMPickerTextField(placeHolder: "응원 구단을 선택해주세요", isFlex: true)
    
    private let cheerStyleSection = UIView()
    private let cheerStyleLabel: UILabel = {
        let label = UILabel()
        label.text = "나의 응원 스타일"
        label.applyStyle(textStyle: FontSystem.body02_medium)
        label.textColor = .cmNonImportantTextColor
        return label
    }()
    private let cheerStylePicker = CMPickerTextField(placeHolder: "응원 스타일을을 선택해보세요", isFlex: true)
    private let buttonContainer = UIView()
    private let saveButton = CMDefaultFilledButton(title: "완료")
    
    init(reactor: ProfileEditReactor, imageString: String?) {
        self.reactor = reactor
        self.initImageStr = imageString
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.pin.left().right().top(view.pin.safeArea).above(of: saveButton)
        buttonContainer.pin.left().right().bottom(view.pin.safeArea).height(72)
        containerView.flex.layout()
        buttonContainer.flex.layout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLeftTitle("프로필 편집")
        setupUI()
        setupPicker()
        bind(reactor: reactor)
        view.backgroundColor = .grayScale50
        imgPicker.delegate = self
        imgPicker.allowsEditing = true
        setupImage()
    }
    private func setupImage() {
        if let imgStr = initImageStr {
            ImageLoadHelper.urlToUIImage(imgStr) { [weak self] image in
                self?.reactor.action.onNext(.changeImage(image))
            }
        }
        ImageLoadHelper.loadImage(profileImageView, pictureString: initImageStr)
    }
    private func setupPicker() {
        // Team Picker
        teamPicker.parentViewController = self
        teamPicker.pickerViewController = TeamFilterViewController(reactor: reactor)
        teamPicker.customDetent = BasePickerViewController.returnCustomDetent(height: SheetHeight.large, identifier: "ProfileEditTeamPicker")
        
        // CheerStyle Picker
        cheerStylePicker.parentViewController = self
        cheerStylePicker.pickerViewController = CheerStylePickerViewController(reactor: reactor)
        cheerStylePicker.customDetent = BasePickerViewController.returnCustomDetent(height: SheetHeight.large, identifier: "ProfileEditCheerStylePicker")
    }
}
// MARK: - ImagePicker
extension ProfileEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            if let validImage = UIImage(data: image.jpegData(compressionQuality: 0.5)!) {
                reactor.action.onNext(.changeImage(validImage))
            } else {
                print("이미지가 유효하지 않습니다.")
            }
        }
        dismiss(animated: true, completion: nil)
    }
}
// MARK: - Bind
extension ProfileEditViewController {
    private func openLibrary(){
        imgPicker.sourceType = .photoLibrary
        present(imgPicker, animated: false, completion: nil)
    }
    func bind(reactor: ProfileEditReactor) {
        imageEditButton.rx.tap
            .withUnretained(self)
            .subscribe { vc, _ in
                PhotoPermissionService.shared.checkPermission(from: self) { result in
                    if result {
                        self.openLibrary()
                    }
                }
            }
            .disposed(by: disposeBag)
        self.nicknameTextField.text = reactor.currentState.nickname
        self.nicknameTextField.applyStyle(textStyle: FontSystem.body02_semiBold)
        self.nicknameCountLabel.text = "\(reactor.currentState.nickNameCount)/10"
        self.nicknameCountLabel.applyStyle(textStyle: FontSystem.body02_medium)
        
        nicknameTextField.rx.text.orEmpty
            .distinctUntilChanged()
            .withUnretained(self)
            .map { vc, text in
                let string = String(text.trimmingCharacters(in: .whitespaces).prefix(10))
                vc.nicknameTextField.text = string
                vc.nicknameTextField.applyStyle(textStyle: FontSystem.body02_semiBold)
                return string
            }
            .map { Reactor.Action.changeNickname($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .throttle(.seconds(3), latest: false, scheduler: MainScheduler.instance)
            .withUnretained(self)
            .subscribe {vc,  _ in
                if reactor.currentState.nickNameValidate == .failed {
                    vc.showToast(message: "중복된 닉네임입니다.", buttonContainerExists: true)
                } else {
                    reactor.action.onNext(.editProfile)
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.editProfileSucess}
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe { vc, state in
                if state {
                    vc.navigationController?.popViewController(animated: true)
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.nickname}
            .withUnretained(self)
            .subscribe { vc, nickname in
                vc.nicknameTextField.text = nickname
                vc.nicknameTextField.applyStyle(textStyle: FontSystem.body02_semiBold)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.nickNameCount}
            .withUnretained(self)
            .subscribe { vc, count in
                vc.nicknameCountLabel.text = "\(count)/10"
                vc.nicknameCountLabel.applyStyle(textStyle: FontSystem.body02_medium)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.team}
            .withUnretained(self)
            .subscribe { vc, team in
                vc.teamPicker.didSelectItem(team.rawValue)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.cheerStyle}
            .withUnretained(self)
            .subscribe { vc, style in
                var text = ""
                if let style = style {
                    text = style.rawValue + " 스타일"
                }
                vc.cheerStylePicker.didSelectItem(text)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.profileImage}
            .withUnretained(self)
            .subscribe { vc, image in
                vc.profileImageView.image = image
            }
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.error}
            .compactMap{$0}
            .withUnretained(self)
            .subscribe { vc, error in
                vc.handleError(error)
            }
            .disposed(by: disposeBag)

        nicknameTextField.rx.text.orEmpty
            .skip(1)
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .map { _ in Reactor.Action.endEditNickname }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        nicknameTextField.rx.controlEvent(.editingDidEnd)
            .map { Reactor.Action.endEditNickname }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.nickNameValidate}
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe(onNext: { vc, state in
                vc.nicknameVaildateLabel.text = state.rawValue
                switch state {
                case .none:
                    vc.nicknameVaildateLabel.textColor = .white
                case .success:
                    vc.nicknameVaildateLabel.textColor = .cmSystemBule
                case .failed:
                    vc.nicknameVaildateLabel.textColor = .cmSystemRed
                }
                vc.nicknameVaildateLabel.applyStyle(textStyle: FontSystem.caption01_semiBold)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UI
extension ProfileEditViewController {
    private func setupUI() {
        view.addSubviews(views: [containerView, buttonContainer])
        containerView.flex.width(100%).backgroundColor(.grayScale50).define { flex in
            flex.addItem(section1).direction(.column).backgroundColor(.white).justifyContent(.start).alignItems(.center).paddingHorizontal(MainGridSystem.getMargin()).define { flex in
                flex.addItem().define({ flex in
                    flex.addItem(profileImageView).size(68).cornerRadius(68/2)
                    flex.addItem(imageEditButton).size(68).cornerRadius(68/2).position(.absolute).all(0)
                }).marginTop(16).marginBottom(24)
                
                flex.addItem().direction(.row).width(100%).justifyContent(.spaceBetween).alignItems(.center).define { flex in
                    flex.addItem(nicknameLabel)
                    flex.addItem(nicknameCountLabel)
                }.marginBottom(12)
                flex.addItem(nicknameTextField).marginBottom(4).width(100%)
                flex.addItem(nicknameVaildateLabel).marginBottom(20).width(100%).height(UIFont.caption01_semiBold.pointSize)
            }.marginBottom(8)
            flex.addItem(teamSection).direction(.column).backgroundColor(.white).justifyContent(.start).alignItems(.start).paddingHorizontal(MainGridSystem.getMargin()).define { flex in
                flex.addItem().direction(.row).width(100%).justifyContent(.start).alignItems(.center).define { flex in
                    let requiredMark = UIImageView(image: UIImage(named: "requiredMark"))
                    requiredMark.contentMode = .scaleAspectFit
                    flex.addItem(teamLabel).marginTop(20).marginRight(3)
                    flex.addItem(requiredMark).size(6)
                }.marginBottom(12)
                flex.addItem(teamPicker).marginBottom(20).width(100%)
            }.marginBottom(8)
            flex.addItem(cheerStyleSection).direction(.column).backgroundColor(.white).justifyContent(.start).alignItems(.start).paddingHorizontal(MainGridSystem.getMargin()).define { flex in
                flex.addItem(cheerStyleLabel).marginTop(20).marginBottom(12)
                flex.addItem(cheerStylePicker).marginBottom(20).width(100%)
            }.marginBottom(8)
        }
        buttonContainer.flex.direction(.column).justifyContent(.start).alignItems(.center).define { flex in
            flex.addItem(saveButton).height(52).width(100%)
        }.marginHorizontal(ButtonGridSystem.getMargin()).backgroundColor(.grayScale50)
    }
}

final class ProfileImageEditButton: UIButton {
    private let dimView = UIView()
    private let iconImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        setupViews()
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        // Dim View 설정
        dimView.backgroundColor = .opacity600
        dimView.isUserInteractionEnabled = false
        addSubview(dimView)
        
        // Icon ImageView 설정
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.image = UIImage(systemName: "camera")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        iconImageView.tintColor = .white
        iconImageView.isUserInteractionEnabled = false
        addSubview(iconImageView)
        
        // SnapKit 제약 조건
        dimView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(24)
        }
    }
}
extension Reactive where Base: ProfileImageEditButton {
    var tap: ControlEvent<Void> {
        return controlEvent(.touchUpInside)
    }
}
