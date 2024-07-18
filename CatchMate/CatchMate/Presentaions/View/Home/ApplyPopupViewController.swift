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
    var disposeBag: DisposeBag = DisposeBag()
    private var reactor: PostReactor
    private var applyReactor: ApplyFormReactor
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
    
    private let applyButton: UIButton = {
        let button = UIButton()
        button.setTitle("신청", for: .normal)
        button.setTitleColor(.cmNonImportantTextColor, for: .normal)
        button.applyStyle(textStyle: FontSystem.body02_medium)
        button.backgroundColor = .white
        button.tintColor = .clear
        return button
    }()
    
    private let cancelButton: UIButton = {
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
   
    init(post: Post, reactor: PostReactor) {
        self.post = post
        self.reactor = reactor
        self.applyReactor = ApplyFormReactor(postId: post.id)
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
    }
    
    private func setupView() {
        infoTextLabel.text = "\(post.date) | \(post.playTime) | \(post.location)"
        infoTextLabel.applyStyle(textStyle: FontSystem.body02_medium)
        homeTeamImageView.image = post.homeTeam.getLogoImage
        homeTeamImageView.backgroundColor = post.writer.team == post.homeTeam ? post.homeTeam.getTeamColor : .white
        awayTeamImageView.image = post.awayTeam.getLogoImage
        awayTeamImageView.backgroundColor = post.writer.team == post.awayTeam ? post.awayTeam.getTeamColor : .white
    
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
                flex.addItem().direction(.row).justifyContent(.start).alignItems(.center).width(100%).paddingTop(16).paddingBottom(24).paddingHorizontal(24).define { flex in
                    flex.addItem(cancelButton).grow(1).shrink(0)
                    flex.addItem(verticalDivider).width(1).height(18).backgroundColor(.grayScale100).marginHorizontal(10)
                    flex.addItem(applyButton).grow(1).shrink(0)
                }
            }
        }
    }
}

// MARK: - Bind
extension ApplyPopupViewController {
    func bind(reactor: PostReactor) {
        cancelButton.rx.tap
            .withUnretained(self)
            .subscribe { vc, _ in
                vc.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        applyButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                let text = vc.textView.text
                // MARK: - 로그인 연결 후 유저 정보 아이디값 연결 필요
                let apply = Apply(postId: vc.post.id, applicantId: "111111", addText: text)
                vc.applyReactor.action.onNext(.requestApplyForm(apply))
            })
            .disposed(by: disposeBag)
        
        applyReactor.state.map{$0.appleyResult}
            .compactMap{$0}
            .withUnretained(self)
            .subscribe { vc, result in
                if result {
                    vc.reactor.action.onNext(.changeIsApplied(true))
                    vc.dismiss(animated: true)
                } else {
                    vc.showToast(message: "신청에 실패했습니다. 다시 시도해주세요.", relativeTo: vc.dimView, using: .flexLayout, anchorPosition: .bottom)
                }
            }
            .disposed(by: disposeBag)
    }
}
