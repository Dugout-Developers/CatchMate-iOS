//
//  TeamFilterViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 6/16/24.
//

import UIKit
import SnapKit

final class TeamFilterViewController: UIViewController {
    private let allTeams: [Team] = Team.allCases
    private let tableView: UITableView = UITableView()
    private let saveButton: UIButton = {
        let button = UIButton(configuration: .plain())
        button.layer.cornerRadius = 4
        button.backgroundColor = .cmPrimaryColor
        button.setTitleColor(.white, for: .normal)
        button.setTitle("저장", for: .normal)
        button.tintColor = .clear
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupTableView()
    }
    
    private func setupTableView() {
        // MARK: - 임시 (바인드 시 지우기)
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(TeamFilterTableViewCell.self, forCellReuseIdentifier: "TeamFilterTableViewCell")
        tableView.tableHeaderView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 65
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
    }
}

// MARK: - 임시: 와이어프레임 확인용 테이블 뷰 데이터소스 및 델리게이트
extension TeamFilterViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTeams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TeamFilterTableViewCell", for: indexPath) as? TeamFilterTableViewCell else { return UITableViewCell() }
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.setupData(team: allTeams[indexPath.row])
        return cell
    }
    
    
}

// MARK: - UI
extension TeamFilterViewController {
    private func setupUI() {
        view.addSubviews(views: [tableView, saveButton])
        
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.leading.trailing.equalToSuperview().inset(12)
        }

        saveButton.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom).offset(30)
            make.leading.trailing.equalTo(tableView)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-30)
            make.height.equalTo(50)
        }
    }
}

