//
//  BlockSettingViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 10/4/24.
//

import UIKit
import ReactorKit
import SnapKit
import FlexLayout
import PinLayout
import ReactorKit

final class BlockSettingViewController: BaseViewController, View {
    override var useSnapKit: Bool {
        return false
    }
    override var buttonContainerExists: Bool {
        return true
    }
    private let reactor: BlockUserReactor
    private let tableView = UITableView()
    private let emptyViewContainer = UIView()
    private let emptyImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "favoriteNone"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let emptyTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "차단한 사용자가 없어요"
        label.textColor = .cmHeadLineTextColor
        label.applyStyle(textStyle: FontSystem.headline03_semiBold)
        return label
    }()
    override func viewWillAppear(_ animated: Bool) {
        reactor.action.onNext(.loadBlockUser)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLeftTitle("차단 설정")
        setupTableView()
        setupUI()
        bind(reactor: reactor)
    }
    init() {
        self.reactor = DIContainerService.shared.makeBlockUserReactor()
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTableView() {
        tableView.register(BlockUserProfileCell.self, forCellReuseIdentifier: "BlockUserProfileCell")
//        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 56
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
    }
    private func changeView(_ isEmpty: Bool) {
        if isEmpty {
            tableView.isHidden = true
            emptyViewContainer.isHidden = false
        } else {
            tableView.isHidden = false
            emptyViewContainer.isHidden = true
        }
    }
    func bind(reactor: BlockUserReactor) {
        tableView.rx.contentOffset
            .map { [weak self] _ in
                guard let self = self else { return false }
                let offsetY = self.tableView.contentOffset.y
                let contentHeight = self.tableView.contentSize.height
                let threshold = contentHeight - self.tableView.frame.size.height - (self.tableView.rowHeight * 4)
                return offsetY > threshold
            }
            .distinctUntilChanged()
            .filter { $0 }
            .map { _ in BlockUserReactor.Action.loadNextPage }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.blockUsers}
            .bind(to: tableView.rx.items(cellIdentifier: "BlockUserProfileCell", cellType: BlockUserProfileCell.self)) {  row, user, cell in
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
                cell.setupData(user)
                
                cell.unblockButton.rx.tap
                    .map{user}
                    .compactMap{$0}
                    .withUnretained(self)
                    .subscribe(onNext: { vc, user in
                        vc.showCMAlert(titleText: "'\(user.nickName)'\n차단을 해제할까요?", importantButtonText: "해제", commonButtonText: "취소") {
                            print(user)
                            vc.reactor.action.onNext(.unblockUser(user.userId))
                        } commonAction: {
                            self.dismiss(animated: false)
                        }

                    })
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)

        reactor.state.map{$0.blockUsers.count == 0}
            .withUnretained(self)
            .subscribe { vc, isEmpty in
                vc.changeView(isEmpty)
            }
            .disposed(by: disposeBag)
    }
    private func setupUI() {
        view.addSubviews(views: [tableView, emptyViewContainer])
        tableView.snp.makeConstraints { make in
            make.top.bottom.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview().inset(18)
        }
        emptyViewContainer.addSubviews(views: [emptyImageView, emptyTitleLabel])
        emptyViewContainer.snp.makeConstraints { make in
            make.center.equalTo(view.safeAreaLayoutGuide)
        }
        emptyImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.size.equalTo(88)
        }
        emptyTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyImageView.snp.bottom).offset(48)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

final class BlockUserProfileCell: UITableViewCell {
    var disposeBag = DisposeBag()
    private let containerView = UIView()
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    private let nickNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmHeadLineTextColor
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    let unblockButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.plain()
        let title = "차단 해제"
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
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.pin.top(16).left().right().bottom()
        containerView.flex.layout(mode: .adjustHeight)
        contentView.frame.size.height = 56
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        containerView.pin.width(size.width)
        containerView.flex.layout(mode: .adjustHeight)
        let height = containerView.frame.height + 16 // 16 위쪽 padding + 16 아래쪽 padding
        return CGSize(width: size.width, height: height)
    }
    override func prepareForReuse() {
        super.prepareForReuse()

        self.disposeBag = DisposeBag() // 새로운 DisposeBag으로 초기화
        self.profileImageView.image = nil
        self.nickNameLabel.text = nil
        
    }
    func setupData(_ user: SimpleUser) {
        ImageLoadHelper.loadImage(profileImageView, pictureString: user.picture)
        nickNameLabel.text = user.nickName
        nickNameLabel.applyStyle(textStyle: FontSystem.body02_medium)
    }
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.flex.direction(.row).justifyContent(.start).alignItems(.center).width(100%).define { flex in
            flex.addItem(profileImageView).size(40).cornerRadius(20)
            flex.addItem(nickNameLabel).marginHorizontal(8).grow(1).shrink(1)
            flex.addItem(unblockButton)
        }
    }
}

