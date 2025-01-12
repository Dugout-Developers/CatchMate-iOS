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
    private let tableView: UITableView = UITableView()
    private let inputview: ChatingInputField = ChatingInputField()
    private var chat: Chat
    var reactor: ChatRoomReactor
    private var keyboardManager: KeyboardManager?
    private var bottomConstraint: Constraint?
    private var inputViewHeightConstraint: Constraint?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reactor.action.onNext(.loadMessages)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
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
    }
    // 임시
    private let user = User(id: "1", email: "ㄴㄴㄴ", nickName: "나요", birth: "2000-01-22", team: .dosun, gener: .man, cheerStyle: .director, profilePicture: nil, allAlarm: true, chatAlarm: true, enrollAlarm: true, eventAlarm: true)
    init(chat: Chat) {
        self.reactor = ChatRoomReactor(chat: chat, user: user)
        self.chat = chat
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
            label.text = chat.post.title
            label.textColor = .cmHeadLineTextColor
            label.applyStyle(textStyle: FontSystem.body01_medium)
            label.lineBreakMode = .byTruncatingTail
            label.numberOfLines = 1
            return label
        }()
        let numberLabel: UILabel = {
            let label = UILabel()
            label.text = "\(chat.post.currentPerson)"
            label.textColor = .cmNonImportantTextColor
            label.applyStyle(textStyle: FontSystem.caption01_medium)
            return label
        }()
        numberLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        customNavigationBar.addLeftItems(items: [titleLabel, numberLabel])
    }
    
    @objc private func clickedMenuButton(_ sender: UIButton) {
        let sideSheetVC = ChatSideSheetViewController(chat: chat)
//        let transitioningDelegate = SideSheetTransitioningDelegate()
//        sideSheetVC.transitioningDelegate = transitioningDelegate
//        sideSheetVC.modalPresentationStyle = .custom
//        present(sideSheetVC, animated: true, completion: nil)
    }
    
    private func setupUI() {
        view.addSubviews(views: [tableView, inputview])
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
        reactor.state.map{$0.messages}
            .subscribe(onNext: { [weak self] messages in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if messages.count > 0 {         
                        self.tableView.reloadData()
                        let indexPath = IndexPath(row: messages.count - 1, section: 0)
                        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
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
                case 0:
                    if item.user?.id == user.id {
                        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyMessageTableViewCell", for: indexPath) as? MyMessageTableViewCell else { return UITableViewCell() }
                        cell.configData(item)
                        cell.selectionStyle = .none
                        cell.backgroundColor = .clear
                        return cell
                    } else {
                        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OtherMessageTableViewCell", for: indexPath) as? OtherMessageTableViewCell else { return UITableViewCell() }
                        let isHiddenTime = index == 0 ? false : (reactor.currentState.messages[index-1].messageType == 0 && reactor.currentState.messages[index-1].user?.id == item.user?.id && reactor.currentState.messages[index-1].date == item.date)
                        let isHiddenProfile = index == 0 ? false : (reactor.currentState.messages[index-1].messageType == 0 && reactor.currentState.messages[index-1].user?.id == item.user?.id)
                        cell.configData(item, isHiddenTime: isHiddenTime, isHiddenProfile: isHiddenProfile)
                        cell.selectionStyle = .none
                        cell.backgroundColor = .clear
                        return cell
                    }
                case 1:
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "EnterUserCell", for: indexPath) as? EnterUserCell, let user = item.user else { return UITableViewCell() }
                    cell.configData(user)
                    cell.selectionStyle = .none
                    cell.backgroundColor = .clear
                    return cell
                case 2:
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "DateChatInfoCell", for: indexPath) as? DateChatInfoCell else { return UITableViewCell() }
                    cell.configData(item.date)
                    cell.selectionStyle = .none
                    cell.backgroundColor = .clear
                    return cell
                case 3:
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "StartChatInfoCell", for: indexPath) as? StartChatInfoCell else { return UITableViewCell() }
                    cell.configData(chat.post)
                    cell.selectionStyle = .none
                    cell.backgroundColor = .clear
                    return cell
                default:
                    return UITableViewCell()
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
    }
}

// MARK: - System Info Cell
final class StartChatInfoCell: UITableViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmNonImportantTextColor
        return label
    }()
    private let teamView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    private let teamStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 26
        return stackView
    }()
    private let homeTeamImageView: TeamImageView = {
        let imageview = TeamImageView()
        imageview.snp.makeConstraints { make in
            make.size.equalTo(50)
        }
        return imageview
    }()
    private let awayTeamImageView: TeamImageView = {
        let imageview = TeamImageView()
        imageview.snp.makeConstraints { make in
            make.size.equalTo(50)
        }
        return imageview
    }()
    private let vsLabel: UILabel = {
        let label = UILabel()
        label.text = "VS"
        label.textColor = .cmNonImportantTextColor
        label.applyStyle(textStyle: FontSystem.body03_medium)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(containerView)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        infoLabel.text = nil
    }
    
    func configData(_ post: Post) {
        infoLabel.text = "\(post.date) | \(post.playTime) | \(post.location)"
        infoLabel.applyStyle(textStyle: FontSystem.body02_medium)
        homeTeamImageView.setupTeam(team: post.homeTeam, isMyTeam: post.writer.favGudan == post.homeTeam)
        awayTeamImageView.setupTeam(team: post.awayTeam, isMyTeam: post.writer.favGudan == post.awayTeam)
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubviews(views: [infoLabel, teamView])
        teamView.addSubview(teamStackView)
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(MainGridSystem.getMargin())
            make.top.bottom.equalToSuperview().inset(4)
        }
        infoLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
        }
        teamView.snp.makeConstraints { make in
            make.top.equalTo(infoLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-12)
        }
        teamStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.center.equalToSuperview()
            make.height.equalTo(50)
        }
        [homeTeamImageView, vsLabel, awayTeamImageView].forEach { view in
            teamStackView.addArrangedSubview(view)
        }
    }
}

final class DateChatInfoCell: UITableViewCell {
    private let containerView = UIView()
    private var isStart: Bool = false
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmNonImportantTextColor
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
    
    func configData(_ date: Date, _ isStart: Bool = false) {
        dateLabel.text = date.toString(format: "M월 d일")
        dateLabel.applyStyle(textStyle: FontSystem.body03_medium)
        if isStart {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.text = nil
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        let leftDivider = createDivider()
        let rightDivider = createDivider()
        containerView.addSubviews(views: [leftDivider, dateLabel, rightDivider])
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(MainGridSystem.getMargin())
            make.top.equalToSuperview().inset(isStart ? 16 : 12)
            make.bottom.equalToSuperview().inset(12)
        }
        leftDivider.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(leftDivider.snp.trailing).offset(12)
            make.top.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        rightDivider.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.leading.equalTo(dateLabel.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }
    
    private func createDivider() -> UIView {
        let view = UIView()
        view.backgroundColor = .cmStrokeColor
        return view
    }
}

final class EnterUserCell: UITableViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .grayScale600
        label.textAlignment = .center
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(containerView)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configData(_ user: User) {
        infoLabel.text = "\(user.nickName) 님이 채팅에 참여했어요"
        infoLabel.applyStyle(textStyle: FontSystem.body03_medium)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        infoLabel.text = nil
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(infoLabel)
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(MainGridSystem.getMargin())
            make.top.bottom.equalToSuperview().inset(4)
        }
        infoLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(10)
            make.width.lessThanOrEqualTo(containerView).offset(-24)
        }
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
