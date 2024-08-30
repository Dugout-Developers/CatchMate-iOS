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
    private var selectedTeams: [Team] = []
    private var selectedTeam: Team?
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
        if let homeReactor = reactor {
            for team in homeReactor.currentState.selectedTeams {
                selectedTeams.append(team)
            }
        } else if let addReactor = addReactor {
            if isHomeTeam {
                selectedTeam = addReactor.currentState.homeTeam
            } else {
                selectedTeam = addReactor.currentState.awayTeam
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTableView()
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
    
    private func setupCell() {
        guard let cells = tableView.visibleCells as? [TeamFilterTableViewCell] else { return }
        for cell in cells {
            guard let team = cell.team else { continue }
            cell.isClicked = team == selectedTeam
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
        
        willAppearPublisher
            .observe(on: MainScheduler.asyncInstance)
            .bind(onNext: setupCell)
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
                    .subscribe { vc, _ in
                        vc.selectedTeam = team
                        vc.updateSelectedTeams(team)
                    }
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .withUnretained(self)
            .subscribe { vc, _ in
                if let team = vc.selectedTeam {
                    if vc.isHomeTeam {
                        reactor.action.onNext(.changeHomeTeam(team))
                    } else {
                        reactor.action.onNext(.changeAwayTeam(team))
                    }
                }
                vc.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        reactor.state.map{$0.error}
            .compactMap{$0}
            .withUnretained(self)
            .subscribe { vc, error in
                if let message = error.errorDescription {
                    vc.showToast(message: message, buttonContainerExists: true)
                }
            }
            .disposed(by: disposeBag)
            
    }
    
    func bind(reactor: HomeReactor) {
        tableView.rx.itemSelected
            .withUnretained(self)
            .subscribe { vc, indexPath in
                let team = self.allTeams[indexPath.row]
                if let index = vc.selectedTeams.firstIndex(of: team) {
                    vc.selectedTeams.remove(at: index)
                } else {
                    vc.selectedTeams.append(team)
                }
            }
            .disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        resetButton.rx.tap
            .withUnretained(self)
            .subscribe { vc, _ in
                reactor.action.onNext(.updateTeamFilter([]))
                vc.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .withUnretained(self)
            .subscribe { vc, _ in
                reactor.action.onNext(.updateTeamFilter(vc.selectedTeams))
                vc.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        Observable.just(allTeams)
            .bind(to: tableView.rx.items(cellIdentifier: "TeamFilterTableViewCell", cellType: TeamFilterTableViewCell.self)) { row, team, cell in
                let isSelected = reactor.currentState.selectedTeams.contains(team)
                cell.configure(with: team, isClicked: isSelected)
                cell.selectionStyle = .none
                cell.checkButton.rx.tap
                    .subscribe(onNext: { [weak self] _ in
                        guard let self = self else { return }
                        if let index = selectedTeams.firstIndex(of: team) {
                            selectedTeams.remove(at: index)
                            cell.isClicked = false
                        } else {
                            selectedTeams.append(team)
                            cell.isClicked = true
                        }
                    })
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
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

