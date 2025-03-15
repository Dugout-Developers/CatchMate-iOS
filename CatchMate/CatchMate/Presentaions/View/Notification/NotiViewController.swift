//
//  NotiViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 6/14/24.
//

import UIKit
import RxSwift
import ReactorKit

final class NotiViewController: BaseViewController, View {
    private let reactor: NotificationListReactor
    
    override var useSnapKit: Bool {
        return true
    }
    override var buttonContainerExists: Bool {
        return false
    }
    private let tableView = UITableView()
    
    init(reactor: NotificationListReactor) {
        self.reactor = reactor
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reactor.action.onNext(.loadList)
        reactor.action.onNext(.selectNoti(nil))
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.post(name: .reloadUnreadMessageState, object: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .cmBackgroundColor
        setupUI()
        setupTableView()
        setupLeftTitle("알림")
        bind(reactor: reactor)
    }
    private func setupTableView() {
        tableView.register(NotiViewTableViewCell.self, forCellReuseIdentifier: "NotiViewTableViewCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
    }
}
// MARK: - Bind
extension NotiViewController {
    func bind(reactor: NotificationListReactor) {
        reactor.state.map{$0.notifications}
            .bind(to: tableView.rx.items(cellIdentifier: "NotiViewTableViewCell", cellType: NotiViewTableViewCell.self)) { (row, item, cell) in
                cell.selectionStyle = .none
                cell.configData(noti: item)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.selectedNoti}
            .compactMap{$0}
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe { vc, noti in
                switch noti.type {
                case .receivedView:
                    let receivedVC = ReceiveMateListViewController(reactor: DIContainerService.shared.makeReciveMateReactor(), id: String(noti.boardId))
                    
                    vc.navigationController?.pushViewController(receivedVC, animated: true)
                case .chatRoom:
                    vc.navigateToRootAndSwitchTab()
                case .none:
                    vc.showCMAlert(titleText: "이미 처리된 알림이에요", importantButtonText: "확인", commonButtonText: nil)
                }
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemDeleted
          .observe(on: MainScheduler.asyncInstance)
          .withUnretained(self)
          .bind { vc, indexPath in
              vc.reactor.action.onNext(.deleteNoti(indexPath.row))
          }
          .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe { indexPath in
                let noti = reactor.currentState.notifications[indexPath.row]
                reactor.action.onNext(.selectNoti(noti))
            }
            .disposed(by: disposeBag)
        
        tableView.rx.contentOffset
            .skip(1)
            .map { [weak self] _ in
                guard let self = self else { return false }
                let offsetY = self.tableView.contentOffset.y
                let contentHeight = self.tableView.contentSize.height
                let threshold = contentHeight - self.tableView.frame.size.height - (self.tableView.rowHeight * 4)
                return offsetY > threshold
            }
            .distinctUntilChanged()
            .filter { $0 }
            .map { _ in NotificationListReactor.Action.loadNextPage }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func navigateToRootAndSwitchTab() {
        guard let tabBarController = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?.rootViewController as? UITabBarController else {
            print("탭바 컨트롤러를 찾을 수 없습니다.")
            return
        }

        tabBarController.selectedIndex = 3

        if let navigationController = tabBarController.viewControllers?[3] as? UINavigationController {
            navigationController.popToRootViewController(animated: false)
        }
    }
}
// MARK: - UI
extension NotiViewController {
    private func setupUI() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
