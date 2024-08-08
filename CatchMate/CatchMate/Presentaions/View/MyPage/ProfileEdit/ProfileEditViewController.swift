//
//  ProfileEditViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 8/2/24.
//

import UIKit
import RxSwift
import ReactorKit
import FlexLayout
import PinLayout

final class ProfileEditViewController: BaseViewController, View {
    var reactor: ProfileEditReactor
    private var profileImageString: String?
    private let containerView = UIView()
    private let section1 = UIView()
    private let profileImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "profile"))
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
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
    
    private let nicknameCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0/10"
        label.applyStyle(textStyle: FontSystem.body02_medium)
        label.textColor = .cmNonImportantTextColor
        return label
    }()
    private let nicknameTextField = CMTextField(placeHolder: "닉네임을 입력해주세요")
    init(reactor: ProfileEditReactor, imageString: String?) {
        self.reactor = reactor
        self.profileImageString = imageString
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.pin.all(view.pin.safeArea)
        containerView.flex.layout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLeftTitle("프로필 편집")
        setupUI()
        setupImage()
        bind(reactor: reactor)
    }
    private func setupImage() {
        if let string = profileImageString, let url = URL(string: string) {
            profileImageView.kf.setImage(with: url)
        } else {
            profileImageView.image = UIImage(named: "tempProfile")
        }
    }
}

// MARK: - Bind
extension ProfileEditViewController {
    func bind(reactor: ProfileEditReactor) {
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
// 닉네임 중복 검사 -> 나중에 연결
//        nicknameTextField.rx.text.orEmpty
//            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
//            .distinctUntilChanged()
//            .map { _ in Reactor.Action.endEditNickname }
//            .bind(to: reactor.action)
//            .disposed(by: disposeBag)
//        
//        nicknameTextField.rx.controlEvent(.editingDidEnd)
//            .map { Reactor.Action.endEditNickname }
//            .bind(to: reactor.action)
//            .disposed(by: disposeBag)
    }
}

// MARK: - UI
extension ProfileEditViewController {
    private func setupUI() {
        view.addSubview(containerView)
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
                flex.addItem(nicknameTextField).marginBottom(12).width(100%)
            }
        }
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
           addSubview(dimView)
           
           // Icon ImageView 설정
           iconImageView.contentMode = .scaleAspectFit
           iconImageView.image = UIImage(systemName: "camera")?.withTintColor(.white, renderingMode: .alwaysOriginal)
           iconImageView.tintColor = .white
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
