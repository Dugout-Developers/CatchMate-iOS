//
//  FavoriteListViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 7/11/24.
//

import UIKit
import RxSwift
import ReactorKit
import SnapKit

final class FavoriteListViewController: BaseViewController ,View {
    private let tableView = UITableView()
    private let reactor: FavoriteReactor

    init(reactor: FavoriteReactor) {
        self.reactor = reactor
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reactor.action.onNext(.loadFavoritePost)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLeftTitle("찜 목록")
        setupTableview()
        setupUI()
        bind(reactor: reactor)
        reactor.action.onNext(.loadFavoritePost)
    }
    
    private func setupTableview() {
        tableView.register(ListCardViewTableViewCell.self, forCellReuseIdentifier: "ListCardViewTableViewCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 178
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
    }
    
    func bind(reactor: FavoriteReactor) {
        tableView.rx.itemSelected
            .map { indexPath in
                let post = reactor.currentState.favoritePost[indexPath.row]
                return Reactor.Action.selectPost(post)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.selectedPost}
            .distinctUntilChanged()
            .compactMap{$0}
            .withUnretained(self)
            .subscribe { vc, post in
                let postDetailVC = PostDetailViewController(postID: post.id)
                vc.navigationController?.pushViewController(postDetailVC, animated: true)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.favoritePost}
            .bind(to: tableView.rx.items(cellIdentifier: "ListCardViewTableViewCell", cellType: ListCardViewTableViewCell.self)) {  row, item, cell in
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
                cell.setupData(item, isFavoriteCell: true)
                
                
                cell.tapEvent
                    .withUnretained(cell)
                    .map { $0.0.post }
                    .compactMap { $0 }
                    .map { Reactor.Action.removeFavoritePost($0) }
                    .bind(to: reactor.action)
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
