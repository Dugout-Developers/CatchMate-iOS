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
    override var useSnapKit: Bool {
        return true
    }
    override var buttonContainerExists: Bool {
        return false
    }
    private let chatListTableView = UITableView()
    private let emptyView = EmptyView(type: .chat)
    var reactor: ChatListReactor
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        reactor.action.onNext(.selectChat(nil))
        reactor.action.onNext(.loadChatList)
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
    
    init(reactor: ChatListReactor) {
        self.reactor = reactor
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupNavigationBar() {
        setupLeftTitle("채팅")
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
            .bind(to: chatListTableView.rx.items(cellIdentifier: "ChatListTableViewCell", cellType: ChatListTableViewCell.self)) { (row, item, cell) in
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
            .subscribe(onNext: { vc, _ in
                let chat = Chat.mockupData[0]
                let roomVC = ChatRoomViewController(chat: chat)
                roomVC.hidesBottomBarWhenPushed = true
                vc.navigationController?.pushViewController(roomVC, animated: true)
            })
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.chatList.isEmpty}
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe { vc, isEmpty in
                vc.changeView(isEmpty)
            }
            .disposed(by: disposeBag)
    }
}
// MARK: - UI
extension ChatListViewController {
    
    private func changeView(_ isEmpty: Bool) {
        if isEmpty {
            chatListTableView.isHidden = true
            emptyView.isHidden = false
        } else {
            chatListTableView.isHidden = false
            emptyView.isHidden = true
        }
    }
    
    private func setupUI() {
        view.addSubviews(views: [chatListTableView, emptyView])
        chatListTableView.snp.makeConstraints { make in
            make.top.bottom.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(18)
        }
        emptyView.snp.makeConstraints { make in
            make.center.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
