//
//  SettingViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 8/7/24.
//

import UIKit
import RxSwift


final class SettingViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    private let settingMenus = MypageMenu.settingMenus
    private let supportMenus = MypageMenu.supportMenus
    private let tableview = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupTableView()
        setupUI()
    }
    
    private func setupNavigation() {
        setupLeftTitle("설정")
    }
    
    private func setupTableView() {
        tableview.delegate = self
        tableview.dataSource = self
        tableview.separatorStyle = .none
        tableview.register(MypageListCell.self, forCellReuseIdentifier: "MypageListCell")
        tableview.register(MypageHeader.self, forHeaderFooterViewReuseIdentifier: "MypageHeader")
        tableview.register(DividerFooterView.self, forHeaderFooterViewReuseIdentifier: "DividerFooterView")
        tableview.sectionHeaderTopPadding = 0
    }
    private func setupUI() {
        tableview.backgroundColor = .grayScale50
        view.addSubview(tableview)
        tableview.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return settingMenus.count
        case 1:
            return supportMenus.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MypageListCell", for: indexPath) as? MypageListCell else {
            return UITableViewCell()
        }
        let menu = indexPath.section == 0 ? settingMenus[indexPath.row] : supportMenus[indexPath.row]
        cell.configData(title: menu.rawValue)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            settingMenus[indexPath.row].navigationVC()
                .catch({ [weak self] error in
                    guard let self = self else { return Observable.empty() }
                    if let error = error as? PresentationError {
                        switch error {
                        case .retryable(let message):
                            showToast(message: message)
                        case .contactSupport(let message):
                            showToast(message: message)
                        case .showErrorPage(let message):
                            break
                        case .informational(let message):
                            showToast(message: message)
                        case .validationFailed(let message):
                            showToast(message: message)
                        case .unauthorized(let message):
                            showAlert(message: message){}
                        case .timeout(let message):
                            showToast(message: message)
                        case .unknown(let message):
                            LoggerService.shared.log(message, level: .error)
                            showToast(message: "예기치 못한 오류가 발생했습니다. 다시 시도해주세요.")
                        }
                    }
                    return Observable.empty()
                })
                .withUnretained(self)
                .subscribe { vc, nextVC in
                    vc.navigationController?.pushViewController(nextVC, animated: true)
                }
                .disposed(by: disposeBag)
        case 1:
            supportMenus[indexPath.row].navigationVC()
                .withUnretained(self)
                .subscribe { vc, nextVC in
                    vc.navigationController?.pushViewController(nextVC, animated: true)
                }
                .disposed(by: disposeBag)
        default:
            break
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "MypageHeader") as? MypageHeader else { return UIView() }
        if section == 0 {
            headerView.configData(title: "사용자 설정")
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
        return 48
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 53
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8
    }
    
}


