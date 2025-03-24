//
//  ApplyPopupViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 7/16/24.
//

import UIKit
import FlexLayout
import PinLayout
import ReactorKit
import RxSwift

final class ApplyPopupViewController: UIViewController, View {
    var post: Post
    var apply: MyApplyInfo?
    var disposeBag: DisposeBag = DisposeBag()
    var reactor: PostReactor
    private let topContentsPadding = 36.0
    private let bottomContentsPadding = 36.0
    private let horizontalContentsPadding = 24.0
    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = .opacity400
        return view
    }()
    
    private let alertView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = .white
        view.layer.masksToBounds = false
        return view
    }()
    
    private let infoTextLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .cmNonImportantTextColor
        return label
    }()
    
    private let homeTeamImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        return imageView
    }()
    private let vsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .cmNonImportantTextColor
        label.text = "VS"
        label.applyStyle(textStyle: FontSystem.body03_medium)
        return label
    }()
    private let awayTeamImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        return imageView
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .cmHeadLineTextColor
        label.text = "직관 신청을 보낼까요?"
        label.applyStyle(textStyle: FontSystem.bodyTitle)
        return label
    }()
    
    private let textView: DefaultsTextView = {
        let textView = DefaultsTextView()
        textView.backgroundColor = .grayScale50
        textView.placeholder = "간단한 자기소개를 적어주세요"
        return textView
    }()
    private let primaryButton: UIButton = {
        let button = UIButton()
        button.setTitle("신청", for: .normal)
        button.setTitleColor(.cmPrimaryColor, for: .normal)
        button.applyStyle(textStyle: FontSystem.body02_medium)
        button.backgroundColor = .white
        button.tintColor = .clear
        return button
    }()
    
    private let commonButton: UIButton = {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
        button.setTitleColor(.cmHeadLineTextColor, for: .normal)
        button.applyStyle(textStyle: FontSystem.body02_medium)
        button.backgroundColor = .white
        button.tintColor = .clear
        return button
    }()
    
    private let horizontralDivider = UIView()
    private let verticalDivider = UIView()
   
    init(post: Post, reactor: PostReactor, apply: MyApplyInfo?) {
        self.post = post
        self.reactor = reactor
        self.apply = apply
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
        bind(reactor: reactor)
        view.tappedDismissKeyboard()
    }
    
    private func setupView() {
        infoTextLabel.text = "\(post.date) | \(post.playTime) | \(post.location)"
        infoTextLabel.applyStyle(textStyle: FontSystem.body02_medium)
        homeTeamImageView.image = post.homeTeam.getLogoImage
        homeTeamImageView.backgroundColor = post.writer.favGudan == post.homeTeam ? post.homeTeam.getTeamColor : .white
        awayTeamImageView.image = post.awayTeam.getLogoImage
        awayTeamImageView.backgroundColor = post.writer.favGudan == post.awayTeam ? post.awayTeam.getTeamColor : .white
        if let text = apply?.addInfo {
            titleLabel.text = "직관 신청을 보냈어요"
            titleLabel.applyStyle(textStyle: FontSystem.bodyTitle)
            textView.text = text
            textView.applyStyle(textStyle: FontSystem.body02_medium)
            textView.isEditable = false
            primaryButton.setTitle("확인", for: .normal)
            primaryButton.applyStyle(textStyle: FontSystem.body02_medium)
            commonButton.setTitle("신청 취소", for: .normal)
            commonButton.applyStyle(textStyle: FontSystem.body02_medium)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        dimView.pin.all()
        dimView.flex.layout()
    }
    private func setupUI() {
        view.addSubview(dimView)
        
        dimView.flex.direction(.column).alignItems(.center).justifyContent(.center).paddingHorizontal(50).define { flex in
            flex.addItem(alertView).direction(.column).justifyContent(.start).width(100%).alignItems(.center).paddingTop(topContentsPadding).paddingHorizontal(horizontalContentsPadding).define { flex in
                flex.addItem(infoTextLabel).marginBottom(12)
                flex.addItem().direction(.row).justifyContent(.center).alignItems(.center).define { flex in
                    flex.addItem(homeTeamImageView).size(50)
                    flex.addItem(vsLabel).marginHorizontal(24)
                    flex.addItem(awayTeamImageView).size(50)
                }.marginBottom(16)
                flex.addItem(titleLabel).marginBottom(16)
                flex.addItem(textView).width(100%).height(100).marginHorizontal(24).marginBottom(bottomContentsPadding)
                flex.addItem(horizontralDivider).width(100%).height(1).backgroundColor(.grayScale100)
                flex.addItem().direction(.row).justifyContent(.start).alignItems(.center).width(100%).paddingTop(16).paddingBottom(24).define { flex in
                    flex.addItem(commonButton).grow(1).shrink(0).basis(0%)
                    flex.addItem(verticalDivider).width(1).height(18).backgroundColor(.grayScale100)
                    flex.addItem(primaryButton).grow(1).shrink(0).basis(0%)
                }
            }
        }
    }
}

// MARK: - Bind: Post Reactor
extension ApplyPopupViewController {
    func bind(reactor: PostReactor) {
        commonButton.rx.tap
            .throttle(.seconds(3), latest: false, scheduler: MainScheduler.instance)
            .withUnretained(self)
            .subscribe { vc, _ in
                if vc.apply != nil {
                    // 이미 보낸 신청 취소하기
                    reactor.action.onNext(.cancelApply)
                }
                vc.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        primaryButton.rx.tap
            .throttle(.seconds(3), latest: false, scheduler: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                if vc.apply != nil {
                    vc.dismiss(animated: true)
                } else {
                    // 신청하기
                    let text = vc.textView.text
                    reactor.action.onNext(.apply(text))
                    vc.dismiss(animated: true)
                }
            })
            .disposed(by: disposeBag)

        reactor.state.map{$0.error}
            .compactMap{$0}
            .withUnretained(self)
            .subscribe { vc, error in
                vc.showToast(message: error.errorDescription ?? "문제가 생겼어요\n다시 시도해주세요.")
            }
            .disposed(by: disposeBag)
    }
}

