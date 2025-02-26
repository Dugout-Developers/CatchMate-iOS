//
//  SendMateListViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 8/8/24.
//

import UIKit
import SnapKit
import RxSwift
import ReactorKit

final class SendMateListViewController: BaseViewController, View {
    override var useSnapKit: Bool {
        return true
    }
    override var buttonContainerExists: Bool {
        return false
    }
    
    private let tableView = UITableView()
    var reactor: SendMateReactor
    
    init(reactor: SendMateReactor) {
        self.reactor = reactor
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reactor.action.onNext(.loadSendMate)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLeftTitle("보낸 신청")
        setupUI()
        setupTableView()
        bind(reactor: reactor)
    }
    private func setupTableView() {
        tableView.register(ListCardViewTableViewCell.self, forCellReuseIdentifier: "ListCardViewTableViewCell")
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
            make.leading.trailing.equalToSuperview()
        }
    }
}

// MARK: - Bind
extension SendMateListViewController {
    func bind(reactor: SendMateReactor) {
        reactor.state.map{$0.sendMates}
            .bind(to: tableView.rx.items(cellIdentifier: "ListCardViewTableViewCell", cellType: ListCardViewTableViewCell.self)) { (row, item, cell) in
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
                cell.setupData(item)
                cell.updateConstraints()
            }
            .disposed(by: disposeBag)

        tableView.rx.itemSelected
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { vc, indexPath in
                let post = reactor.currentState.sendMates[indexPath.row]
                let postDetailVC = PostDetailViewController(postID: post.id)
                vc.navigationController?.pushViewController(postDetailVC, animated: true)
            })
            .disposed(by: disposeBag)
        
        tableView.rx.contentOffset
            .skip(1)
            .distinctUntilChanged()
            .withUnretained(self)
            .map { vc, offset in
                let offsetY = offset.y
                let contentHeight = vc.tableView.contentSize.height
                let threshold = contentHeight - vc.tableView.frame.size.height - (vc.tableView.rowHeight * 4)
                return (vc, offsetY, threshold)
            }
            .filter { vc, offsetY, threshold in
                offsetY > threshold &&
                !reactor.currentState.isLoading &&
                !reactor.currentState.isLast
            }
            .subscribe(onNext: { vc, _, _ in
                reactor.action.onNext(.loadNextPage)
            })
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
