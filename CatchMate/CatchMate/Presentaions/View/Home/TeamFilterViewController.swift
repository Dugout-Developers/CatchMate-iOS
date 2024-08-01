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
    var isHomeTeam: Bool = false
    private let allTeams: [Team] = Team.allTeam
    private let tableView: UITableView = UITableView()
    private let saveButton = CMDefaultFilledButton(title: "저장")
    private let resetButton: UIButton = {
        let button = UIButton()
        button.setTitle("초기화", for: .normal)
        button.applyStyle(textStyle: FontSystem.body02_semiBold)
        button.setTitleColor(.cmNonImportantTextColor, for: .normal)
        button.backgroundColor = .grayScale50
        button.clipsToBounds = true
        button.layer.cornerRadius = 8
        return button
    }()
    private let willAppearPublisher = PublishSubject<Void>()
    
    var reactor: HomeReactor?
    var addReactor: AddReactor?
    var disposeBag = DisposeBag()
    
    init(reactor: any Reactor) {
        super.init(nibName: nil, bundle: nil)
        
        if let homeReactor = reactor as? HomeReactor {
            self.reactor = homeReactor
        } else if let addReactor = reactor as? AddReactor {
            self.addReactor = addReactor
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        willAppearPublisher.onNext(())
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTableView()
        settupButton()
        if let homeReactor = reactor {
            bind(reactor: homeReactor)
            setupUI(isHome: true)
        } else if let addReactor = addReactor {
            bind(reactor: addReactor)
            setupUI()
        }
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
}

// MARK: - Bind

extension TeamFilterViewController {
    private func updateSelectedTeams(_ selectedTeam: Team?) {
        guard let cells = tableView.visibleCells as? [TeamFilterTableViewCell] else { return }
        for cell in cells {
            guard let team = cell.team else { continue }
            cell.isClicked = (team == selectedTeam)
        }
    }
    
    private func updateUnableTeam(_ selectedTeam: Team?) {
        guard let cells = tableView.visibleCells as? [TeamFilterTableViewCell] else { return }
        for cell in cells {
            guard let team = cell.team else { continue }
            cell.isUnable = (team == selectedTeam)
        }
    }
    func bind(reactor: AddReactor) {
        willAppearPublisher
            .withUnretained(self)
            .map { vc, _ -> Team? in
                vc.isHomeTeam ? reactor.currentState.awayTeam : reactor.currentState.homeTeam
            }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .bind(onNext: updateUnableTeam)
            .disposed(by: disposeBag)
        
        reactor.state
            .withUnretained(self)
            .map { vc, state in
                if vc.isHomeTeam {
                    state.homeTeam
                } else {
                    state.awayTeam
                }
            }
            .bind(onNext: updateSelectedTeams)
            .disposed(by: disposeBag)
        
        
        Observable.just(allTeams)
            .bind(to: tableView.rx.items(cellIdentifier: "TeamFilterTableViewCell", cellType: TeamFilterTableViewCell.self)) {[weak self] row, team, cell in
                guard let self = self else { return }
                if isHomeTeam {
                    cell.configure(with: team, isClicked: false, isUnable: reactor.currentState.awayTeam==team)
                } else {
                    cell.configure(with: team, isClicked: false, isUnable: reactor.currentState.homeTeam==team)
                }
                cell.selectionStyle = .none
                cell.checkButton.rx.tap
                    .withUnretained(self)
                    .map{ vc, _ in
                        if vc.isHomeTeam {
                            return AddReactor.Action.changeHomeTeam(team)
                        } else {
                            return AddReactor.Action.changeAwayTeam(team)
                        }
                    }
                    .bind(to: reactor.action)
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
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
    private func setupUI(isHome: Bool = false) {
        view.addSubviews(views: [tableView, saveButton])
        
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.leading.trailing.equalToSuperview().inset(12)
        }

        if isHome {
            view.addSubview(resetButton)
            resetButton.snp.makeConstraints { make in
                make.top.equalTo(tableView.snp.bottom).offset(30)
                make.leading.equalToSuperview().inset(ButtonGridSystem.getMargin())
                make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-30)
                make.width.equalTo(ButtonGridSystem.getColumnWidth(totalWidht: Screen.width))
                make.height.equalTo(52)
            }
            saveButton.snp.makeConstraints { make in
                make.top.bottom.height.equalTo(resetButton)
                make.leading.equalTo(resetButton.snp.trailing).offset(ButtonGridSystem.getGutter())
                make.trailing.equalToSuperview().inset(ButtonGridSystem.getMargin())
            }
        } else {
            saveButton.snp.makeConstraints { make in
                make.top.equalTo(tableView.snp.bottom).offset(30)
                make.leading.trailing.equalTo(tableView)
                make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-30)
                make.height.equalTo(50)
            }
        }
    }
}

