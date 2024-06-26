//
//  InputFavoriteTeamViewContoller.swift
//  CatchMate
//
//  Created by 방유빈 on 6/25/24.
//

import UIKit
import FlexLayout
import PinLayout
import ReactorKit
import RxSwift
import RxCocoa

final class InputFavoriteTeamViewContoller: UIViewController, View {
    var disposeBag = DisposeBag()
    var reactor: SignReactor
    
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    private let teamButtonTapPublisher = PublishSubject<Team>().asObserver()
    
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
        label.text = "응원구단을 알려주세요."
        label.adjustsFontSizeToFitWidth = true
        label.font = .systemFont(ofSize: 28)
        label.textColor = .cmHeadLineTextColor
        return label
    }()
    
    private let requiredMark: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "requiredMark")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let teamButtons: [SignSelectedButton<Team>] = {
        var buttons: [SignSelectedButton<Team>] = []
        Team.allTeamFull.forEach { team in
            let teamButton = SignSelectedButton<Team>(item: team)
            buttons.append(teamButton)
        }
        return buttons
    }()
    
    private let nextButton: CMDefaultFilledButton = {
        let button = CMDefaultFilledButton()
        button.setTitle("다음", for: .normal)
        button.isEnabled = false
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
                vc.teamButtons.forEach { teamButton in
                    if teamButton.item == state.team {
                        teamButton.isSelected = true
                    }
                }
            }).disposed(by: disposeBag)
    }
}
// MARK: - Button
extension InputFavoriteTeamViewContoller {
    private func setupButton() {
        nextButton.addTarget(self, action: #selector(clickNextButton), for: .touchUpInside)
        teamButtons.forEach { button in
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(clickTeamButton))
            button.addGestureRecognizer(tapGesture)
        }
    }
    
    @objc
    private func clickNextButton(_ sender: UIButton) {
        navigationController?.pushViewController(InputCheerStyleViewController(reactor: reactor), animated: true)
    }
    
    @objc
    private func clickTeamButton(_ sender: UITapGestureRecognizer) {
        guard let teamButton = sender.view as? SignSelectedButton<Team> else { return }
        teamButtons.forEach { button in
            if teamButton == button {
                button.isSelected = true
                teamButtonTapPublisher.onNext(button.item)
            } else {
                button.isSelected = false
            }
        }
    }
}

// MARK: - bind
extension InputFavoriteTeamViewContoller {
    func bind(reactor: SignReactor) {
        teamButtonTapPublisher
            .map { Reactor.Action.updateTeam($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        reactor.state
            .map {"\($0.nickName)님의"}
            .bind(to: titleLabel1.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isTeamSelected }
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: disposeBag)

    }
}

// MARK: - UI
extension InputFavoriteTeamViewContoller {
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.flex.marginHorizontal(24).define { flex in
            flex.addItem().direction(.column).justifyContent(.start).alignItems(.start).define { flex in
                flex.addItem(titleLabel1).marginTop(48).marginBottom(4)
                flex.addItem().direction(.row).alignItems(.center).define { flex in
                    flex.addItem(titleLabel2).marginRight(6)
                    flex.addItem(requiredMark).size(6)
                }.marginBottom(40)
                for i in stride(from: 0, to: teamButtons.count, by: 3) {
                    flex.addItem().width(100%).direction(.row).justifyContent(.spaceBetween).define { flex in
                        for j in i..<min(i+3, teamButtons.count) {
                            flex.addItem(teamButtons[j]).grow(1).shrink(1).basis(0%).marginHorizontal(j % 3 == 1 ? 9 : 0)
                        }
                    }.marginBottom(12)
                }
                flex.addItem(nextButton).width(100%).height(50).marginTop(56)
            }
        }
    }
}


                                                                            
