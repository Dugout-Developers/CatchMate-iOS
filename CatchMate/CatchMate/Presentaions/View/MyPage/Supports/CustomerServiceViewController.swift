//
//  CustomerServiceViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 8/8/24.
//

import UIKit
import RxSwift

enum CustomerServiceMenu: String, CaseIterable {
    case account = "계정, 로그인 관련"
    case post = "게시글 관련"
    case chat = "채팅 관련"
    case user = "유저 관련"
    case etc = "기타"
    
    var serverRequest: String {
        switch self {
        case .account:
            return "ACCOUNT"
        case .post:
            return "POST"
        case .chat:
            return "CHAT"
        case .user:
            return "USER"
        case .etc:
            return "OTHER"
        }
    }
}
final class CustomerServiceViewController: BaseViewController {
    private let menus = CustomerServiceMenu.allCases
    private var user: UserInfoDTO
    private let titleNameLabel : UILabel = {
        let label = UILabel()
        label.text = "닉네임님,"
        label.textColor = .grayScale800
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    private let titleInfoLabel : UILabel = {
        let label = UILabel()
        label.text = "무엇을 도와드릴까요?"
        label.textColor = .grayScale800
        label.applyStyle(textStyle: FontSystem.headline01_medium)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    private let tableView = UITableView()
    override var useSnapKit: Bool {
        return true
    }
    override var buttonContainerExists: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLeftTitle("고객센터")
        view.backgroundColor = .grayScale50
        setupNickName()
        setupTableView()
        setupUI()
        bind()
    }
    private func setupNickName() {
        titleNameLabel.text = "\(user.nickname)님,"
        titleNameLabel.applyStyle(textStyle: FontSystem.headline01_medium)
    }
    init(user: UserInfoDTO) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTableView() {
        tableView.register(CustomerServiceCell.self, forCellReuseIdentifier: "CustomerServiceCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
    }
    private func setupUI() {
        view.addSubviews(views: [titleInfoLabel, titleNameLabel, tableView])
        titleNameLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(MainGridSystem.getMargin())
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
        }
        titleInfoLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(titleNameLabel)
            make.top.equalTo(titleNameLabel.snp.bottom)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleInfoLabel.snp.bottom).offset(20)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func bind() {
        Observable.just(menus)
            .bind(to: tableView.rx.items(cellIdentifier: "CustomerServiceCell", cellType: CustomerServiceCell.self)) {  (row, item, cell) in
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
                cell.configData(item.rawValue)
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .withUnretained(self)
            .subscribe { vc, indexPath in
                let menu = vc.menus[indexPath.row]
                let nextVC = CustomerServiceAddViewController(menu: menu)
                vc.navigationController?.pushViewController(nextVC, animated: true)
            }
            .disposed(by: disposeBag)
    }
}

final class CustomerServiceCell: UITableViewCell {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grayScale800
        return label
    }()
    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .cmStrokeColor
        return view
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
        titleLabel.text = nil
    }
    func configData(_ title: String) {
        titleLabel.text = title
        titleLabel.applyStyle(textStyle: FontSystem.body01_medium)
    }
    func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(divider)
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(MainGridSystem.getMargin())
            make.top.equalToSuperview().inset(16)

        }
        divider.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalTo(titleLabel)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
}
