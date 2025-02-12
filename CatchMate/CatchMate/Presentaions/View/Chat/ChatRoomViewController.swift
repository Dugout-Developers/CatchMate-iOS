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
    var reactor: ChatRoomReactor
    private var keyboardManager: KeyboardManager?
    private var bottomConstraint: Constraint?
    private var inputViewHeightConstraint: Constraint?
   
    private let refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        control.tintColor = .cmPrimaryColor
        return control
    }()
    private let numberLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmNonImportantTextColor
        label.applyStyle(textStyle: FontSystem.caption01_medium)
        return label
    }()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reactor.action.onNext(.subscribeRoom)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
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
        reactor.action.onNext(.loadMessages)
    }

    init(chat: ChatRoomInfo, userId: Int) {
        self.reactor = ChatRoomReactor(roomId: chat.chatRoomId, managerInfo: chat.managerInfo, loadInfoUS: DIContainerService.shared.makeChatRoomUseCase())
        self.chat = chat
        self.userId = userId
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
        tableView.refreshControl = refreshControl
        view.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.tableHeaderView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
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
        let sideSheetVC = ChatSideSheetViewController(chat: chat, userId: userId, people: reactor.currentState.senderProfiles)
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
    
    
    func bind(reactor: ChatRoomReactor) {

        refreshControl.rx.controlEvent(.valueChanged)
            .withLatestFrom(reactor.state.map { $0.isLast })
            .subscribe(onNext: { [weak self] isLast in
                guard let self = self else { return }
                if isLast {
                    self.refreshControl.endRefreshing()
                } else {
                    reactor.action.onNext(.loadMessages)
                }
            })
            .disposed(by: disposeBag)

 
        reactor.state.map { !$0.isLoading }
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                self?.refreshControl.endRefreshing()
            })
            .disposed(by: disposeBag)
        
        
        
        reactor.state.map { $0.messages }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] messages in
                guard let self = self else { return }
                
                let isFirstLoad = self.tableView.contentSize.height == 0 // 처음 로드 확인
                let previousContentHeight = self.tableView.contentSize.height // 기존 높이 저장
//                let previousOffsetY = self.tableView.contentOffset.y // 기존 오프셋 저장
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    let newContentHeight = self.tableView.contentSize.height // 새로운 높이 가져오기
                    
                    if isFirstLoad {
                        // 처음 채팅방을 열었을 때는 가장 아래로 스크롤
                        self.scrollToBottom(animated: false)
                    } else if messages.count > 0, previousContentHeight > 0 {
                        // 위로 스크롤하여 메시지를 불러온 경우 스크롤 위치 유지
                        let offsetYDifference = newContentHeight - previousContentHeight
                        self.tableView.contentOffset.y += offsetYDifference
                    }
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.messages}
            .observe(on: MainScheduler.instance)
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
                        return cell
                    } else {
                        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OtherMessageTableViewCell", for: indexPath) as? OtherMessageTableViewCell else {
                            return UITableViewCell()
                        }
                        let isHiddenTime = index == 0 ? false : (reactor.currentState.messages[index-1].messageType == .talk && reactor.currentState.messages[index-1].userId == item.userId && reactor.currentState.messages[index-1].time == item.time)
                        let isHiddenProfile = index == 0 ? false : (reactor.currentState.messages[index-1].messageType == .talk && reactor.currentState.messages[index-1].userId == item.userId)
                        cell.configData(item, isHiddenTime: isHiddenTime, isHiddenProfile: isHiddenProfile)
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
                case .enterUser:
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "EnterUserCell", for: indexPath) as? EnterUserCell else {
                        return UITableViewCell()
                    }
                    cell.configData(item.nickName)
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
        
        reactor.state.map {$0.error}
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
