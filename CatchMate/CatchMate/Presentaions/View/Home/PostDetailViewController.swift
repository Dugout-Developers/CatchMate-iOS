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


final class PostDetailViewController: BaseViewController, View {
    override var useSnapKit: Bool {
        return false
    }
    override var buttonContainerExists: Bool {
        return false
    }
    private var isFirstFavoriteState: Bool = true
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
    private let ageOptionView: UIView = UIView()
    private var ageOptionLabel: [DefaultsPaddingLabel] = []
    private var genderOptionLabel: DefaultsPaddingLabel = {
        let label = DefaultsPaddingLabel(padding: UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8))
        label.textColor = .cmNonImportantTextColor
        label.applyStyle(textStyle: FontSystem.caption01_reguler)
        label.backgroundColor = .grayScale100
        label.layer.cornerRadius = 10
        return label
    }()
    
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
        imageView.contentMode = .scaleAspectFill
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
    private var cheerStyleLabel: DefaultsPaddingLabel = {
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
        label.backgroundColor = .grayScale100
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
        label.numberOfLines = 0
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
    private let applyButton = ApplyButton()
    
    private let toastSubject = PublishSubject<Void>()
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
        reportButton.addTarget(self, action: #selector(setupMenuButton), for: .touchUpInside)
        customNavigationBar.addRightItems(items: [reportButton])
    }
    
    @objc private func setupMenuButton() {
        let localDataUserId = SetupInfoService.shared.getUserInfo(type: .id)
        let menuVC = CMActionMenu()
        if let currentlocalId = localDataUserId, Int(currentlocalId) != nil, Int(currentlocalId)! == reactor.currentState.post?.writer.userId {
            // 메뉴 항목 설정
            menuVC.menuItems = [
                MenuItem(title: "끌어올리기", action: { [weak self] in
                    self?.reactor.action.onNext(.upPost)
                }),
                MenuItem(title: "게시글 수정", action: { [weak self] in
                    if let post = self?.reactor.currentState.post {
                        let editVC = AddViewController(reactor: DIContainerService.shared.makeAddReactor(), editPost: post)
                        self?.navigationController?.pushViewController(editVC, animated: true)
                    } else {
                        self?.showToast(message: "게시글을 수정하는데 실패했어요\n다시 시도해주세요")
                    }
                }),
                MenuItem(title: "게시글 삭제", textColor: UIColor.cmSystemRed, action: { [weak self] in
                    self?.showCMAlert(titleText: "삭제 시 채팅방도 같이 삭제돼요\n정말로 삭제할까요?", importantButtonText: "삭제", commonButtonText: "취소", importantAction: {
                        self?.reactor.action.onNext(.deletePost)
                    }, commonAction: {
                        self?.dismiss(animated: false)
                    })
                })
            ]
        } else {
            // 메뉴 항목 설정
            menuVC.menuItems = [
                MenuItem(title: "찜하기", action: { [weak self] in
                    if let isFavorite = self?.reactor.currentState.isFavorite, !isFavorite {
                        self?.reactor.action.onNext(.changeFavorite(true))
                    }
                }),
//                MenuItem(title: "공유하기", action: {
//                    print("공유하기 선택됨")
//                }),
                MenuItem(title: "신고하기", textColor: UIColor.cmSystemRed, action: { [weak self] in
                    if let user = self?.reactor.currentState.post?.writer {
                        let reportVC = UserReportViewController(reportUser: user)
                        reportVC.toastSubject = self?.toastSubject
                        self?.navigationController?.pushViewController(reportVC, animated: true)
                    } else {
                        self?.showToast(message: "다시 시도해주세요", buttonContainerExists: true)
                    }
                })
            ]
        }
        // 메뉴 화면을 모달로 표시
        menuVC.modalPresentationStyle = .overFullScreen
        present(menuVC, animated: false, completion: nil)
    }
    
    private func setupData(post: Post) {
        dateValueLabel.text = "\(post.date) | \(post.playTime)"
        titleLabel.text = post.title
        placeValueLabel.text = post.location
        partynumValueLabel.text = "\(post.maxPerson)명"
        ImageLoadHelper.loadImage(profileImageView, pictureString: post.writer.picture)
        nickNameLabel.text = post.writer.nickName
        cheerTeam.backgroundColor = post.writer.favGudan.getTeamColor
        cheerTeam.text = post.writer.favGudan.rawValue
        if let cheerStyle = post.writer.cheerStyle {
            cheerStyleLabel.text = cheerStyle.rawValue
            cheerStyleLabel.applyStyle(textStyle: FontSystem.caption01_medium)
            cheerStyleLabel.flex.display(.flex)
        } else {
            cheerStyleLabel.flex.display(.none)
        }
        genderLabel.text = post.writer.gender.rawValue
        ageLabel.text = post.writer.ageRange
        homeTeamImageView.setupTeam(team: post.homeTeam, isMyTeam: post.homeTeam == post.cheerTeam)
        awayTeamImageView.setupTeam(team: post.awayTeam, isMyTeam: post.awayTeam == post.cheerTeam)

        addInfoValueLabel.text = post.addInfo
        
        if post.preferAge == [0] {
            ageOptionLabel.append(makeAgeLabel(age: 0))
        } else {
            let ageArr = post.preferAge.sorted(by: <)
            ageArr.forEach { age in
                ageOptionLabel.append(makeAgeLabel(age: age))
            }
        }

        if let gender = post.preferGender {
            genderOptionLabel.text = gender.rawValue
        } else {
            genderOptionLabel.isHidden = true
        }
        setTextStyle()
        titleLabel.flex.markDirty()
        dateValueLabel.flex.markDirty()
        placeValueLabel.flex.markDirty()
        partynumValueLabel.flex.markDirty()
        cheerTeam.flex.markDirty()
        cheerStyleLabel.flex.markDirty()
        genderLabel.flex.markDirty()
        ageLabel.flex.markDirty()
        addInfoValueLabel.flex.markDirty()
        ageOptionView.flex.define { flex in
            ageOptionLabel.forEach { label in
                flex.addItem(label).marginRight(4).marginBottom(4)
            }
        }
        nickNameLabel.flex.markDirty()
        genderOptionLabel.flex.markDirty()
        ageOptionView.flex.layout()
        contentView.flex.layout(mode: .adjustHeight)
        buttonContainer.flex.layout()
    }
    
    private func setupButton() {
        let pushUserPageGesture = UITapGestureRecognizer(target: self, action: #selector(pushUserPage))
        wirterInfoView.addGestureRecognizer(pushUserPageGesture)
        
    }
    
    @objc private func pushUserPage(_ sender: UITapGestureRecognizer) {
        if let user = reactor.currentState.post?.writer {
            let userPageVC = OtherUserMyPageViewController(user: user, reactor: DIContainerService.shared.makeOtherUserPageReactor(user))
            navigationController?.pushViewController(userPageVC, animated: true)
        } else {
            showToast(message: "해당 사용자 정보에 접근할 수 없어요\n다시 시도해주세요", buttonContainerExists: true)
        }
    }
    
    private func setTextStyle() {
        titleLabel.applyStyle(textStyle: FontSystem.headline03_medium)
        genderOptionLabel.applyStyle(textStyle: FontSystem.caption01_reguler)
        dateValueLabel.applyStyle(textStyle: FontSystem.body02_medium)
        placeValueLabel.applyStyle(textStyle: FontSystem.body02_medium)
        partynumValueLabel.applyStyle(textStyle: FontSystem.body02_medium)
        nickNameLabel.applyStyle(textStyle: FontSystem.body02_medium)
        cheerTeam.applyStyle(textStyle: FontSystem.caption01_medium)
        genderLabel.applyStyle(textStyle: FontSystem.caption01_medium)
        ageLabel.applyStyle(textStyle: FontSystem.caption01_medium)
        addInfoValueLabel.applyStyle(textStyle: FontSystem.body02_medium)
    }
    
    private func makeAgeLabel(age: Int) -> DefaultsPaddingLabel {
        let label = DefaultsPaddingLabel(padding: UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8))
        label.textColor = .cmNonImportantTextColor
        label.applyStyle(textStyle: FontSystem.caption01_reguler)
        label.backgroundColor = .grayScale100
        label.layer.cornerRadius = 10
        if age == 0 {
            label.text = "전연령"
        } else {
            label.text = "\(String(age))대"
        }
        label.applyStyle(textStyle: FontSystem.caption01_reguler)
        return label
    }
}

// MARK: - bind
extension PostDetailViewController {
    func bind(reactor: PostReactor) {
        // 신고 토스트 메시지
        toastSubject
            .withUnretained(self)
            .subscribe { vc, _ in
                vc.showToast(message: "신고 완료되었어요")
            }
            .disposed(by: disposeBag)
        reactor.state.map{ $0.post }
            .compactMap{$0}
            .distinctUntilChanged()
            .bind(onNext: setupData)
            .disposed(by: disposeBag)
        
        reactor.state.map{ $0.isFavorite }
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe(onNext: { vc, state in
                vc.setupFavoriteButton(state)
            })
            .disposed(by: disposeBag)

        
        favoriteButton.rx.tap
            .withUnretained(self)
            .subscribe { vc, _ in
                let currentState = reactor.currentState.isFavorite
                reactor.action.onNext(.changeFavorite(!currentState))
            }
            .disposed(by: disposeBag)
        
        applyButton.rx.tap
            .withUnretained(self)
            .subscribe { vc, _ in
                switch vc.applyButton.type {
                case .none:
                    if let post = reactor.currentState.post, post.isFinishGame {
                        vc.showCMAlert(titleText: "이미 시작된 게임이에요.\n그래도 신청할까요?", importantButtonText: "신청", commonButtonText: "취소", importantAction:  {
                            vc.showApplyPopup()
                        })
                    } else {
                        vc.showApplyPopup()
                    }
                case .applied:
                    vc.showCancelApplyPopup()
                case .finished:
                    break
                case .chat:
                    vc.showChatRoom()
                }
            }
            .disposed(by: disposeBag)

        reactor.state.map{$0.applyButtonState}
            .compactMap{$0}
            .withUnretained(self)
            .subscribe(onNext: { vc, state in
                vc.applyButton.type = state
            })
            .disposed(by: disposeBag)
        
        
        reactor.state.map{$0.error}
            .compactMap{$0}
            .withUnretained(self)
            .subscribe { vc, error in
                vc.handleError(error)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.isDelete}
            .withUnretained(self)
            .subscribe { vc, flag in
                if flag {
                    vc.navigationController?.popViewController(animated: true)
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.upPostResult}
            .compactMap{$0}
            .withUnretained(self)
            .subscribe { vc, result in
                if result.result {
                    vc.showToast(message: "게시글을 끌어올렸어요", buttonContainerExists: true)
                } else {
                    if let message = result.message {
                        let toastMsg = "\(message) 뒤에 끌어올릴 수 있어요"
                        vc.showToast(message: toastMsg, buttonContainerExists: true)
                    }
                }
                vc.reactor.action.onNext(.resetUpPostResult)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.applyToastTrigger}
            .distinctUntilChanged()
            .filter{$0}
            .withUnretained(self)
            .subscribe { vc, _ in
                vc.showToast(message: "직관 신청을 보냈어요", buttonContainerExists: true)
                reactor.action.onNext(.resetApplyTrigger)
            }
            .disposed(by: disposeBag)
        
    }
    
    private func setupFavoriteButton(_ state: Bool) {
        if state {
            favoriteButton.setImage(UIImage(named: "favoriteGray_filled")?.withTintColor(.cmPrimaryColor, renderingMode: .alwaysOriginal), for: .normal)
            if reactor.currentState.isLoadSetting {
                showToast(message: "게시물을 저장했어요", buttonContainerExists: true)
            }
        } else {
            favoriteButton.setImage(UIImage(named: "favoriteGray_filled")?.withRenderingMode(.alwaysOriginal), for: .normal)
        }
    }
    
    func showApplyPopup() {
        guard let post = reactor.currentState.post else { return }
        let applyVC = ApplyPopupViewController(post: post, reactor: reactor, apply: nil)
        applyVC.modalPresentationStyle = .overFullScreen
        applyVC.modalTransitionStyle = .crossDissolve
        present(applyVC, animated: true)
    }
    
    func showCancelApplyPopup() {
        guard let post = reactor.currentState.post,
              let applyInfo = reactor.currentState.applyInfo else {
            showToast(message: "요청에 실패했어요.\n문제 지속 시 문의주세요")
            return
        }
        print(applyInfo)
        let applyVC = ApplyPopupViewController(post: post, reactor: reactor, apply: applyInfo)
        applyVC.modalPresentationStyle = .overFullScreen
        applyVC.modalTransitionStyle = .crossDissolve
        present(applyVC, animated: true)
    }
    
    
    func showChatRoom() {
        guard let post = reactor.currentState.post, let chatId = post.chatRoomId else {
            showToast(message: "채팅방에 들어갈 수 없어요\n문제 지속 시 문의해주세요")
            return
        }
        guard let id = SetupInfoService.shared.getUserInfo(type: .id), let userId = Int(id) else {
            reactor.action.onNext(.setError(.unauthorized))
            return
        }
        
        let chatInfoUC = DIContainerService.shared.makeChatDetailUseCase()
        
        chatInfoUC.loadChat(chatId)
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] info in
                let chatRoomVC = ChatRoomViewController(chat: ChatRoomInfo(chatRoomId: chatId, postInfo: info.postInfo, managerInfo: info.managerInfo, cheerTeam: info.postInfo.cheerTeam), userId: userId, isNew: info.newChat)
                self?.navigationController?.pushViewController(chatRoomVC, animated: true)
            }
            .disposed(by: disposeBag)
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
                flex.addItem().direction(.row).wrap(.wrap).justifyContent(.start).width(100%).define { flex in
                    flex.addItem(ageOptionView).direction(.row)
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
                            flex.addItem(cheerStyleLabel).marginRight(4)
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

final class ApplyButton: UIButton {
    var type: ApplyType = .none {
        didSet {
            changeButtonStyle()
        }
    }
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupButton()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupButton() {
        clipsToBounds = true
        layer.cornerRadius = 8
        setTitle("직관 신청", for: .normal)
        setTitleColor(.white, for: .normal)
        backgroundColor = .cmPrimaryColor
        applyStyle(textStyle: FontSystem.body02_semiBold)
    }
    
    func changeButtonStyle() {
        switch type {
        case .none:
            setTitle("직관 신청", for: .normal)
            setTitleColor(.white, for: .normal)
            layer.borderWidth = 0
            backgroundColor = .cmPrimaryColor
            isEnabled = true
        case .applied:
            setTitle("보낸 신청 보기", for: .normal)
            setTitleColor(.cmPrimaryColor, for: .normal)
            backgroundColor = .white
            layer.borderWidth = 1
            layer.borderColor = UIColor.cmPrimaryColor.cgColor
            isEnabled = true
        case .finished:
            setTitle("신청 마감", for: .normal)
            setTitleColor(.white, for: .normal)
            layer.borderWidth = 0
            backgroundColor = .cmPrimaryColor
            isEnabled = false
        case .chat:
            setTitle("채팅 보기", for: .normal)
            setTitleColor(.white, for: .normal)
            layer.borderWidth = 0
            backgroundColor = .cmPrimaryColor
            isEnabled = true
        }
        applyStyle(textStyle: FontSystem.body02_semiBold)
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                animate(scale: 0.95)
            } else {
                animate(scale: 1.0)
            }
        }
    }
    
    private func animate(scale: CGFloat) {
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        })
    }
}
