//
//  ReceiveMateListViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 8/8/24.
//

import UIKit
import SnapKit
import RxSwift
import ReactorKit

final class ReceiveMateListViewController: BaseViewController, View {
    private let tableView = UITableView()
    var reactor: RecevieMateReactor
    
    init(reactor: RecevieMateReactor) {
        self.reactor = reactor
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reactor.action.onNext(.loadReceiveMate)
        reactor.action.onNext(.selectPost(nil))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLeftTitle("받은 신청")
        setupUI()
        setupTableView()
        bind(reactor: reactor)
    }
    private func setupTableView() {
        tableView.register(ReceiveMateListCell.self, forCellReuseIdentifier: "ReceiveMateListCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
    }
    private func setupUI() {
        view.backgroundColor = .grayScale50
        tableView.backgroundColor = .clear
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.bottom.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview().inset(MainGridSystem.getMargin())
        }
    }
}
// MARK: - Bind
extension ReceiveMateListViewController {
    func bind(reactor: RecevieMateReactor) {
        reactor.state.map{$0.receiveMates}
            .bind(to: tableView.rx.items(cellIdentifier: "ReceiveMateListCell", cellType: ReceiveMateListCell.self)) { (row, item, cell) in
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
                cell.configData(apply: item)
                cell.updateConstraints()
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe { indexPath in
                let applies = reactor.currentState.receiveMates[indexPath.row]
                let detailVC = ReceiveMateListDetailViewController(reactor: ReceiveMateDetailReactor(aplies: applies))
                detailVC.modalPresentationStyle = .overFullScreen
                self.present(detailVC, animated: false)
            }
            .disposed(by: disposeBag)
    }
}
