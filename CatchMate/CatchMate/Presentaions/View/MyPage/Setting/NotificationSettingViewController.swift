//
//  NotificationSettingViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 8/7/24.
//

import UIKit
import SnapKit
import RxSwift
import ReactorKit

final class NotificationSettingViewController: BaseViewController, View {
    override var useSnapKit: Bool {
        return true
    }
    override var buttonContainerExists: Bool {
        return false
    }
    private let tableView = UITableView()
    var reactor: NotificationSettingReactor
    
    init(reactor: NotificationSettingReactor) {
        self.reactor = reactor
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLeftTitle("알림 설정")
        setupTableView()
        setupUI()
        bind(reactor: reactor)
    }
    private func setupTableView() {
        tableView.rowHeight = 53
        tableView.separatorStyle = .none
        tableView.register(NotificationSettingCell.self, forCellReuseIdentifier: "NotificationSettingCell")
    }
    private func setupUI() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.bottom.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview().inset(MainGridSystem.getMargin())
        }
    }
    func bind(reactor: NotificationSettingReactor) {
        tableView.rx.itemSelected
            .map { indexPath in
                return NotificationSettingReactor.Action.toggleSwitch(indexPath)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // 상태 바인딩: 테이블뷰 데이터 소스 설정
        reactor.state.map { $0.settings }
            .bind(to: tableView.rx.items(cellIdentifier: "NotificationSettingCell", cellType: NotificationSettingCell.self)) { _, setting, cell in
                cell.configData(setting: setting)
                cell.switchStateSubject
                    .bind { state in
                        print("\(setting.title) switch state: \(state)")
                    }
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
    }
}


final class NotificationSettingCell: UITableViewCell {
    private let notiTitleLabel: UILabel = {
        let label = UILabel()
        label.applyStyle(textStyle: FontSystem.body01_medium)
        label.textColor = .cmHeadLineTextColor
        return label
    }()
    var disposeBag = DisposeBag() 
    var switchStateSubject = PublishSubject<Bool>()
    private let switchView = CMSwitch()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSwitch()
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    private func setupSwitch() {
        switchView.rx_isOn()
            .bind(to: switchStateSubject)
            .disposed(by: disposeBag)
    }
    
    func configData(setting: NotificationSetting) {
        notiTitleLabel.text = setting.title
        notiTitleLabel.applyStyle(textStyle: FontSystem.body01_medium)
    }
    
    private func setupUI() {
        contentView.addSubviews(views: [notiTitleLabel, switchView])
        notiTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()

        }
        switchView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(58)  // widthAnchor 설정
            make.height.equalTo(34)

        }
        notiTitleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        switchView.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        notiTitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        switchView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
}
