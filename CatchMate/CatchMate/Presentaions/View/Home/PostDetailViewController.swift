//
//  PostDetailViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 7/15/24.
//

import UIKit
import FlexLayout
import PinLayout
import RxSwift
import ReactorKit

extension Reactive where Base: PostDetailViewController {
    var isFavoriteState: Observable<Bool> {
        return base._isFavorite.asObservable()
    }
}
final class PostDetailViewController: BaseViewController, View {
    private var isFavorite: Bool = false {
        didSet {
            _isFavorite.onNext(isFavorite)
        }
    }
    fileprivate var _isFavorite = PublishSubject<Bool>()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let partyNumberLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmPrimaryColor
        return label
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmHeadLineTextColor
        return label
    }()
    private let matchInfoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmNonImportantTextColor
        return label
    }()
    private let writerContainer: UIView = UIView()
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    private let nickNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmHeadLineTextColor
        return label
    }()
    private let cheerTeam = TeamPaddingLabel()
    private let genderLabel: DefaultsPaddingLabel = {
        let label = DefaultsPaddingLabel()
        label.textColor = .cmHeadLineTextColor
        label.backgroundColor = .grayScale50
        return label
    }()
    private let ageLabel: DefaultsPaddingLabel = {
        let label = DefaultsPaddingLabel()
        label.textColor = .cmHeadLineTextColor
        label.backgroundColor = .grayScale50
        return label
    }()
    private let navigatorImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "cm20right")?.withTintColor(.cmNonImportantTextColor, renderingMode: .alwaysOriginal))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let homeTeamImageView = ListTeamImageView()
    private let homeTeamLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmHeadLineTextColor
        return label
    }()
    private let awayTeamImageView = ListTeamImageView()
    private let awayTeamLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmHeadLineTextColor
        return label
    }()
    private let vsLabel: UILabel = {
        let label = UILabel()
        label.text = "VS"
        label.applyStyle(textStyle: FontSystem.body03_medium)
        label.textColor = .cmNonImportantTextColor
        return label
    }()
    
    private let addInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "추가 정보"
        label.applyStyle(textStyle: FontSystem.body02_medium)
        label.textColor = .cmNonImportantTextColor
        return label
    }()
    private let addInfoText: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .cmHeadLineTextColor
        return label
    }()
    private let addOptionLabel: UILabel = {
        let label = UILabel()
        label.text = "선호 사항"
        label.applyStyle(textStyle: FontSystem.body02_medium)
        label.textColor = .cmNonImportantTextColor
        return label
    }()
    private var ageOptionLabel = [DefaultsPaddingLabel]()
    private let genderOptionLabel: DefaultsPaddingLabel = {
        let label = DefaultsPaddingLabel(padding: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        label.textColor = .cmNonImportantTextColor
        label.backgroundColor = .grayScale50
        label.layer.cornerRadius = 18
        return label
    }()
    private let buttonContainer = UIView()
    private let favoriteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "favoriteGray_filled")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.backgroundColor = .grayScale50
        button.clipsToBounds = true
        button.layer.cornerRadius = 8
        return button
    }()
    private let applyButton = CMDefaultFilledButton(title: "직관 신청")
    
    var reactor: PostReactor
    
    init(postID: String) {
        self.reactor = PostReactor(postId: postID)
        super.init(nibName: nil, bundle: nil)
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind(reactor: reactor)
        reactor.action.onNext(.loadPostDetails)
        reactor.action.onNext(.loadIsApplied)
        reactor.action.onNext(.loadIsFavorite)
        setupUI()
        setupNavigation()
        setTextStyle()
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
    
    private func setupNavigation() {
        let reportButton = UIButton()
        reportButton.setImage(UIImage(named: "cm20kebab")?.withTintColor(.cmHeadLineTextColor, renderingMode: .alwaysOriginal), for: .normal)
        customNavigationBar.addRightItems(items: [reportButton])
    }
    
    private func setupData(post: Post) {
        partyNumberLabel.text = "\(post.currentPerson)/\(post.maxPerson)"
        titleLabel.text = post.title
        matchInfoLabel.text = "\(post.date) | \(post.playTime) | \(post.location)"
        // TODO: - API UseCase 연결시 프로필 링크 가져오는걸로 바꾸기
        profileImageView.image = UIImage(named: "profile")
        nickNameLabel.text = post.writer.nickName
        cheerTeam.setTeam(team: post.writer.team)
        genderLabel.text = post.writer.gener.rawValue
        ageLabel.text = "\(post.writer.age)"
        homeTeamImageView.setupTeam(team: post.homeTeam, isMyTeam: post.homeTeam == post.writer.team)
        homeTeamLabel.text = post.homeTeam.rawValue
        awayTeamImageView.setupTeam(team: post.awayTeam, isMyTeam: post.awayTeam == post.writer.team)
        if post.homeTeam != post.writer.team {
            homeTeamImageView.setBacgroundColor(.white)
        }
        if post.awayTeam != post.writer.team {
            awayTeamImageView.setBacgroundColor(.white)
        }
        awayTeamLabel.text = post.awayTeam.rawValue
        if post.addInfo != nil {
            addInfoText.text = post.addInfo
        } else {
            addInfoText.text = "작성한 추가 정보가 없습니다."
            addInfoText.textColor = .cmNonImportantTextColor
        }
        if post.preferAge.isEmpty {
            ageOptionLabel.append(makePreferAgeLabel(ageText: "전연령"))
        } else {
            post.preferAge.forEach { age in
                ageOptionLabel.append(makePreferAgeLabel(ageText: String(age)))
            }
        }
        if let gender = post.preferGender {
            genderOptionLabel.text = gender.rawValue
        } else {
            genderOptionLabel.text = "성별무관"
        }
    }
    
    private func setTextStyle() {
        partyNumberLabel.applyStyle(textStyle: FontSystem.body03_semiBold)
        titleLabel.applyStyle(textStyle: FontSystem.bodyTitle)
        matchInfoLabel.applyStyle(textStyle: FontSystem.body02_medium)
        nickNameLabel.applyStyle(textStyle: FontSystem.body02_medium)
        cheerTeam.applyStyle(textStyle: FontSystem.caption01_medium)
        genderLabel.applyStyle(textStyle: FontSystem.caption01_medium)
        ageLabel.applyStyle(textStyle: FontSystem.caption01_medium)
        homeTeamLabel.applyStyle(textStyle: FontSystem.body02_medium)
        awayTeamLabel.applyStyle(textStyle: FontSystem.body02_medium)
        addInfoText.applyStyle(textStyle: FontSystem.bodyTitle)
        
        genderOptionLabel.applyStyle(textStyle: FontSystem.body02_semiBold)
        ageOptionLabel.forEach { label in
            label.applyStyle(textStyle: FontSystem.body02_semiBold)
        }
    }
    
    private func makePreferAgeLabel(ageText: String) -> DefaultsPaddingLabel {
        let label = DefaultsPaddingLabel(padding: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        label.textColor = .cmNonImportantTextColor
        label.text = ageText
        label.backgroundColor = .grayScale50
        label.layer.cornerRadius = 18
        return label
    }
}

// MARK: - bind
extension PostDetailViewController {
    func bind(reactor: PostReactor) {
        reactor.state.map{ $0.post }
            .compactMap{$0}
            .distinctUntilChanged()
            .bind(onNext: setupData)
            .disposed(by: disposeBag)
        
        reactor.state.map{ $0.isFavorite }
            .distinctUntilChanged() // 초기 상태가 전달되지 않는 문제를 방지
            .withUnretained(self)
            .subscribe(onNext: { vc, state in
                vc.isFavorite = state // 상태를 직접 설정
                vc.setupFavoriteButton(state)
            })
            .disposed(by: disposeBag)
        _isFavorite
            .map{Reactor.Action.changeFavorite($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        favoriteButton.rx.tap
            .withUnretained(self)
            .subscribe { vc, _ in
                vc.isFavorite.toggle()
            }
            .disposed(by: disposeBag)
        
        applyButton.rx.tap
            .withUnretained(self)
            .subscribe { vc, _ in
                guard let post = vc.reactor.currentState.post else { return }
                let applyVC = ApplyPopupViewController(post: post, reactor: reactor)
                applyVC.modalPresentationStyle = .overFullScreen
                applyVC.modalTransitionStyle = .crossDissolve
                vc.present(applyVC, animated: true)
            }
            .disposed(by: disposeBag)
        
        applyButton.rx.tap
            .withUnretained(self)
            .subscribe { vc, _ in
                guard let post = vc.reactor.currentState.post else { return }
                let applyVC = ApplyPopupViewController(post: post, reactor: reactor)
                applyVC.modalPresentationStyle = .overFullScreen
                applyVC.modalTransitionStyle = .crossDissolve
                vc.present(applyVC, animated: true)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.isApplied}
            .withUnretained(self)
            .subscribe(onNext: { vc, state in
                vc.updateApplyButton(state)
            })
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.isFinished}
            .withUnretained(self)
            .subscribe(onNext: { vc, state in
                vc.updateApplyButtonFinished(state)
            })
            .disposed(by: disposeBag)
        
    }
    
    private func setupFavoriteButton(_ state: Bool) {
        if state {
            favoriteButton.setImage(UIImage(named: "favoriteGray_filled")?.withTintColor(.cmPrimaryColor, renderingMode: .alwaysOriginal), for: .normal)
        } else {
            favoriteButton.setImage(UIImage(named: "favoriteGray_filled")?.withRenderingMode(.alwaysOriginal), for: .normal)
        }
    }
    
    private func updateApplyButton(_ state: Bool) {
        if state {
            applyButton.isEnabled = false
            applyButton.setTitle("신청 완료", for: .normal)
            applyButton.applyStyle(textStyle: FontSystem.body02_semiBold)
        } else {
            applyButton.isEnabled = true
            applyButton.setTitle("직관 신청", for: .normal)
            applyButton.applyStyle(textStyle: FontSystem.body02_semiBold)
        }
    }
    
    private func updateApplyButtonFinished(_ state: Bool) {
        if state {
            applyButton.isEnabled = false
            applyButton.setTitle("신청 마감", for: .normal)
            applyButton.applyStyle(textStyle: FontSystem.body02_semiBold)
        }
    }
}

// MARK: - UI
extension PostDetailViewController {
    private func setupUI() {
        view.addSubviews(views: [scrollView, buttonContainer])
        scrollView.addSubview(contentView)
        contentView.flex.paddingHorizontal(MainGridSystem.getMargin()).define { flex in
            flex.addItem().width(100%).direction(.column).justifyContent(.start).alignItems(.start).define { flex in
                flex.addItem(partyNumberLabel)
                flex.addItem(titleLabel).marginVertical(8)
                flex.addItem(matchInfoLabel)
            }.marginTop(20).marginBottom(16)
            flex.addItem(writerContainer).direction(.row).width(100%).justifyContent(.spaceBetween).alignItems(.center).define { flex in
                flex.addItem().direction(.row).justifyContent(.start).alignItems(.center).define { flex in
                    flex.addItem(profileImageView).width(48).aspectRatio(1).cornerRadius(24).marginRight(8)
                    flex.addItem().direction(.column).justifyContent(.start).alignItems(.start).grow(1).define { flex in
                        flex.addItem(nickNameLabel).marginBottom(6).grow(1)
                        flex.addItem().direction(.row).justifyContent(.start).alignItems(.start).define { flex in
                            flex.addItem(cheerTeam)
                            flex.addItem(genderLabel).marginHorizontal(6)
                            flex.addItem(ageLabel)
                        }
                    }
                } // 프로필 정보
                flex.addItem(navigatorImageView).size(20)
            } // 프로필 정보 전체 셀
            let divider1 = UIView()
            flex.addItem(divider1).height(1).width(100%).backgroundColor(.grayScale50).marginVertical(16)
            flex.addItem().direction(.row).width(100%).justifyContent(.center).alignItems(.center).backgroundColor(.grayScale50).cornerRadius(5).paddingVertical(12).define { flex in
                flex.addItem().direction(.column).justifyContent(.start).alignItems(.center).define { flex in
                    flex.addItem(homeTeamImageView).width(50).height(67).marginBottom(8)
                    flex.addItem(homeTeamLabel)
                }
                flex.addItem(vsLabel).marginHorizontal(24)
                flex.addItem().direction(.column).justifyContent(.start).alignItems(.center).define { flex in
                    flex.addItem(awayTeamImageView).width(50).height(67).marginBottom(8)
                    flex.addItem(awayTeamLabel)
                }
            } // 경기 팀 정보 컨테이너
            let divider2 = UIView()
            flex.addItem(divider2).height(1).width(100%).backgroundColor(.grayScale50).marginVertical(16)
            flex.addItem(addInfoLabel).marginBottom(12)
            flex.addItem(addInfoText).marginBottom(10)
            let divider3 = UIView()
            flex.addItem(divider3).height(1).width(100%).backgroundColor(.grayScale50).marginBottom(22)
            flex.addItem(addOptionLabel).marginBottom(12)
            flex.addItem().direction(.row).wrap(.wrap).justifyContent(.start).define { flex in
                ageOptionLabel.forEach { label in
                    flex.addItem(label).marginRight(10).marginBottom(8)
                }
                flex.addItem(genderOptionLabel).marginRight(10).marginBottom(8)
            }
        } // contentView
        
        buttonContainer.flex.direction(.row).marginHorizontal(ButtonGridSystem.getMargin()).marginVertical(10).define { flex in
            flex.addItem(favoriteButton).height(52).width(ButtonGridSystem.getColumnWidth(totalWidht: Screen.width)).marginRight(ButtonGridSystem.getGutter())
            flex.addItem(applyButton).grow(1)
        }
    }
}
