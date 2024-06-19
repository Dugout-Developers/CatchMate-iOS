//
//  NotiViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 6/14/24.
//

import UIKit
import RxSwift

final class NotiViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .cmBackgroundColor
        configNavigationLeftTitle("알림")
        setupUI()
        setupTableView()
        setupEditTableView()
    }
    
}

// MARK: - TableView 임시: 와이어프레임 확인용 테이블 뷰 데이터소스 및 델리게이트 -> Rx 적용 후 수정 필수
extension NotiViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NotiViewTableViewCell", for: indexPath) as? NotiViewTableViewCell else { return UITableViewCell() }
        return cell
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NotiViewTableViewCell.self, forCellReuseIdentifier: "NotiViewTableViewCell")
        tableView.tableHeaderView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .clear
    }
    
    private func setupEditTableView() {
        tableView.rx.itemDeleted
          .observe(on: MainScheduler.asyncInstance)
          .withUnretained(self)
          .bind { _, indexPath in
              print("remove \(indexPath.row+1) item")
          }
          .disposed(by: self.disposeBag)
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
