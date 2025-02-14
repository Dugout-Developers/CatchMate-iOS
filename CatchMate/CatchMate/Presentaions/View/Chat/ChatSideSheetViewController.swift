//
//  ChatSideSheetViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 8/13/24.
//

import UIKit
import RxSwift
import SnapKit

final class ChatSideSheetViewController: BaseViewController, UITableViewDelegate , UITableViewDataSource {
    override var useSnapKit: Bool {
        return true
    }
    override var buttonContainerExists: Bool {
        return false
    }
    private let userId: Int
    private let chat: ChatRoomInfo
    private let people: [SenderInfo]
    private let chatRoomImage: String
    private let reactor: ChatRoomReactor
    private var isManager: Bool {
        return chat.managerInfo.id == userId
    }
    private let infoView = UIView()
    private let teamInfoView = UIView()
    private let topDivider: UIView = {
        let view = UIView()
        view.backgroundColor = .grayScale100
        return view
    }()
    private let tableView = UITableView()
    private let bottomDivider: UIView = {
        let view = UIView()
        view.backgroundColor = .grayScale100
        return view
    }()
    private let buttonView = UIView()
    
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
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
    private let partyInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "참여자 정보"
        label.textColor = .cmNonImportantTextColor
        label.numberOfLines = 1
        label.applyStyle(textStyle: FontSystem.body02_medium)
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
    private let rightBtnStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 24
        return stackView
    }()
    private func setupStyle() {
        if let date = DateHelper.shared.toDate(from: chat.postInfo.date, format: "MM.dd") {
            let string = DateHelper.shared.toString(from: date, format: "M월 d일 EEEE")
            infoLabel.text = "\(string) | \(chat.postInfo.playTime) | \(chat.postInfo.location)"
        } else {
            infoLabel.text = "0월 0일 요일 | \(chat.postInfo.playTime) | \(chat.postInfo.location)"
        }
        infoLabel.applyStyle(textStyle: FontSystem.body03_medium)
        infoLabel.textColor = .cmPrimaryColor
        partyNumLabel.text = "\(chat.postInfo.currentPerson)/\(chat.postInfo.maxPerson)"
        partyNumLabel.applyStyle(textStyle: FontSystem.caption01_medium)
        partyNumLabel.layer.cornerRadius = 10
        partyNumLabel.textAlignment = .center
        partyNumLabel.textColor = .cmPrimaryColor
        partyNumLabel.backgroundColor = .brandColor50
        titleLabel.text = chat.postInfo.title
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.textColor = .cmHeadLineTextColor
        titleLabel.applyStyle(textStyle: FontSystem.body01_medium)
        homeTeamImageView.setupTeam(team: chat.postInfo.homeTeam, isMyTeam: chat.postInfo.cheerTeam == chat.postInfo.homeTeam)
        awayTeamImageView.setupTeam(team: chat.postInfo.awayTeam, isMyTeam: chat.postInfo.cheerTeam == chat.postInfo.awayTeam)
    }
    
    init(chat: ChatRoomInfo, userId: Int, people: [SenderInfo], image: String = "", reactor: ChatRoomReactor) {
        // TODO: - image 임시 기본값
        self.chat = chat
        self.userId = userId
        self.people = people
        self.chatRoomImage = image
        self.reactor = reactor
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        modalTransitionStyle = .crossDissolve
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStyle()
        setupUI()
        setupTableView()
        navigationBarHidden()
        bind()
        settingButton.isHidden = !isManager
    }
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(ChatRoomPeopleListCell.self, forCellReuseIdentifier: "ChatRoomPeopleListCell")
    }
    private func bind() {
        settingButton.rx.tap
            .withUnretained(self)
            .flatMapLatest { vc, _ -> Observable<ChatSettingViewController> in
                return Observable.create { observer in
                    do {
                        let settingVC = try ChatSettingViewController(reactor: vc.reactor, chat: vc.chat, people: vc.people)
                        settingVC.modalPresentationStyle = .fullScreen
                        observer.onNext(settingVC)
                        observer.onCompleted()
                    } catch {
                        LoggerService.shared.errorLog(error, domain: "show_chatsettingpage", message: "userId 찾기 실패로 ChatSettingViewController 생성 실패")
                        vc.reactor.action.onNext(.setError(ErrorMapper.mapToPresentationError(error)))
                        observer.onCompleted()
                    }
                    return Disposables.create()
                }
            }
            .subscribe(onNext: { [weak self] settingVC in
                self?.present(settingVC, animated: false)
            })
            .disposed(by: disposeBag)
    }
    private func setupUI() {
        view.addSubviews(views: [infoView, teamInfoView, topDivider, partyInfoLabel, tableView, bottomDivider ,buttonView])
        infoView.addSubviews(views: [infoLabel, partyNumLabel, titleLabel, indicatorImageView])
        teamInfoView.addSubviews(views: [homeTeamImageView, vsLabel, awayTeamImageView])
        buttonView.addSubviews(views: [exitButton, rightBtnStackView])
        rightBtnStackView.addArrangedSubview(notiButton)
        rightBtnStackView.addArrangedSubview(settingButton)
        
        let safeArea = view.safeAreaLayoutGuide
        infoView.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(24)
            make.leading.trailing.equalTo(safeArea).inset(20)
        }
        teamInfoView.snp.makeConstraints { make in
            make.top.equalTo(infoView.snp.bottom).offset(12)
            make.leading.trailing.equalTo(safeArea).inset(20)
        }
        topDivider.snp.makeConstraints { make in
            make.top.equalTo(teamInfoView.snp.bottom).offset(16)
            make.leading.trailing.equalTo(safeArea).inset(20)
            make.height.equalTo(1)
        }
        partyInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(topDivider.snp.bottom).offset(16)
            make.leading.equalTo(safeArea).offset(18)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(partyInfoLabel.snp.bottom).offset(12)
            make.leading.trailing.equalTo(safeArea)
        }
        bottomDivider.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom).offset(16)
            make.leading.trailing.equalTo(safeArea).inset(20)
            make.height.equalTo(1)
        }
        buttonView.snp.makeConstraints { make in
            make.top.equalTo(bottomDivider.snp.bottom).offset(16)
            make.leading.trailing.equalTo(safeArea).inset(20)
            make.bottom.equalTo(safeArea).inset(16)
        }
        
        //infoView
        infoLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }
        partyNumLabel.snp.makeConstraints { make in
            make.top.equalTo(infoLabel.snp.bottom).offset(5)
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        partyNumLabel.setContentHuggingPriority(.required, for: .horizontal)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(partyNumLabel.snp.trailing).offset(6)
            make.centerY.equalTo(partyNumLabel)
        }
        indicatorImageView.snp.makeConstraints { make in
            make.size.equalTo(20)
            make.centerY.equalToSuperview()
            make.leading.equalTo(titleLabel.snp.trailing).offset(10)
            make.trailing.equalToSuperview()
        }
        
        //teamInfoView
        teamInfoView.backgroundColor = .grayScale50
        teamInfoView.layer.cornerRadius = 8
        
        vsLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        homeTeamImageView.snp.makeConstraints { make in
            make.trailing.equalTo(vsLabel.snp.leading).inset(-24)
            make.size.equalTo(50)
            make.top.bottom.equalToSuperview().inset(16)
        }
        awayTeamImageView.snp.makeConstraints { make in
            make.leading.equalTo(vsLabel.snp.trailing).offset(24)
            make.size.equalTo(50)
            make.top.bottom.equalToSuperview().inset(16)
        }
        
        //buttonView
        exitButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.size.equalTo(20)
        }
        rightBtnStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        notiButton.snp.makeConstraints { make in
            make.size.equalTo(20)
        }
        settingButton.snp.makeConstraints { make in
            make.size.equalTo(20)
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatRoomPeopleListCell", for: indexPath) as? ChatRoomPeopleListCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        let person = people[indexPath.row]
        cell.configData(person, isMy: person.senderId == userId, isManager: person.senderId == chat.managerInfo.id, isHiddenExportButton: true)
        return cell
        
    }
    // UITableViewDelegate: 셀 높이 지정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
}


final class ChatRoomPeopleListCell: UITableViewCell {
    var disposeBag = DisposeBag()
    private let imageSize = 40.0
    private let profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    private let myImageBedge: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let managerImageBedge: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmHeadLineTextColor
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let exportButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.plain()
        let title = "내보내기"
        var attributedTitle = AttributedString(title)
        attributedTitle.font = UIFont.body02_medium
        attributedTitle.foregroundColor = UIColor.grayScale500

        config.attributedTitle = attributedTitle
        config.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4)
        button.configuration = config
        
        button.backgroundColor = .grayScale100
        button.clipsToBounds = true
        button.layer.cornerRadius = 2
        return button
    }()
    
    var exportButtonTapped: Observable<Void> {
        return exportButton.rx.tap.asObservable()
    }

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
        profileImage.isHidden = false
        managerImageBedge.isHidden = false
        nicknameLabel.text = nil
        profileImage.image = nil
        exportButton.isHidden = true
        disposeBag = DisposeBag()
    }

    func configData(_ person: SenderInfo, isMy: Bool, isManager: Bool, isHiddenExportButton: Bool) {
        ImageLoadHelper.loadImage(profileImage, pictureString: person.imageUrl)
        profileImage.layer.cornerRadius = imageSize / 2
        nicknameLabel.text = person.nickName
        nicknameLabel.applyStyle(textStyle: FontSystem.body02_medium)
        myImageBedge.image = UIImage(named: "myBedge")
        managerImageBedge.image = UIImage(named: "king")
        myImageBedge.isHidden = !isMy
        managerImageBedge.isHidden = !isManager
        exportButton.isHidden = isHiddenExportButton
        layoutIfNeeded()
    }
    
    private func setupUI() {
        contentView.addSubviews(views: [profileImage, stackView])
        stackView.addArrangedSubview(myImageBedge)
        stackView.addArrangedSubview(managerImageBedge)
        stackView.addArrangedSubview(nicknameLabel)
        stackView.addArrangedSubview(exportButton)
        
        profileImage.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.leading.equalToSuperview().offset(18)
            make.size.equalTo(imageSize)
        }
        stackView.snp.makeConstraints { make in
            make.leading.equalTo(profileImage.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(18)
            make.centerY.equalTo(profileImage)
        }
        
        myImageBedge.setContentHuggingPriority(.required, for: .horizontal)
        managerImageBedge.setContentHuggingPriority(.required, for: .horizontal)
    }
}
