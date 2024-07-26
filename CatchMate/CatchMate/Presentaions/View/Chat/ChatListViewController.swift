//
//  ChatListViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 6/14/24.
//

import UIKit
import RxSwift
import SnapKit

final class ChatListViewController: BaseViewController {
    private let chatListTableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupUI()
        setupTableView()
        setupEditTableView()
        setupNavigationBar()
    }
    
    private func setupView() {
        view.backgroundColor = .cmBackgroundColor
    }
    
    private func setupNavigationBar() {
        let editButton = UIBarButtonItem(image: UIImage(systemName: "slider.horizontal.3"), style: .plain, target: self, action: #selector(clickEditButton))
        navigationItem.rightBarButtonItem = editButton
        setupLeftTitle("채팅목록")
    }
    
    private func setupTableView() {
        chatListTableView.delegate = self
        chatListTableView.dataSource = self
        chatListTableView.register(ChatListTableViewCell.self, forCellReuseIdentifier: "ChatListTableViewCell")
        chatListTableView.tableHeaderView = UIView()
        chatListTableView.rowHeight = UITableView.automaticDimension
        chatListTableView.backgroundColor = .clear
    }
    
    @objc
    private func clickEditButton(_ sender: UIBarButtonItem) {
        print("편집버튼 클릭")
    }

}
// MARK: - TableView
extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Chat.mockupData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListTableViewCell", for: indexPath) as? ChatListTableViewCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatRoomVC = ChatRoomViewController(chat: Chat.mockupData[indexPath.row])
        navigationController?.pushViewController(chatRoomVC, animated: true)
    }
    
    private func setupEditTableView() {
        chatListTableView.rx.itemDeleted
          .observe(on: MainScheduler.asyncInstance)
          .withUnretained(self)
          .bind { _, indexPath in
              print("remove \(indexPath.row+1) item")
          }
          .disposed(by: self.disposeBag)
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
