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
        tableView.tableHeaderView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .clear
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
        
        tableView.rx.itemDeleted
          .observe(on: MainScheduler.asyncInstance)
          .withUnretained(self)
          .bind { _, indexPath in
              print("remove \(indexPath.row+1) item")
          }
          .disposed(by: disposeBag)
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
