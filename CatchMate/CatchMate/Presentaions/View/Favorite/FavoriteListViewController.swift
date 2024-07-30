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
    private let emptyViewContainer = UIView()
    private let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "EmptyDisable"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let emptyTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "찜한 게시글이 없어요"
        label.textColor = .cmHeadLineTextColor
        label.applyStyle(textStyle: FontSystem.headline03_semiBold)
        return label
    }()
    private let emptySubLabel: UILabel = {
        let label = UILabel()
        label.text = "야구 팬들이 올린 다양한 글을 둘러보고\n마음에 드는 직관 글을 저장해보세요!"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .cmNonImportantTextColor
        label.applyStyle(textStyle: FontSystem.contents)
        return label
    }()
    
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
                cell.updateConstraints()
                
                cell.tapEvent
                    .withUnretained(cell)
                    .map { $0.0.post }
                    .compactMap { $0 }
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
        emptyViewContainer.addSubviews(views: [imageView, emptyTitleLabel, emptySubLabel])
        emptyViewContainer.snp.makeConstraints { make in
            make.center.equalTo(view.safeAreaLayoutGuide)
        }
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.size.equalTo(88)
        }
        emptyTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(48)
            make.centerX.equalToSuperview()
        }
        emptySubLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyTitleLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
