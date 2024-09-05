//
//  SignUpViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 6/24/24.
//

import UIKit
import FlexLayout
import PinLayout
import ReactorKit
import RxSwift
import RxCocoa

final class SignUpViewController: BaseViewController, View {
    var reactor: SignReactor
    
    private let containerView = UIView()
    private let titleLabel1: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = "딱맞는 직관 친구를 구하기 위해"
        label.adjustsFontSizeToFitWidth = true
        label.applyStyle(textStyle: FontSystem.highlight)
        label.textColor = .cmHeadLineTextColor
        return label
    }()
    private let titleLabel2: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = "정보를 입력해주세요."
        label.adjustsFontSizeToFitWidth = true
        label.applyStyle(textStyle: FontSystem.highlight)
        label.textColor = .cmHeadLineTextColor
        return label
    }()
    private let requiredMark: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "requiredMark")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let nickNameLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임"
        label.applyStyle(textStyle: FontSystem.contents)
        label.textColor = .cmNonImportantTextColor
        return label
    }()
    private let countLabel: UILabel = {
        let label = UILabel()
        label.text = "0/10"
        label.applyStyle(textStyle: FontSystem.contents)
        label.textAlignment = .right
        label.textColor = .cmNonImportantTextColor
        return label
    }()
    
    private let nickNameTextField = CMTextField(placeHolder: "닉네임을 입력해주세요")
    private let vaildateLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.applyStyle(textStyle: FontSystem.caption01_semiBold)
        return label
    }()
    private let birthLabel: UILabel = {
        let label = UILabel()
        label.text = "생년월일"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .cmNonImportantTextColor
        return label
    }()
    
    private let birthTextField: CMTextField = {
        let textField = CMTextField(placeHolder: "생년월일을 입력해주세요 예) 000000")
        textField.keyboardType = .numberPad
        return textField
    }()
    
    private let genderLabel: UILabel = {
        let label = UILabel()
        label.text = "성별"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .cmNonImportantTextColor
        return label
    }()
    
    private let womanButton: CMDefaultBorderedButton = {
        let button = CMDefaultBorderedButton(title: "여성")
        button.tag = 1
        return button
    }()
    
    private let manButton: CMDefaultBorderedButton = {
        let button = CMDefaultBorderedButton(title: "남성")
        button.tag = 2
        return button
    }()
    
    private let nextButton = CMDefaultFilledButton(title: "다음")
    
    init(reactor: SignReactor) {
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
        setupNavigation()
        setupButton()
        bind(reactor: reactor)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.pin.all(view.pin.safeArea)
        containerView.flex.layout()
    }
    
    private func setupNavigation() {
        let indicatorImage = UIImage(named: "indicator01")
        let indicatorImageView = UIImageView(image: indicatorImage)
        indicatorImageView.contentMode = .scaleAspectFit
        
        indicatorImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            indicatorImageView.heightAnchor.constraint(equalToConstant: 6),
            indicatorImageView.widthAnchor.constraint(equalToConstant: indicatorImage?.getRatio(height: 6) ?? 30.0)
        ])
        
        customNavigationBar.addRightItems(items: [indicatorImageView])
    }
    
    private func setupView() {
        reactor.state
            .filter({
                !$0.nickName.isEmpty
            })
            .map{$0.nickName}
            .compactMap { $0 }
            .withUnretained(self)
            .bind(onNext: { vc, nickName in
                vc.nickNameTextField.text = nickName
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map {$0.birth}
            .compactMap { $0 }
            .withUnretained(self)
            .bind(onNext: { vc, birth in
                vc.birthTextField.text = birth
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map {$0.gender}
            .compactMap { $0 }
            .withUnretained(self)
            .bind(onNext: { vc, gender in
                switch gender {
                case .woman:
                    vc.manButton.isSelecte = false
                    vc.womanButton.isSelecte = true
                case .man:
                    vc.manButton.isSelecte = true
                    vc.womanButton.isSelecte = false
                case .none:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
}
// MARK: - Button
extension SignUpViewController {
    private func setupButton() {
        nextButton.addTarget(self, action: #selector(clickNextButton), for: .touchUpInside)
    }
    
    @objc
    private func clickNextButton(_ sender: UIButton) {
        navigationController?.pushViewController(InputFavoriteTeamViewContoller(reactor: reactor), animated: true)
    }
}
// MARK: - bind
extension SignUpViewController {
    func bind(reactor: SignReactor) {
        // action (View -> Reactor)
        nickNameTextField.rx.text.orEmpty
            .withUnretained(self)
            .map { vc, text in
                let string = String(text.trimmingCharacters(in: .whitespaces).prefix(10))
                vc.nickNameTextField.text = string
                return string
            }
            .map { Reactor.Action.updateNickname($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        nickNameTextField.rx.text.orEmpty
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .map { _ in Reactor.Action.endEditNickname }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        nickNameTextField.rx.controlEvent(.editingDidEnd)
            .map { Reactor.Action.endEditNickname }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        birthTextField.rx.text.orEmpty
            .withUnretained(self)
            .map { vc, text in
                let string = String(text.replacingOccurrences(of: " ", with: "").prefix(6))
                vc.birthTextField.text = string
                return string
            }
            .map { Reactor.Action.updateBirth($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        manButton.rx.tap
            .withUnretained(self)
            .map { vc, _ in
                vc.manButton.isSelecte = true
                vc.womanButton.isSelecte = false
                return Gender.man
            }
            .map { Reactor.Action.updateGender($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        womanButton.rx.tap
            .withUnretained(self)
            .map { vc, _ in
                vc.manButton.isSelecte = false
                vc.womanButton.isSelecte = true
                return Gender.woman
            }
            .map { Reactor.Action.updateGender($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        // 텍스트 필드 폰트 바인딩
        reactor.state
            .map { $0.nickName }
            .compactMap { $0 }
            .withUnretained(self)
            .bind(onNext: { vc, nickName in
                vc.nickNameTextField.text = nickName
                vc.nickNameTextField.applyStyle(textStyle: FontSystem.body02_semiBold)
            })
            .disposed(by: disposeBag)
        reactor.state
            .map { $0.birth }
            .compactMap{ $0 }
            .withUnretained(self)
            .bind(onNext: { vc, birth in
                vc.birthTextField.text = birth
                vc.birthTextField.applyStyle(textStyle: FontSystem.body02_semiBold)
            })
            .disposed(by: disposeBag)
        
        // state (Reactor -> View)
        reactor.state
            .map {"\($0.nicknameCount)/10"}
            .bind(to: countLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isFormValid }
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.nickNameValidate}
            .distinctUntilChanged()
            .withUnretained(self)
            .bind (onNext: { vc, validateCase in
                vc.vaildateLabel.text = validateCase.rawValue
                switch validateCase {
                case .none:
                    vc.vaildateLabel.textColor = .white
                case .success:
                    vc.vaildateLabel.textColor = .cmSystemBule
                case .failed:
                    vc.vaildateLabel.textColor = .cmSystemRed
                }
                vc.vaildateLabel.applyStyle(textStyle: FontSystem.caption01_semiBold)
            })
            .disposed(by: disposeBag)
        
    }
}

// MARK: - UI
extension SignUpViewController {
    private func setupUI() {
        view.addSubview(containerView)
        let sectionMargin = 32.0
        let itemMargin = 12.0
        
        containerView.flex.direction(.column).marginHorizontal(24).justifyContent(.start).alignItems(.start).define { flex in
            flex.addItem(titleLabel1).marginTop(48).marginBottom(4)
            flex.addItem().direction(.row).alignItems(.center).define { flex in
                flex.addItem(titleLabel2).marginRight(6)
                flex.addItem(requiredMark).size(6)
            }.marginBottom(40)
            flex.addItem().direction(.row).width(100%).justifyContent(.spaceBetween).define { flex in
                flex.addItem(nickNameLabel).grow(1)
                flex.addItem(countLabel).grow(1)
            }.marginBottom(itemMargin)
            flex.addItem(nickNameTextField).width(100%).marginBottom(4)
            flex.addItem(vaildateLabel).height(UIFont.caption01_semiBold.pointSize).width(100%).marginBottom(13)
            flex.addItem(birthLabel).marginBottom(itemMargin)
            flex.addItem(birthTextField).width(100%).marginBottom(sectionMargin)
            flex.addItem(genderLabel).marginBottom(itemMargin)
            flex.addItem().direction(.row).height(50).width(100%).justifyContent(.spaceBetween).define { flex in
                flex.addItem(womanButton).grow(1).marginRight(9)
                flex.addItem(manButton).grow(1)
            }
            flex.addItem().width(100%).grow(1).direction(.column).justifyContent(.end).define { flex in
                flex.addItem(nextButton).width(100%).height(50)
            }
        }
    }
}
