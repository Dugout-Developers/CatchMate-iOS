//
//  ChatListViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 6/14/24.
//

import UIKit
import RxSwift
import SnapKit
import ReactorKit
import FlexLayout
import Alamofire
import RxAlamofire

final class ChatListViewController: BaseViewController, View {
    private let chatListTableView = UITableView()
    var reactor: ChatListReactor
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        reactor.action.onNext(.selectChat(nil))
        reactor.action.onNext(.loadChatList)
        NotificationListDataSourceImpl(tokenDataSource: TokenDataSourceImpl()).loadNotificationList()
            .subscribe { dtoList in
                print(dtoList)
            }
            .disposed(by: disposeBag)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupUI()
        setupTableView()
        setupNavigationBar()
        bind(reactor: reactor)
    }
    
    private func setupView() {
        view.backgroundColor = .cmBackgroundColor
    }
    
    init() {
        self.reactor = ChatListReactor()
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupNavigationBar() {
        setupLeftTitle("채팅목록")
    }
    
    private func setupTableView() {
        chatListTableView.register(ChatListTableViewCell.self, forCellReuseIdentifier: "ChatListTableViewCell")
        chatListTableView.tableHeaderView = UIView()
        chatListTableView.rowHeight = UITableView.automaticDimension
        chatListTableView.backgroundColor = .clear
        chatListTableView.separatorStyle = .none
    }
    

}
// MARK: - Bind
extension ChatListViewController {
    func bind(reactor: ChatListReactor) {
        reactor.state.map{$0.chatList}
            .bind(to: chatListTableView.rx.items(cellIdentifier: "ChatListTableViewCell", cellType: ChatListTableViewCell.self)) {  (row, item, cell) in
                cell.selectionStyle = .none
                cell.configData(chat: item)
                cell.updateConstraints()
            }
            .disposed(by: disposeBag)
        
        chatListTableView.rx.itemSelected
            .map { indexPath in
                let chat = reactor.currentState.chatList[indexPath.row]
                return Reactor.Action.selectChat(chat)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.selectedChat}
            .compactMap{$0}
            .withUnretained(self)
            .subscribe(onNext: { vc, chat in
                let roomVC = ChatRoomViewController(chat: chat)
                roomVC.hidesBottomBarWhenPushed = true
                vc.navigationController?.pushViewController(roomVC, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
// MARK: - UI
extension ChatListViewController {
    private func setupUI() {
        view.addSubview(chatListTableView)
        chatListTableView.snp.makeConstraints { make in
            make.top.bottom.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(18)
        }
    }
}
