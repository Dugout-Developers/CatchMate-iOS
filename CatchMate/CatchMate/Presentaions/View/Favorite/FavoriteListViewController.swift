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
    override var useSnapKit: Bool {
        return true
    }
    override var buttonContainerExists: Bool {
        return false
    }
    private let tableView = UITableView()
    private let reactor: FavoriteReactor
    private let emptyViewContainer = EmptyView(type: .favorite)

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
        tabBarController?.tabBar.isHidden = false
        reactor.action.onNext(.loadFavoritePost)
        reactor.action.onNext(.selectPost(nil))
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLeftTitle("찜 목록")
        setupTableview()
        setupUI()
        bind(reactor: reactor)
        view.backgroundColor = .grayScale50
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
                return Reactor.Action.selectPost(post.id)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
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
            .map { _ in FavoriteReactor.Action.loadNextPage }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.selectedPost}
            .distinctUntilChanged()
            .compactMap{$0}
            .withUnretained(self)
            .subscribe { vc, postId in
                let postDetailVC = PostDetailViewController(postID: postId)
                postDetailVC.hidesBottomBarWhenPushed = true
                vc.navigationController?.pushViewController(postDetailVC, animated: true)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.favoritePost}
            .bind(to: tableView.rx.items(cellIdentifier: "ListCardViewTableViewCell", cellType: ListCardViewTableViewCell.self)) {  row, item, cell in
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
                cell.setupData(item, isFavoriteCell: true)
                cell.updateConstraints()


                cell.tapEvent
                    .withUnretained(cell)
                    .map { $0.0.post }
                    .compactMap { $0 }
                    .map{$0.id}
                    .map { Reactor.Action.removeFavoritePost($0) }
                    .bind(to: reactor.action)
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        reactor.state.map{$0.favoritePost.count == 0}
            .withUnretained(self)
            .subscribe { vc, isEmpty in
                vc.changeView(isEmpty)
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
    
    private func changeView(_ isEmpty: Bool) {
        if isEmpty {
            tableView.isHidden = true
            emptyViewContainer.isHidden = false
        } else {
            tableView.isHidden = false
            emptyViewContainer.isHidden = true
        }
    }
    
    private func setupUI() {
        view.addSubviews(views: [tableView, emptyViewContainer])
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        emptyViewContainer.snp.makeConstraints { make in
            make.center.equalTo(view.safeAreaLayoutGuide)
        }

    }
}
