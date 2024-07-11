//
//  TeamFilterViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 6/16/24.
//

import UIKit
import RxSwift
import ReactorKit
import SnapKit

final class TeamFilterViewController: BasePickerViewController, View, UIScrollViewDelegate {
    private let allTeams: [Team] = Team.allTeam
    private let tableView: UITableView = UITableView()
    private let saveButton = CMDefaultFilledButton(title: "저장")
    
    var reactor: HomeReactor
    var disposeBag = DisposeBag()
    
    init(reactor: HomeReactor) {
        self.reactor = reactor
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        bind(reactor: reactor)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupTableView()
        settupButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disable()
    }
    
    private func settupButton() {
        saveButton.addTarget(self, action: #selector(clickedSaveButton), for: .touchUpInside)
    }
    @objc private func clickedSaveButton(_ sender: UIButton) {
        dismiss(animated: true)
    }
    private func setupTableView() {
        tableView.register(TeamFilterTableViewCell.self, forCellReuseIdentifier: "TeamFilterTableViewCell")
        tableView.tableHeaderView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 65
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
    }
    
    func bind(reactor: HomeReactor) {
        reactor.state.map { $0.selectedTeams }
            .bind(onNext: updateSelectedTeams)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .map { indexPath in
                let team = self.allTeams[indexPath.row]
                return Reactor.Action.toggleTeamSelection(team)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        Observable.just(allTeams)
            .bind(to: tableView.rx.items(cellIdentifier: "TeamFilterTableViewCell", cellType: TeamFilterTableViewCell.self)) { row, team, cell in
                let isSelected = reactor.currentState.selectedTeams.contains(team)
                cell.configure(with: team, isClicked: isSelected)
                cell.selectionStyle = .none
                cell.checkButton.rx.tap
                    .map { Reactor.Action.toggleTeamSelection(team) }
                    .bind(to: reactor.action)
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
    }
    
    private func updateSelectedTeams(_ selectedTeams: [Team]) {
        guard let cells = tableView.visibleCells as? [TeamFilterTableViewCell] else { return }
        for cell in cells {
            guard let team = cell.team else { continue }
            cell.isClicked = selectedTeams.contains(team)
        }
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

