//
//  MyPageViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 6/14/24.
//

import UIKit
import RxSwift

class MyPageViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource  {
    private var user: User? = User(id: "11", snsID: "11", email: "dd", nickName: "한화화나", age: 24, team: .hanhwa, gener: .woman, cheerStyle: .cheerleader, profilePicture: "https://cloudfront-ap-northeast-1.images.arcpublishing.com/chosun/GVJVDKERHREIPJJHZHNNHHOUTI.jpg")
    private let tableview = UITableView()
    private let supportMenus = MypageMenu.supportMenus
    private let myMenus = MypageMenu.myMenus
    private let logoutButton = CMDefaultFilledButton(title: "임시 로그아웃임둥")
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupTableView()
        setupUI()
        bind()
    }
    
    private func setupNavigation() {
        setupLeftTitle("내 정보")
    }
    
    private func setupTableView() {
        tableview.delegate = self
        tableview.dataSource = self
        tableview.separatorStyle = .none
        tableview.register(MyPageProfileCell.self, forCellReuseIdentifier: "MyPageProfileCell")
        tableview.register(MypageListCell.self, forCellReuseIdentifier: "MypageListCell")
        tableview.register(MypageHeader.self, forHeaderFooterViewReuseIdentifier: "MypageHeader")
        tableview.register(DividerFooterView.self, forHeaderFooterViewReuseIdentifier: "DividerFooterView")
        tableview.estimatedSectionHeaderHeight = 0
         tableview.estimatedSectionFooterHeight = 0
        tableview.sectionHeaderTopPadding = 0
    }
    private func setupUI() {
        tableview.backgroundColor = .grayScale50
        view.addSubview(tableview)
        view.addSubview(logoutButton)
        tableview.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        logoutButton.snp.makeConstraints { make in
            make.top.equalTo(tableview.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(ButtonGridSystem.getMargin())
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-30)
            make.height.equalTo(52)
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return myMenus.count
        } else {
            return supportMenus.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = MyPageProfileCell(style: .default, reuseIdentifier: nil)
            cell.configData(user)
            cell.updateConstraints()
            cell.selectionStyle = .none
            return cell
        } else if indexPath.section == 1 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MypageListCell", for: indexPath) as? MypageListCell else {
                return UITableViewCell()
            }
            cell.configData(title: myMenus[indexPath.row].rawValue)
            cell.selectionStyle = .none
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MypageListCell", for: indexPath) as? MypageListCell else {
                return UITableViewCell()
            }
            cell.configData(title: supportMenus[indexPath.row].rawValue)
            cell.selectionStyle = .none
            return cell
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
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
        return section == 0 ? 0 : 48
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 88
        } else {
            return 53
        }
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8
    }
}

// MARK: - Bind
extension MyPageViewController {
    func bind() {
        logoutButton.rx.tap
            .take(1)
            .withUnretained(self)
            .subscribe { vc, _ in
                // 임시
                let logoutDS = LogoutDataSourceImpl()
                guard let refreshToken = KeychainService.getToken(for: .refreshToken) else {
                    let reactor = DIContainerService.shared.makeAuthReactor()
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootView(SignInViewController(reactor: reactor), animated: true)
                    return
                }
                logoutDS.logout(token: refreshToken)
                    .subscribe { result in
                        if result {
                            LoggerService.shared.debugLog("로그아웃")
                            _ = KeychainService.deleteToken(for: .accessToken)
                            _ = KeychainService.deleteToken(for: .refreshToken)
                            let reactor = DIContainerService.shared.makeAuthReactor()
                            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootView(SignInViewController(reactor: reactor), animated: true)
                        }
                    }
    
                    .disposed(by: vc.disposeBag)
            }
            .disposed(by: disposeBag)
    }
}
