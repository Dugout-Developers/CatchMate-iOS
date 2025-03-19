//
//  ChatRoomViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 7/17/24.
//

import UIKit
import SnapKit
import ReactorKit
import RxSwift

final class ChatRoomViewController: BaseViewController, View {
    override var useSnapKit: Bool {
        return true
    }
    override var buttonContainerExists: Bool {
        return true
    }
    private let errorMessageView: UIView = {
        let view = UIView()
        view.backgroundColor = .opacity600
        return view
    }()
    private let errorMessage: UILabel = {
        let label = UILabel()
        label.text = "채팅방 연결이 불안정합니다."
        label.textColor = .white
        label.applyStyle(textStyle: FontSystem.body02_medium)
        return label
    }()
    private let tableView: UITableView = UITableView()
    private let inputview: ChatingInputField = ChatingInputField()
    private var chat: ChatRoomInfo
    private var userId: Int
    private var isUserScrolling = false
    private var isMessageUpdate = false
    var reactor: ChatRoomReactor
    private var keyboardManager: KeyboardManager?
    private var bottomConstraint: Constraint?
    private var inputViewHeightConstraint: Constraint?
    private var lastTopMessage: ChatMessage?
    private let isNew: Bool
    private var isStart: Bool = true
    private let numberLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmNonImportantTextColor
        label.applyStyle(textStyle: FontSystem.caption01_medium)
        return label
    }()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reactor.action.onNext(.subscribeRoom)
        reactor.action.onNext(.loadNotificationStatus)
        reactor.action.onNext(.loadPostDetail(nil))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isNew {
            showCMAlert(titleText: "경기 종료 후 7일이 지나면\n채팅방이 자동으로 삭제됩니다\n참고해주세요", importantButtonText: "확인", commonButtonText: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        SocketService.shared?.readMessage(roomId: String(chat.chatRoomId))

        NotificationCenter.default.removeObserver(self)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.post(name: .reloadUnreadMessageState, object: nil)
        reactor.action.onNext(.unsubscribeRoom)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigation()
        setupUI()
        bind(reactor: reactor)
        textViewBind()
        keyboardManager = KeyboardManager(view: view, bottomConstraint: bottomConstraint, keyboardWillShowHandler: { [weak self] in
            self?.scrollToBottom(animated: true)
        })
        view.backgroundColor = .white
        reactor.action.onNext(.loadPeople)
        reactor.action.onNext(.loadMessages(isStart: true))
    }
    
    init(chat: ChatRoomInfo, userId: Int, isNew: Bool) {
        self.reactor = DIContainerService.shared.makeChatRoomReactor(chat)
        self.chat = chat
        self.userId = userId
        self.isNew = isNew
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func scrollToBottom(animated: Bool) {
        guard !reactor.currentState.messages.isEmpty else { return }
        let indexPath = IndexPath(row: reactor.currentState.messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
    }
    
    private func setupView() {
        // 셀 등록
        tableView.register(MyMessageTableViewCell.self, forCellReuseIdentifier: "MyMessageTableViewCell")
        tableView.register(OtherMessageTableViewCell.self, forCellReuseIdentifier: "OtherMessageTableViewCell")
        tableView.register(StartChatInfoCell.self, forCellReuseIdentifier: "StartChatInfoCell")
        tableView.register(DateChatInfoCell.self, forCellReuseIdentifier: "DateChatInfoCell")
        tableView.register(EnterUserCell.self, forCellReuseIdentifier: "EnterUserCell")
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        view.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.tableHeaderView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .grayScale50
    }
    private func setupNavigation() {
        let menuButton = UIButton()
        menuButton.setImage(UIImage(named: "cm20hamburger")?.withTintColor(.grayScale800, renderingMode: .alwaysOriginal), for: .normal)
        menuButton.addTarget(self, action: #selector(clickedMenuButton), for: .touchUpInside)
        customNavigationBar.addRightItems(items: [menuButton])
        menuButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        let titleLabel: UILabel = {
            let label = UILabel()
            label.text = chat.postInfo.title
            label.textColor = .cmHeadLineTextColor
            label.applyStyle(textStyle: FontSystem.body01_medium)
            label.lineBreakMode = .byTruncatingTail
            label.numberOfLines = 1
            return label
        }()
        numberLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        customNavigationBar.addLeftItems(items: [titleLabel, numberLabel])
    }
    
    private func updateCurrentPeople(_ count: Int) {
        numberLabel.text = "\(count)"
        numberLabel.applyStyle(textStyle: FontSystem.caption01_medium)
    }
    
    @objc private func clickedMenuButton(_ sender: UIButton) {
        print(reactor.currentState.senderProfiles)
        let sideSheetVC = ChatSideSheetViewController(chat: chat, userId: userId, people: reactor.currentState.senderProfiles, reactor: reactor)
        let transitioningDelegate = SideSheetTransitioningDelegate()
        sideSheetVC.transitioningDelegate = transitioningDelegate
        sideSheetVC.modalPresentationStyle = .custom
        present(sideSheetVC, animated: true, completion: nil)
    }
    
    private func setupUI() {
        view.addSubviews(views: [tableView, inputview, errorMessageView])
        errorMessageView.addSubview(errorMessage)
        errorMessageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        errorMessage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(9)
        }
        tableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        inputview.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            inputViewHeightConstraint = make.height.equalTo(52).constraint
            bottomConstraint = make.bottom.equalTo(view.safeAreaLayoutGuide).constraint
        }
    }
}

// MARK: - Bind
extension ChatRoomViewController {
    func textViewBind() {
        inputview.textField.rx.text
            .compactMap { $0 }
            .withUnretained(self)
            .subscribe(onNext: { vc, text in
                vc.inputview.textField.isScrollEnabled = false
                let size = CGSize(width: vc.inputview.textField.frame.width, height: .infinity)
                let estimatedSize = vc.inputview.textField.sizeThatFits(size)
                
                // 최대 높이를 넘어가는지 여부 확인
                let isMaxHeight = estimatedSize.height >= 90
                
                if isMaxHeight {
                    vc.inputview.textField.isScrollEnabled = true
                    vc.updateInputViewHeight(newHeight: 90)
                } else {
                    vc.inputview.textField.isScrollEnabled = false
                    vc.updateInputViewHeight(newHeight: estimatedSize.height+34)
                }
            })
            .disposed(by: disposeBag)
    }
    // inputview의 높이를 동적으로 업데이트하는 함수
    func updateInputViewHeight(newHeight: CGFloat) {
        inputViewHeightConstraint?.update(offset: newHeight)
        view.layoutIfNeeded()
    }
    
    
    private func scrollTableview() {
        tableView.beginUpdates()
        if let index = reactor.currentState.messages.firstIndex(where: {$0 == lastTopMessage}) {
            guard index >= 0, index < tableView.numberOfRows(inSection: 0) else {
                tableView.endUpdates()
                return
            }

            let indexPath = IndexPath(row: index, section: 0)
            print(reactor.currentState.messages.count)
            tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        }
        tableView.endUpdates()
        isMessageUpdate = false
    }
    
    func scrollToTableViewBottom(_ animate: Bool) {
        tableView.beginUpdates()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let lastSection = max(self.tableView.numberOfSections - 1, 0)
            let lastRow = max(self.tableView.numberOfRows(inSection: lastSection) - 1, 0)
            if self.tableView.numberOfRows(inSection: lastSection) == 0 { return }

            // 데이터가 존재하는지 확인 후 스크롤 실행
            if lastRow >= 0 {
                let indexPath = IndexPath(row: lastRow, section: lastSection)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: animate)
            }
        }
        tableView.endUpdates()
        isMessageUpdate = false
    }
    
    private func isTableViewAtBottom() -> Bool {
        let contentHeight = tableView.contentSize.height
        let tableHeight = tableView.bounds.height
        let contentOffsetY = tableView.contentOffset.y
        let bottomInset = tableView.adjustedContentInset.bottom

        return contentOffsetY >= (contentHeight - tableHeight - bottomInset - 10) // 여유값 10 추가
    }
    func bind(reactor: ChatRoomReactor) {
        reactor.state.map{$0.loadPostDetailTrigger}
            .compactMap{$0}
            .withUnretained(self)
            .subscribe { vc, _ in
                let postDetailVC = PostDetailViewController(postID: vc.chat.postInfo.id)
                vc.navigationController?.pushViewController(postDetailVC, animated: true)
            }
            .disposed(by: disposeBag)
        
        tableView.rx.didScroll
            .subscribe(onNext: { [weak self] _ in
                if let topIndexPath = self?.tableView.indexPathsForVisibleRows?.first,
                   let message = reactor.currentState.messages[safe: topIndexPath.row] {
                    if self?.lastTopMessage != message {
                        self?.lastTopMessage = message
                    }
                }
            })
            .disposed(by: disposeBag)
        tableView.rx.contentOffset
            .filter { [weak self] _ in
                guard let self = self else { return false }
                return self.tableView.isDragging || self.tableView.isDecelerating //  사용자가 스크롤한 경우만 감지
            }
            .map { offset -> Bool in
                return offset.y <= 0 // 천장에 닿았을 때 true 반환
            }
            .distinctUntilChanged()
            .filter { $0 } 
            .withLatestFrom(reactor.state.map { $0.isLast })
            .filter { !$0 }
            .subscribe(onNext: { _ in
                reactor.action.onNext(.loadMessages(isStart: false))
            })
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.exitTrigger}
            .compactMap{$0}
            .withUnretained(self)
            .subscribe { vc, _ in
                vc.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)

        reactor.state.map{$0.scrollTrigger}
            .filter { [weak self] _ in
                self?.isMessageUpdate == true
            }
            .withUnretained(self)
            .subscribe { vc, type in
                switch type {
                case .startRoom:
                    vc.scrollToTableViewBottom(false)
                case .sendMyMessage:
                    vc.scrollToTableViewBottom(true)
                case .nextPage, .background:
                    vc.scrollTableview()
                case .receivedMessage:
                    let isAtBottom = vc.isTableViewAtBottom()
                    print(isAtBottom)
                    if isAtBottom {
                        vc.scrollToTableViewBottom(true)
                    } else {
                        vc.scrollTableview()
                    }
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.messages}
            .observe(on: MainScheduler.instance)
            .do(afterNext: { _ in
                self.isMessageUpdate = true
            })
            .bind(to: tableView.rx.items) { [weak self] tableView, index, item in
                guard let self = self else { return UITableViewCell() }
                let indexPath = IndexPath(row: index, section: 0)
                switch item.messageType {
                case .talk:
                    if item.userId == self.userId {
                        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyMessageTableViewCell", for: indexPath) as? MyMessageTableViewCell else {
                            return UITableViewCell()
                        }
                        cell.configData(item)
                        cell.selectionStyle = .none
                        cell.backgroundColor = .clear
                        cell.messageLabel.setNeedsLayout()
                        cell.messageLabel.layoutIfNeeded()
                        return cell
                    } else {
                        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OtherMessageTableViewCell", for: indexPath) as? OtherMessageTableViewCell else {
                            return UITableViewCell()
                        }
                        let isHiddenTime = index == 0 ? false : (reactor.currentState.messages[index-1].messageType == .talk && reactor.currentState.messages[index-1].userId == item.userId && item.isEqualTime(reactor.currentState.messages[index-1]))
                        let isHiddenProfile = index == 0 ? false : (reactor.currentState.messages[index-1].messageType == .talk && reactor.currentState.messages[index-1].userId == item.userId)
                        cell.configData(item, isHiddenTime: isHiddenTime, isHiddenProfile: isHiddenProfile)
                        cell.messageLabel.setNeedsLayout()
                        cell.messageLabel.layoutIfNeeded()
                        cell.selectionStyle = .none
                        cell.backgroundColor = .clear
                        
                        return cell
                    }
                case .date:
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "DateChatInfoCell", for: indexPath) as? DateChatInfoCell else { return UITableViewCell() }
                    cell.configData(item.time)
                    cell.selectionStyle = .none
                    cell.backgroundColor = .clear
                    return cell
                case .enterUser, .leaveUser:
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "EnterUserCell", for: indexPath) as? EnterUserCell else {
                        return UITableViewCell()
                    }
                    cell.configData(item.nickName, type: item.messageType.serverRequest)
                    cell.selectionStyle = .none
                    cell.backgroundColor = .clear
                    return cell
                case .startChat:
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "StartChatInfoCell", for: indexPath) as? StartChatInfoCell else { return UITableViewCell() }
                    cell.configData(chat.postInfo)
                    cell.selectionStyle = .none
                    cell.backgroundColor = .clear
                    return cell
                }
            }
            .disposed(by: disposeBag)
        
        inputview.rx.sendTap
            .throttle(.seconds(3), latest: false, scheduler: MainScheduler.instance)
            .compactMap { $0 }
            .distinctUntilChanged()
            .withUnretained(self)
            .map { (vc, text) -> String in
                vc.inputview.clearText()
                return text
            }
            .map{Reactor.Action.sendMessage($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.senderProfiles.count}
            .withUnretained(self)
            .subscribe { vc, count in
                vc.updateCurrentPeople(count)
            }
            .disposed(by: disposeBag)
        reactor.state.map{$0.error}
            .compactMap{$0}
            .withUnretained(self)
            .subscribe { vc, error in
                vc.handleError(error)
            }
            .disposed(by: disposeBag)
        reactor.state.map {$0.chatError}
            .map{ $0 == nil }
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe { vc, state in
                vc.errorMessageView.isHidden = state
            }
            .disposed(by: disposeBag)
    }
}


class KeyboardManager {
    private weak var view: UIView?
    private var bottomConstraint: Constraint?
    private var keyboardWillShowHandler: (() -> Void)?
    private var keyboardWillHideHandler: (() -> Void)?
    
    init(view: UIView, bottomConstraint: Constraint?, keyboardWillShowHandler: (() -> Void)? = nil, keyboardWillHideHandler: (() -> Void)? = nil) {
        self.view = view
        self.bottomConstraint = bottomConstraint
        self.keyboardWillShowHandler = keyboardWillShowHandler
        self.keyboardWillHideHandler = keyboardWillHideHandler
        registerKeyboardNotifications()
    }
    
    deinit {
        unregisterKeyboardNotifications()
    }
    
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func unregisterKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        adjustForKeyboard(notification: notification, keyboardWillShow: true)
        keyboardWillShowHandler?()
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        adjustForKeyboard(notification: notification, keyboardWillShow: false)
        keyboardWillHideHandler?()
    }
    
    private func adjustForKeyboard(notification: Notification, keyboardWillShow: Bool) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let view = view else {
            return
        }
        
        let changeInHeight = keyboardWillShow ? -keyboardFrame.height + view.safeAreaInsets.bottom : 0
        
        bottomConstraint?.update(offset: changeInHeight)
        
        UIView.animate(withDuration: animationDuration) {
            view.layoutIfNeeded()
        }
    }
}
