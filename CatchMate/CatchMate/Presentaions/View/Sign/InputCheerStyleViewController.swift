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

final class InputCheerStyleViewController: UIViewController, View {
    var disposeBag = DisposeBag()
    var reactor: SignReactor
    
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    private let styleButtonTapPublisher = PublishSubject<CheerStyles?>().asObserver()
    
    private let titleLabel1: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.font = .systemFont(ofSize: 28)
        label.textColor = .cmHeadLineTextColor
        return label
    }()
    
    private let titleLabel2: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = "응원스타일을 알려주세요."
        label.adjustsFontSizeToFitWidth = true
        label.font = .systemFont(ofSize: 28)
        label.textColor = .cmHeadLineTextColor
        return label
    }()
    
    private let requiredMark: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = "선택"
        label.adjustsFontSizeToFitWidth = true
        label.font = .systemFont(ofSize: 11)
        label.textColor = .cmNonImportantTextColor
        return label
    }()
    
    private let styleButtons: [SignSelectedButton<CheerStyles>] = {
        var buttons: [SignSelectedButton<CheerStyles>] = []
        CheerStyles.allCheerStyles.forEach { team in
            let teamButton = SignSelectedButton(item: team)
            buttons.append(teamButton)
        }
        return buttons
    }()
    
    private let nextButton: CMDefaultFilledButton = {
        let button = CMDefaultFilledButton()
        button.setTitle("다음", for: .normal)
        return button
    }()

    
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
        bind(reactor: reactor)
        configNavigationBackButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.pin.all()
        containerView.pin.top().left().right()
        
        containerView.flex.layout(mode: .adjustHeight)
        scrollView.contentSize = containerView.frame.size
    }
    
    private func setupView() {
        view.backgroundColor = .white
        view.tappedDismissKeyboard()
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
        guard let styleButton = sender.view as? SignSelectedButton<CheerStyles> else { return }
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
            .map { Reactor.Action.signUpUser }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .map {"\($0.nickName)님의"}
            .bind(to: titleLabel1.rx.text)
            .disposed(by: disposeBag)
        
        
        reactor.state
            .map { $0.isSignUp }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isSignUp in
                if isSignUp == true {
                    self?.navigateToNextPage()
                } else if isSignUp == false {
                    self?.showErrorAlert()
                }
            })
            .disposed(by: disposeBag)

    }
    
    private func navigateToNextPage() {
            // Logic to navigate to the next page
            let nextViewController = SignUpFinishedViewController(reactor: reactor)
            navigationController?.pushViewController(nextViewController, animated: true)
        }
        
        private func showErrorAlert() {
            let alert = UIAlertController(title: "Error", message: "Sign up failed.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
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
