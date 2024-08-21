//
//  ChatSideSheetViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 8/13/24.
//

import UIKit
import PinLayout
import FlexLayout
import RxSwift

final class ChatSideSheetViewController: BaseViewController, UITableViewDelegate , UITableViewDataSource {
    private let user = SimpleUser(user: User(id: "1", email: "ㄴㄴㄴ", nickName: "나요", birth: "2000-01-22", team: .dosun, gener: .man, cheerStyle: .director, profilePicture: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT4MTkSLvHP365kTge2U5CHc-smH-Z2Xq5p-A&s", pushAgreement: true, description: ""))
    private let chat: Chat
    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = .opacity400
        return view
    }()
    private let containerView = UIView()
    private let infoView = UIView()
    private let topDivider = UIView()
    private let tableView = UITableView()
    private let bottomDivider = UIView()
    private let buttonView = UIView()
    private let titleLabel = UILabel()    
    private let indicatorImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "cm20right")?.withTintColor(.grayScale500, renderingMode: .alwaysOriginal)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let infoLabel = UILabel()
    private let partyNumLabel: UILabel = DefaultsPaddingLabel(padding: UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8))
    private let homeTeamImageView = TeamImageView()
    private let awayTeamImageView = TeamImageView()
    private let vsLabel: UILabel = {
        let label = UILabel()
        label.text = "VS"
        label.textColor = .cmNonImportantTextColor
        label.applyStyle(textStyle: FontSystem.body03_medium)
        return label
    }()
    private let exitButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "cm20leave")?.withTintColor(.grayScale500, renderingMode: .alwaysOriginal), for: .normal)
        return button
    }()
    private let notiButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "notification")?.withTintColor(.grayScale500, renderingMode: .alwaysOriginal), for: .normal)
        return button
    }()
    private let settingButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "setting")?.withTintColor(.grayScale500, renderingMode: .alwaysOriginal), for: .normal)
        return button
    }()
    private func setupStyle() {
        if let date = DateHelper.shared.toDate(from: chat.post.date, format: "MM.dd") {
            let string = DateHelper.shared.toString(from: date, format: "M월 d일 EEEE")
            infoLabel.text = "\(string) | \(chat.post.playTime) | \(chat.post.location)"
        } else {
            infoLabel.text = "0월 0일 요일 | \(chat.post.playTime) | \(chat.post.location)"
        }
        infoLabel.applyStyle(textStyle: FontSystem.body03_medium)
        infoLabel.textColor = .cmPrimaryColor
        partyNumLabel.text = "\(chat.post.currentPerson/chat.post.maxPerson)"
        partyNumLabel.textColor = .cmPrimaryColor
        partyNumLabel.backgroundColor = .brandColor50
        titleLabel.text = chat.post.title
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.textColor = .cmHeadLineTextColor
        titleLabel.applyStyle(textStyle: FontSystem.body01_medium)
        homeTeamImageView.setupTeam(team: chat.post.homeTeam, isMyTeam: chat.post.writer.favGudan == chat.post.homeTeam)
        awayTeamImageView.setupTeam(team: chat.post.awayTeam, isMyTeam: chat.post.writer.favGudan == chat.post.awayTeam)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(ChatRoomPeopleListCell.self, forCellReuseIdentifier: "ChatRoomPeopleListCell")
        tableView.register(MypageHeader.self, forHeaderFooterViewReuseIdentifier: "MypageHeader")
    }
    init(chat: Chat) {
        self.chat = chat
        super.init(nibName: nil, bundle: nil)
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStyle()
        setupUI()
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
        setupGesture()
    }
    
    override func viewDidLayoutSubviews() {
        dimView.pin.all()
        containerView.pin.top(view.pin.safeArea).bottom().right().width(80%)
        infoView.pin.top().horizontally().height(135)
            .marginTop(24).marginHorizontal(20)
        tableView.pin.below(of: infoView).horizontally().above(of: buttonView)
        buttonView.pin
            .bottom(view.pin.safeArea)
            .horizontally()
            .height(52)
    }
    private func setupGesture() {
        let backGesture = UITapGestureRecognizer(target: self, action: #selector(clickedBack))
        dimView.addGestureRecognizer(backGesture)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        containerView.addGestureRecognizer(panGesture)
    }
    
    @objc private func clickedBack(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true)
    }
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        
        switch gesture.state {
        case .changed:
            if translation.x > 0 { // 오른쪽으로 슬라이드할 때만 이동
                containerView.frame.origin.x = translation.x
            }
        case .ended:
            if translation.x > containerView.frame.width / 2 { // 슬라이드가 반 이상이면 닫기
                dismiss(animated: true, completion: nil)
            } else {
                // 반 이하로 움직였으면 다시 원래 위치로 애니메이션
                UIView.animate(withDuration: 0.3) {
                    self.containerView.frame.origin.x = 0
                }
            }
        default:
            break
        }
    }
    private func setupUI() {
        view.addSubview(dimView)
        view.addSubview(containerView)
        containerView.addSubviews(views: [infoView, tableView, buttonView])
        infoView.flex.direction(.column).justifyContent(.start).alignItems(.start).width(100%).define { flex in
            flex.addItem().direction(.row).justifyContent(.spaceBetween).alignItems(.center).define { flex in
                flex.addItem().direction(.column).define { flex in
                    flex.addItem(infoLabel).marginBottom(4)
                    flex.addItem().direction(.row).define { flex in
                        flex.addItem(partyNumLabel).marginRight(6)
                        flex.addItem(titleLabel).shrink(1)
                    }
                }.shrink(1)
                flex.addItem(indicatorImageView).size(20)
            }.marginBottom(12)
            flex.addItem().direction(.row).justifyContent(.center).alignItems(.center).define { flex in
                flex.addItem(homeTeamImageView)
                flex.addItem(vsLabel).marginHorizontal(24)
                flex.addItem(awayTeamImageView)
            }.backgroundColor(.grayScale50).cornerRadius(8).paddingVertical(16)
            flex.addItem(topDivider).height(1).backgroundColor(.cmStrokeColor).marginVertical(16)
        }
        buttonView.flex.width(100%).direction(.row).justifyContent(.spaceBetween).alignItems(.center).define { flex in
            flex.addItem(exitButton).size(20)
            flex.addItem().direction(.row).justifyContent(.start).alignItems(.center).define { flex in
                flex.addItem(notiButton).size(20)
                if chat.roomManager == user {
                    flex.addItem(settingButton).marginLeft(24).size(20)
                }
            }
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chat.people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatRoomPeopleListCell", for: indexPath) as? ChatRoomPeopleListCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        let person = chat.people[indexPath.row]
        cell.configData(person, isMy: person == user, isManager: person == chat.roomManager)
        return cell
        
    }
    // UITableViewDelegate: 셀 높이 지정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }

    // UITableViewDelegate: 섹션 헤더 높이 지정
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "MypageHeader") as? MypageHeader else { return UIView() }
        headerView.configData(title: "참여자 정보")

        return headerView
    }
}

extension ChatSideSheetViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return SideSheetPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SideSheetAnimator(isPresenting: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SideSheetAnimator(isPresenting: false)
    }
}


final class ChatRoomPeopleListCell: UITableViewCell {
    private let containerView = UIView()
    private let profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    private let myImageBedge: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "myBedge")
        return imageView
    }()
    private let managerImageBedge: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "king")
        return imageView
    }()
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmHeadLineTextColor
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImage.image = nil
        nicknameLabel.text = ""
        profileImage.flex.display(.none)
        myImageBedge.flex.display(.none)
        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.pin.all()
        containerView.flex.layout()
    }
    
    func configData(_ person: SimpleUser, isMy: Bool, isManager: Bool) {
        ProfileImageHelper.loadImage(profileImage, pictureString: person.picture)
        nicknameLabel.text = person.nickName
        nicknameLabel.applyStyle(textStyle: FontSystem.body02_medium)
        // 데이터에 따라 UI 요소 배치 결정
        if isMy {
            myImageBedge.flex.display(.flex)
        } else {
            myImageBedge.flex.display(.none)
        }
        
        if isManager {
            managerImageBedge.flex.display(.flex)
        } else {
            managerImageBedge.flex.display(.none)
        }

        // 레이아웃 업데이트
        managerImageBedge.flex.markDirty()
        myImageBedge.flex.markDirty()
        nicknameLabel.flex.markDirty()
        containerView.flex.layout()
        
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.flex.width(100%).direction(.row).justifyContent(.start).alignItems(.center).define { flex in
            flex.addItem(profileImage).size(40).cornerRadius(20).marginRight(8)
            flex.addItem().direction(.row).justifyContent(.start).alignItems(.center).define { flex in
                flex.addItem(myImageBedge).size(20).marginRight(4)
                flex.addItem(managerImageBedge).size(20).marginRight(4)
                flex.addItem(nicknameLabel)
            }
        }
    }
}

// MARK: - SideSheetPresentationController
class SideSheetPresentationController: UIPresentationController {
    
    private let dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        return view
    }()
    
    override var shouldRemovePresentersView: Bool {
        return false
    }
    
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }
        dimmingView.frame = containerView.bounds
        containerView.addSubview(dimmingView)
        
        dimmingView.alpha = 0.0
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1.0
        })
    }
    
    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0.0
        })
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        guard let containerView = containerView else { return }
        presentedView?.frame = CGRect(x: containerView.bounds.width * 0.2,
                                      y: 0,
                                      width: containerView.bounds.width * 0.8,
                                      height: containerView.bounds.height)
    }
}

// MARK: - SideSheetAnimator
class SideSheetAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let isPresenting: Bool
    
    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from),
              let toView = transitionContext.view(forKey: .to) else { return }
        
        let containerView = transitionContext.containerView
        let finalWidth = containerView.bounds.width * 0.8
        let initialFrame = isPresenting ? CGRect(x: containerView.bounds.width,
                                                 y: 0,
                                                 width: finalWidth,
                                                 height: containerView.bounds.height) : toView.frame
        
        let finalFrame = isPresenting ? CGRect(x: containerView.bounds.width * 0.2,
                                               y: 0,
                                               width: finalWidth,
                                               height: containerView.bounds.height) : initialFrame.offsetBy(dx: containerView.bounds.width, dy: 0)
        
        let animateView = isPresenting ? toView : fromView
        
        if isPresenting {
            containerView.addSubview(animateView)
        }
        
        animateView.frame = initialFrame
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            animateView.frame = finalFrame
        }) { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
