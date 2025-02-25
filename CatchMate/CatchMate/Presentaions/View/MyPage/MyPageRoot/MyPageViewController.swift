//
//  MyPageViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 6/14/24.
//

import UIKit
import RxSwift
import ReactorKit

class MyPageViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, View  {
    override var useSnapKit: Bool {
        return true
    }
    override var buttonContainerExists: Bool {
        return true
    }
    private var user: User?
    private var receiveCount: Int?
    private let tableview = UITableView()
    private let supportMenus = MypageMenu.supportMenus
    private let myMenus = MypageMenu.myMenus
    private let reactor: MyPageReactor
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        reactor.action.onNext(.loadUser)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupTableView()
        setupUI()
        bind(reactor: reactor)
    }
    
    init(reactor: MyPageReactor) {
        self.reactor = reactor
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupNavigation() {
        setupLeftTitle("내 정보")
        let settingButton = UIButton()
        settingButton.setImage(UIImage(named: "setting")?.withTintColor(.grayScale700, renderingMode: .alwaysOriginal), for: .normal)
        settingButton.addTarget(self, action: #selector(clickSettingButton), for: .touchUpInside)
        customNavigationBar.addRightItems(items: [settingButton])
    }
    @objc private func clickSettingButton(_ sender: UIButton) {
        let settingVC = SettingViewController()
        navigationController?.pushViewController(settingVC, animated: true)
    }
    
    private func setupTableView() {
        tableview.delegate = self
        tableview.dataSource = self
        tableview.separatorStyle = .none
        tableview.register(MyPageProfileCell.self, forCellReuseIdentifier: "MyPageProfileCell")
        tableview.register(MypageListCell.self, forCellReuseIdentifier: "MypageListCell")
        tableview.register(MypageHeader.self, forHeaderFooterViewReuseIdentifier: "MypageHeader")
        tableview.register(DividerFooterView.self, forHeaderFooterViewReuseIdentifier: "DividerFooterView")
        tableview.register(LogoutCell.self, forCellReuseIdentifier: "LogoutCell")
        tableview.estimatedSectionHeaderHeight = 0
        tableview.estimatedSectionFooterHeight = 0
        tableview.sectionHeaderTopPadding = 0
    }
    private func setupUI() {
        tableview.backgroundColor = .grayScale50
        view.addSubview(tableview)
        tableview.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return myMenus.count
        case 2:
            return supportMenus.count
        case 3:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyPageProfileCell", for: indexPath) as? MyPageProfileCell else {
                return UITableViewCell()
            }
            if let user {
                cell.configData(SimpleUser(user: user))
            }
            cell.selectionStyle = .none
            return cell
        case 1, 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MypageListCell", for: indexPath) as? MypageListCell else {
                return UITableViewCell()
            }
            let menu = indexPath.section == 1 ? myMenus[indexPath.row] : supportMenus[indexPath.row]
            let bedge = indexPath.section == 1 && indexPath.row == 2 ? receiveCount : nil
            cell.configData(title: menu.rawValue, bedge: bedge)
            cell.selectionStyle = .none
            return cell
        case 3:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LogoutCell", for: indexPath) as? LogoutCell else {
                return UITableViewCell()
            }
            cell.logoutTapped
                .take(1)
                .map{ Reactor.Action.logout }
                .bind(to: reactor.action)
                .disposed(by: cell.disposeBag)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            guard let user = user else { return }
            let profileEditUseCase = DIContainerService.shared.makeProfileEditUseCase()
            let nicknameUseCase = DIContainerService.shared.makeNickNameCheckUseCase()
            let profileEditVC = ProfileEditViewController(reactor: ProfileEditReactor(user: user, usecase: profileEditUseCase, nicknameUsecase: nicknameUseCase), imageString: user.profilePicture)
            profileEditVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(profileEditVC, animated: true)
        case 1:
            if let user = user {
                myMenus[indexPath.row].navigationVC(user: SimpleUser(user: user))
                    .throttle(.seconds(3), latest: false, scheduler: MainScheduler.instance)
                    .withUnretained(self)
                    .subscribe { vc, nextVC in
                        nextVC.hidesBottomBarWhenPushed = true
                        vc.navigationController?.pushViewController(nextVC, animated: true)
                    }
                    .disposed(by: disposeBag)
            }
        case 2:
            supportMenus[indexPath.row].navigationVC()
                .throttle(.seconds(3), latest: false, scheduler: MainScheduler.instance)
                .withUnretained(self)
                .subscribe { vc, nextVC in
                    nextVC.hidesBottomBarWhenPushed = true
                    vc.navigationController?.pushViewController(nextVC, animated: true)
                }
                .disposed(by: disposeBag)
        default:
            break
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 || section == 3 {
            return nil // 첫 번째 섹션에 헤더 뷰 없음
        }
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "MypageHeader") as? MypageHeader else { return UIView() }
        if section == 1 {
            headerView.configData(title: "직관 생활")
        } else {
            headerView.configData(title: "지원")
        }
        return headerView
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "DividerFooterView") as? DividerFooterView else { return UIView() }
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 || section == 3 ? 0 : 48
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 88
        case 1,2:
            return 53
        case 3:
            return UITableView.automaticDimension
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8
    }
}

// MARK: - Bind
extension MyPageViewController {
    func bind(reactor: MyPageReactor) {
        reactor.state.map{$0.logoutResult}
            .distinctUntilChanged()
            .subscribe { result in
                if result {
//                    UnauthorizedErrorHandler.shared.handleError()
                    LoginUserDefaultsService.shared.deleteLoginData()
                    let reactor = DIContainerService.shared.makeAuthReactor()
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootView(UINavigationController(rootViewController: SignInViewController(reactor: reactor)), animated: true)
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.user }
            .compactMap{$0}
            .subscribe(onNext: { [weak self] user in
                let prevUser = self?.user
                self?.user = user
                if prevUser?.nickName != user.nickName || prevUser?.cheerStyle != user.cheerStyle || prevUser?.profilePicture != user.profilePicture || prevUser?.team != user.team {                    self?.tableview.reloadData()
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isLoading in
                guard let cell = self?.tableview.cellForRow(at: IndexPath(row: 0, section: 0)) as? MyPageProfileCell else { return }
                if !isLoading {
                    if let user = self?.user {
                        cell.configData(SimpleUser(user: user))
                        cell.updateConstraints()
                    }
                }
            })
            .disposed(by: disposeBag)
        reactor.state.map {$0.error}
            .compactMap{$0}
            .withUnretained(self)
            .subscribe { vc, error in
                vc.logout()
            }
            .disposed(by: disposeBag)
        reactor.state.map{$0.count}
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe { vc, count in
                vc.receiveCount = count
                vc.tableview.reloadData()
            }
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.error}
            .compactMap{$0}
            .withUnretained(self)
            .subscribe { vc, error in
                vc.handleError(error)
            }
            .disposed(by: disposeBag)
    }
}


final class LogoutCell: UITableViewCell {
    let disposeBag = DisposeBag()
        
    var logoutTapped: Observable<Void> {
        return logoutButton.rx.tap.asObservable()
    }
    private let logoutButton: UIButton = {
        let button = UIButton()
        button.setTitle("로그아웃", for: .normal)
        button.setTitleColor(.grayScale400, for: .normal)
        let underlineAttribute: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        button.applyStyle(textStyle: FontSystem.body02_medium, anyAttr: underlineAttribute)
        button.backgroundColor = .clear
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        setupUI()
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupUI() {
        contentView.addSubview(logoutButton)
        logoutButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(10)
        }
    }
}
