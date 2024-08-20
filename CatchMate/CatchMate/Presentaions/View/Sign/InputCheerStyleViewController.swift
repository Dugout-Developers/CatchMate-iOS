//
//  InputCheerStyleViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 6/26/24.
//

import UIKit
import FlexLayout
import PinLayout
import ReactorKit
import RxSwift
import RxCocoa

final class InputCheerStyleViewController: BaseViewController, View {
    var reactor: SignReactor
    var signUpReactor: SignUpReactor?
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    private let styleButtonTapPublisher = PublishSubject<CheerStyles?>().asObserver()
    
    private let titleLabel1: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .cmHeadLineTextColor
        return label
    }()
    
    private let titleLabel2: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = "응원스타일을 알려주세요."
        label.adjustsFontSizeToFitWidth = true
        label.applyStyle(textStyle: FontSystem.highlight)
        label.textColor = .cmHeadLineTextColor
        return label
    }()
    
    private let requiredMark: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = "선택"
        label.adjustsFontSizeToFitWidth = true
        label.applyStyle(textStyle: FontSystem.caption01_semiBold)
        label.textColor = .cmNonImportantTextColor
        return label
    }()
    
    private let styleButtons: [CheerStyleButton] = {
        var buttons: [CheerStyleButton] = []
        CheerStyles.allCheerStyles.forEach { team in
            let teamButton = CheerStyleButton(item: team)
            buttons.append(teamButton)
        }
        return buttons
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
        setupButton()
        setupNavigation()
        bind(reactor: reactor)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.pin.all(view.pin.safeArea)
        containerView.pin.top().left().right()
        
        containerView.flex.layout(mode: .adjustHeight)
        scrollView.contentSize = containerView.frame.size
    }
    
    private func setupNavigation() {
        let indicatorImage = UIImage(named: "indicator03")
        let indicatorImageView = UIImageView(image: indicatorImage)
        indicatorImageView.contentMode = .scaleAspectFit
        
        indicatorImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // UIImageView의 높이 제약 조건을 설정
        NSLayoutConstraint.activate([
            indicatorImageView.heightAnchor.constraint(equalToConstant: 6),
            indicatorImageView.widthAnchor.constraint(equalToConstant: indicatorImage?.getRatio(height: 6) ?? 30.0) // width도 설정해주는 것이 좋습니다.
        ])
        
        customNavigationBar.addRightItems(items: [indicatorImageView])
    }
    
    private func setupView() {
        view.backgroundColor = .white
        reactor.state
            .withUnretained(self)
            .subscribe(onNext: { vc, state in
                vc.styleButtons.forEach { style in
                    if style.item == state.cheerStyle {
                        style.isSelected = true
                    }
                }
            }).disposed(by: disposeBag)
    }
}
// MARK: - Button
extension InputCheerStyleViewController {
    private func setupButton() {
        styleButtons.forEach { button in
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(clickStyleButton))
            button.addGestureRecognizer(tapGesture)
        }
    }
    
    @objc
    private func clickStyleButton(_ sender: UITapGestureRecognizer) {
        guard let styleButton = sender.view as? CheerStyleButton else { return }
        styleButtons.forEach { button in
            if styleButton == button {
                button.isSelected = !button.isSelected
                styleButtonTapPublisher.onNext(button.isSelected ? button.item : nil)
            } else {
                button.isSelected = false
            }
        }
    }
}

// MARK: - bind
extension InputCheerStyleViewController {
    func bind(reactor: SignReactor) {
        styleButtonTapPublisher
            .map { Reactor.Action.updateCheerStyle($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .withUnretained(self)
            .subscribe { vc, _ in
                if let model = reactor.currentState.signUpModel {
                    vc.signUpReactor = DIContainerService.shared.makeSignUpReactor(model, loginModel: reactor.loginModel)
                    vc.bindSignUp(reactor: vc.signUpReactor!)
                    vc.signUpReactor?.action.onNext(.signUpUser)
                } else {
                    vc.showToast(message: "회원가입에 실패했습니다. 입력 값을 다시 확인해주세요.")
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map {"\($0.nickName)님의"}
            .withUnretained(self)
            .bind(onNext: { vc, text in
                vc.titleLabel1.text = text
                vc.titleLabel1.applyStyle(textStyle: FontSystem.highlight)
            })
            .disposed(by: disposeBag)

    }
}

extension InputCheerStyleViewController {
    func bindSignUp(reactor: SignUpReactor) {
        reactor.state.map{$0.signupResponse}
            .compactMap{$0}
            .withUnretained(self)
            .subscribe { vc, response in
                LoggerService.shared.log("bindSingUp: - SignUp success \(response)")
                vc.navigateToNextPage()
            }
            .disposed(by: disposeBag)
    }
    
    private func navigateToNextPage() {
        // Logic to navigate to the next page
        let nextViewController = SignUpFinishedViewController()
        navigationController?.pushViewController(nextViewController, animated: true)
    }
}

// MARK: - UI
extension InputCheerStyleViewController {
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.flex.marginHorizontal(24).define { flex in
            flex.addItem().direction(.column).justifyContent(.start).alignItems(.start).define { flex in
                flex.addItem(titleLabel1).marginTop(48).marginBottom(4)
                flex.addItem().direction(.row).alignItems(.center).define { flex in
                    flex.addItem(titleLabel2).marginRight(6)
                    flex.addItem(requiredMark)
                }.marginBottom(40)
                for i in stride(from: 0, to: styleButtons.count, by: 2) {
                    flex.addItem().width(100%).direction(.row).justifyContent(.spaceBetween).define { flex in
                        for j in i..<min(i+2, styleButtons.count) {
                            flex.addItem(styleButtons[j]).grow(1).shrink(1).basis(0%).marginHorizontal(j % 2 == 1 ? 9 : 0)
                        }
                    }.marginBottom(12)
                }
                flex.addItem(nextButton).width(100%).height(50).marginTop(56)
            }
        }
    }
}
