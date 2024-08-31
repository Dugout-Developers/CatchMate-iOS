//
//  CheerTeamPickerViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 8/30/24.
//

import UIKit
import ReactorKit
import RxSwift
import SnapKit
import FlexLayout
import PinLayout

final class CheerTeamPickerViewController: BasePickerViewController, View {
    var reactor: AddReactor
    var disposeBag: DisposeBag = DisposeBag()
    private var teams = PublishSubject<[Team]>()
    private var home: Team
    private var away: Team
    private var selectedTeam: Team?
    
    private let tableView = UITableView()
    private let saveButton = CMDefaultFilledButton(title: "저장")
    
    init(reactor: AddReactor, home: Team, away: Team) {
        self.reactor = reactor
        self.home = home
        self.away = away
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("\(home), \(away)")
        print("\(reactor.currentState.cheerTeam)")
        updateSelectedTeam(reactor.currentState.cheerTeam)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTableView()
        bind(reactor: reactor)
        teams.onNext([home, away])
        setupUI()
    }

    private func setupTableView() {
        tableView.register(CheerTeamTableViewCell.self, forCellReuseIdentifier: "CheerTeamTableViewCell")
        tableView.tableHeaderView = UIView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
    }
    
    private func updateSelectedTeam(_ selectedTeam: Team?) {
        self.selectedTeam = selectedTeam
        guard let cells = tableView.visibleCells as? [CheerTeamTableViewCell] else { return }
        for cell in cells {
            guard let team = cell.team else { continue }
            cell.isClicked = (team == selectedTeam)
        }
    }
    
    func bind(reactor: AddReactor) {
        reactor.state.map{$0.cheerTeam}
            .distinctUntilChanged()
            .bind(onNext: updateSelectedTeam)
            .disposed(by: disposeBag)
        
        teams.bind(to: tableView.rx.items(cellIdentifier: "CheerTeamTableViewCell", cellType: CheerTeamTableViewCell.self)) { [weak self] row, team, cell in
            guard let self = self else {return}
            if let myTeamStr = SetupInfoService.shared.getUserInfo(type: .team), let myTeam = Team(rawValue: myTeamStr)  {
                cell.setupData(team: team, isClicked: selectedTeam == team)
            }
            cell.selectionStyle = .none
            cell.checkButton.rx.tap
                .withUnretained(self)
                .subscribe(onNext: { vc, _ in
                    vc.updateSelectedTeam(team)
                })
                .disposed(by: cell.disposeBag)
        }
        .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .withUnretained(self)
            .subscribe { vc, _ in
                if let team = vc.selectedTeam {
                    reactor.action.onNext(.changeCheerTeam(team))
                }
                vc.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func setupUI() {
        view.addSubviews(views: [tableView, saveButton])

        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview().inset(MainGridSystem.getMargin())
            make.bottom.equalTo(saveButton.snp.top).offset(-30)
        }

        saveButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(ButtonGridSystem.getMargin())
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-34)
            make.height.equalTo(52).priority(.required)
        }
    }
}

final class CheerTeamTableViewCell: UITableViewCell {
    var disposeBag = DisposeBag()
    var isClicked: Bool = false {
        didSet {
            checkTeam()
        }
    }
    var team: Team?
    private let containerView = UIView()
    private let teamImageView = TeamImageView()
    
    private let teamLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmHeadLineTextColor
        return label
    }()
    
    let checkButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "circle_default")?.withTintColor(.grayScale300, renderingMode: .alwaysOriginal), for: .normal)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
        bind()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.pin.all()
        containerView.flex.layout()
        contentView.frame.size.height = 50
    }
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        containerView.pin.width(size.width)
        containerView.flex.layout(mode: .adjustHeight)
        return CGSize(width: size.width, height: containerView.frame.height)
    }
    
    private func checkTeam() {
        if isClicked {
            if let team = team {
                teamImageView.changeBackGroundColor(team.getTeamColor)
            }
            checkButton.setImage(UIImage(named: "circle_check")?.withRenderingMode(.alwaysOriginal), for: .normal)
        } else {
            teamImageView.changeBackGroundColor(.grayScale50)
            checkButton.setImage(UIImage(named: "circle_default")?.withTintColor(.grayScale300, renderingMode: .alwaysOriginal), for: .normal)
        }
    }
    
    func setupData(team: Team, isClicked: Bool) {
        self.team = team
        self.teamImageView.setupTeam(team: team, isMyTeam: true)
        self.teamLabel.text = team.rawValue
        self.teamLabel.applyStyle(textStyle: FontSystem.bodyTitle)
        self.isClicked = isClicked
        
        self.teamImageView.flex.markDirty()
        self.teamLabel.flex.markDirty()
        containerView.flex.layout(mode: .adjustHeight)
    }

    private func bind() {
        checkButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.isClicked.toggle()
            })
            .disposed(by: disposeBag)
    }
    
    private func setUI() {
        contentView.addSubview(containerView)
        
        containerView.flex.direction(.row).justifyContent(.start).alignContent(.center).paddingVertical(20).define { flex in
            flex.addItem(teamImageView).size(50)
            flex.addItem(teamLabel).marginHorizontal(12).grow(1)
            flex.addItem(checkButton).size(20)
        }
    }
}
