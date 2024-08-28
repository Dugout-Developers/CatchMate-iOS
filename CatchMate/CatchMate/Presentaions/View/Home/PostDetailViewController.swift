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
import Kingfisher

extension Reactive where Base: PostDetailViewController {
    var isFavoriteState: Observable<Bool> {
        return base._isFavorite.asObservable()
    }
}
final class PostDetailViewController: BaseViewController, View {
    private var isFirstFavoriteState: Bool = true
    private var isFavorite: Bool = false {
        didSet {
            _isFavorite.onNext(isFavorite)
        }
    }
    fileprivate var _isFavorite = PublishSubject<Bool>()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let isAddView: Bool
    // 기본 게시글 정보
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmHeadLineTextColor
        label.numberOfLines = 0
        return label
    }()
    private var ageOptionLabel = [DefaultsPaddingLabel]()
    private var genderOptionLabel = DefaultsPaddingLabel()
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmNonImportantTextColor
        label.text = "일시"
        label.applyStyle(textStyle: FontSystem.body02_medium)
        return label
    }()
    private let dateValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmHeadLineTextColor
        return label
    }()
    private let placeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmNonImportantTextColor
        label.text = "장소"
        label.applyStyle(textStyle: FontSystem.body02_medium)
        return label
    }()
    private let placeValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmHeadLineTextColor
        return label
    }()
    private let partynumLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmNonImportantTextColor
        label.text = "인원"
        label.applyStyle(textStyle: FontSystem.body02_medium)
        return label
    }()
    private let partynumValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmHeadLineTextColor
        return label
    }()
    private let homeTeamImageView = TeamImageView()
    private let awayTeamImageView = TeamImageView()
    private let vsLabel: UILabel = {
        let label = UILabel()
        label.text = "VS"
        label.applyStyle(textStyle: FontSystem.body03_medium)
        label.textColor = .cmNonImportantTextColor
        return label
    }()

    // 작성자 정보
    private let wirterInfoView = UIView()
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
    private let cheerTeam: DefaultsPaddingLabel = {
        let label = DefaultsPaddingLabel(padding: UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4))
        label.layer.cornerRadius = 2
        label.textColor = .white
        return label
    }()
    private var cheerStyleLabel: DefaultsPaddingLabel? = {
        let label = DefaultsPaddingLabel(padding: UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4))
        label.layer.cornerRadius = 2
        label.textColor = .white
        label.backgroundColor = .cmPrimaryColor
        return label
    }()
    
    private let genderLabel: DefaultsPaddingLabel = {
        let label = DefaultsPaddingLabel(padding: UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4))
        label.layer.cornerRadius = 2
        label.textColor = .cmHeadLineTextColor
        label.backgroundColor = .grayScale100
        return label
    }()
    private let ageLabel: DefaultsPaddingLabel = {
        let label = DefaultsPaddingLabel(padding: UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4))
        label.layer.cornerRadius = 2
        label.textColor = .cmHeadLineTextColor
        label.backgroundColor = .grayScale50
        return label
    }()
    private let navigatorImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "cm20right")?.withTintColor(.cmNonImportantTextColor, renderingMode: .alwaysOriginal))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    // 추가정보
    private let addInfoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmNonImportantTextColor
        label.text = "추가 정보"
        label.applyStyle(textStyle: FontSystem.body02_medium)
        return label
    }()
    private let addInfoValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmHeadLineTextColor
        return label
    }()
    
    // 버튼
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
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let tabBarController = tabBarController as? TabBarController, isAddView {
            tabBarController.isAddView = false
            tabBarController.selectedIndex = tabBarController.preViewControllerIndex
        }
    }
    init(postID: String, isAddView: Bool = false) {
        self.reactor = DIContainerService.shared.makePostReactor(postID)
        self.isAddView = isAddView
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
//        reactor.action.onNext(.loadIsApplied)
//        reactor.action.onNext(.loadIsFavorite)
        setupUI()
        setupNavigation()
        setupButton()
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
        reportButton.showsMenuAsPrimaryAction = true
        reportButton.menu = createMenu()
        customNavigationBar.addRightItems(items: [reportButton])
    }
    
    private func createMenu() -> UIMenu {
        let pullUpAction = UIAction(title: "끌어올리기", image: nil) { _ in
            print("끌어올리기 선택됨")
        }
        
        let editAction = UIAction(title: "게시글 수정", image: nil) { _ in
            print("게시글 수정 선택됨")
        }
        
        let deleteAction = UIAction(title: "게시글 삭제", image: nil, attributes: .destructive) { _ in
            print("게시글 삭제 선택됨")
        }
        
        return UIMenu(title: "", children: [pullUpAction, editAction, deleteAction])
    }
    
    private func setupData(post: Post) {
        if let date = DateHelper.shared.toDate(from: post.date, format: "MM.dd") {
            let dateString = DateHelper.shared.toString(from: date, format: "M월 d일")
            dateValueLabel.text = "\(dateString) | \(post.playTime)"
        } else {
            dateValueLabel.text = "\(post.date) | \(post.playTime)"
        }
        titleLabel.text = post.title
        placeValueLabel.text = post.location
        partynumValueLabel.text = "\(post.maxPerson)명"
        ProfileImageHelper.loadImage(profileImageView, pictureString: post.writer.picture)
        nickNameLabel.text = post.writer.nickName
        cheerTeam.backgroundColor = post.writer.favGudan.getTeamColor
        cheerTeam.text = post.writer.favGudan.rawValue
        if let cheerStyle = post.writer.cheerStyle {
            cheerStyleLabel?.text = cheerStyle.rawValue
            cheerStyleLabel?.applyStyle(textStyle: FontSystem.caption01_medium)
        } else {
            cheerStyleLabel = nil
        }
        genderLabel.text = post.writer.gender.rawValue
        ageLabel.text = post.writer.ageRange
        homeTeamImageView.setupTeam(team: post.homeTeam, isMyTeam: post.homeTeam == post.writer.favGudan)
        awayTeamImageView.setupTeam(team: post.awayTeam, isMyTeam: post.awayTeam == post.writer.favGudan)

        if post.addInfo != nil {
            addInfoValueLabel.text = post.addInfo
        } else {
            addInfoValueLabel.text = "작성한 추가 정보가 없습니다."
            addInfoValueLabel.textColor = .cmNonImportantTextColor
        }
        if post.preferAge.isEmpty {
            ageOptionLabel.append(makePreferPaddingLabel(text: "전연령"))
        } else {
            post.preferAge.forEach { age in
                ageOptionLabel.append(makePreferPaddingLabel(text: String(age)+"대"))
            }
        }
        if let gender = post.preferGender {
            genderOptionLabel = makePreferPaddingLabel(text: gender.rawValue)
        } else {
            genderOptionLabel = makePreferPaddingLabel(text: "성별 무관")
        }
        setTextStyle()
        titleLabel.flex.markDirty()
        dateValueLabel.flex.markDirty()
        placeValueLabel.flex.markDirty()
        partynumValueLabel.flex.markDirty()
        cheerTeam.flex.markDirty()
        cheerStyleLabel?.flex.markDirty()
        genderLabel.flex.markDirty()
        ageLabel.flex.markDirty()
        addInfoValueLabel.flex.markDirty()
        ageOptionLabel.forEach { label in
            label.flex.markDirty()
        }
        nickNameLabel.flex.markDirty()
        genderOptionLabel.flex.markDirty()
        contentView.flex.layout(mode: .adjustHeight)
    }
    
    private func setupButton() {
        let pushUserPageGesture = UITapGestureRecognizer(target: self, action: #selector(pushUserPage))
        wirterInfoView.addGestureRecognizer(pushUserPageGesture)
        
    }
    
    @objc private func pushUserPage(_ sender: UITapGestureRecognizer) {
        if let user = reactor.currentState.post?.writer {
            let userPageVC = OtherUserMyPageViewController(user: user, reactor: OtherUserpageReactor())
            navigationController?.pushViewController(userPageVC, animated: true)
        } else {
            showToast(message: "해당 사용자 정보에 접근할 수 없습니다. 다시 시도해주세요.", buttonContainerExists: true)
        }
    }
    
    private func setTextStyle() {
        titleLabel.applyStyle(textStyle: FontSystem.headline03_medium)
        genderOptionLabel.applyStyle(textStyle: FontSystem.caption01_reguler)
        ageOptionLabel.forEach { label in
            label.applyStyle(textStyle: FontSystem.caption01_reguler)
        }
        dateValueLabel.applyStyle(textStyle: FontSystem.body02_medium)
        placeValueLabel.applyStyle(textStyle: FontSystem.body02_medium)
        partynumValueLabel.applyStyle(textStyle: FontSystem.body02_medium)
        nickNameLabel.applyStyle(textStyle: FontSystem.body02_medium)
        cheerTeam.applyStyle(textStyle: FontSystem.caption01_medium)
        genderLabel.applyStyle(textStyle: FontSystem.caption01_medium)
        ageLabel.applyStyle(textStyle: FontSystem.caption01_medium)
        addInfoValueLabel.applyStyle(textStyle: FontSystem.body02_medium)
    }
    
    private func makePreferPaddingLabel(text: String) -> DefaultsPaddingLabel {
        let label = DefaultsPaddingLabel(padding: UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8))
        label.textColor = .cmNonImportantTextColor
        label.text = text
        label.backgroundColor = .grayScale100
        label.layer.cornerRadius = 10
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
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe(onNext: { vc, state in
                vc.isFavorite = state // 상태를 직접 설정
                vc.setupFavoriteButton(state)
                if vc.isFavorite && !vc.isFirstFavoriteState {
                    vc.showToast(message: "게시글을 저장했어요", buttonContainerExists: true)
                }
            })
            .disposed(by: disposeBag)

        _isFavorite
            .observe(on: MainScheduler.asyncInstance)
            .map{Reactor.Action.changeFavorite($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        favoriteButton.rx.tap
            .withUnretained(self)
            .subscribe { vc, _ in
                if vc.isFirstFavoriteState {
                    vc.isFirstFavoriteState = false
                }
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
        
        reactor.state.map{$0.error}
            .compactMap{$0}
            .withUnretained(self)
            .subscribe { vc, error in
                vc.showToast(message: "요청에 실패했습니다. 다시 시도해주세요.", buttonContainerExists: true)
            }
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
        scrollView.backgroundColor = .grayScale50
        scrollView.addSubview(contentView)
        contentView.flex.backgroundColor(.grayScale50).define { flex in
            // 게시글 정보
            flex.addItem().backgroundColor(.white).width(100%).direction(.column).justifyContent(.start).alignItems(.start).define { flex in
                flex.addItem(titleLabel).marginBottom(6)
                flex.addItem().direction(.row).wrap(.wrap).justifyContent(.start).define { flex in
                    ageOptionLabel.forEach { label in
                        flex.addItem(label).marginRight(4).marginBottom(4)
                    }
                    flex.addItem(genderOptionLabel).marginRight(4).marginBottom(4)
                }.marginBottom(16) // 선호사항 뱃지
                flex.addItem().direction(.column).justifyContent(.start).alignItems(.start).define({ flex in
                    flex.addItem().direction(.row).justifyContent(.start).alignItems(.center).define { flex in
                        flex.addItem(dateLabel).marginRight(20)
                        flex.addItem(dateValueLabel)
                    } // 일시
                    flex.addItem().direction(.row).justifyContent(.start).alignItems(.center).define { flex in
                        flex.addItem(placeLabel).marginRight(20)
                        flex.addItem(placeValueLabel)
                    }.marginVertical(8) // 구장
                    flex.addItem().direction(.row).justifyContent(.start).alignItems(.center).define { flex in
                        flex.addItem(partynumLabel).marginRight(20)
                        flex.addItem(partynumValueLabel)
                    } // 인원
                }).marginBottom(16)
                flex.addItem().direction(.row).justifyContent(.center).alignItems(.center).width(100%).paddingVertical(16).backgroundColor(.grayScale50).cornerRadius(8).define { flex in
                    flex.addItem(homeTeamImageView).width(48).aspectRatio(1)
                    flex.addItem(vsLabel).marginHorizontal(24)
                    flex.addItem(awayTeamImageView).width(48).aspectRatio(1)
                }
            }.paddingTop(12).paddingBottom(16).paddingHorizontal(MainGridSystem.getMargin()).marginBottom(8)
            
            // 작성자 정보
            flex.addItem(wirterInfoView).backgroundColor(.white).width(100%).direction(.row).justifyContent(.spaceBetween).alignItems(.center).define { flex in
                flex.addItem().direction(.row).justifyContent(.start).alignItems(.center).define { flex in
                    flex.addItem(profileImageView).size(48).cornerRadius(24).marginRight(8)
                    flex.addItem().direction(.column).justifyContent(.start).alignItems(.start).define { flex in
                        flex.addItem(nickNameLabel).marginBottom(6)
                        flex.addItem().direction(.row).justifyContent(.start).alignItems(.start).define { flex in
                            flex.addItem(cheerTeam).marginRight(4)
                            if let cheerStyleLabel = cheerStyleLabel {
                                flex.addItem(cheerStyleLabel).marginRight(4)
                            }
                            flex.addItem(genderLabel).marginRight(4)
                            flex.addItem(ageLabel)
                        }
                    }
                }.grow(1)
                flex.addItem(navigatorImageView).size(20)
            }.paddingHorizontal(MainGridSystem.getMargin()).paddingVertical(16).marginBottom(8)
            
            // 추가 정보
            flex.addItem().backgroundColor(.white).width(100%).direction(.column).justifyContent(.start).alignItems(.start).define { flex in
                flex.addItem(addInfoLabel).marginBottom(12)
                flex.addItem(addInfoValueLabel)
            }.paddingHorizontal(MainGridSystem.getMargin()).paddingTop(16).paddingBottom(22)
        } // contentView

        buttonContainer.flex.direction(.row).paddingHorizontal(ButtonGridSystem.getMargin()).paddingVertical(10).define { flex in
            flex.addItem(favoriteButton).height(52).width(ButtonGridSystem.getColumnWidth(totalWidht: Screen.width)).marginRight(ButtonGridSystem.getGutter())
            flex.addItem(applyButton).grow(1)
        }
    }
}
