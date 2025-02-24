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
    var reactor: AlarmSettingReactor
    private var settingValue: Bool = false
    init(reactor: AlarmSettingReactor) {
        self.reactor = reactor
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationService.shared.checkNotificationPermissionStatus { [weak self] isAllowed in
            print(isAllowed ? "✅ 알림이 허용됨" : "❌ 알림이 거부됨")
            self?.settingValue = isAllowed
            if isAllowed {
                self?.reactor.action.onNext(.loadNotificationInfo)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLeftTitle("알림 설정")
        setupTableView()
        setupUI()
        bind(reactor: reactor)
        setupUpdateNotification()
    }
    private func setupUpdateNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateNotificationStatus),
            name: .notificationStatusChanged,
            object: nil
        )
    }
    @objc private func updateNotificationStatus(notification: Notification) {
        if let isAllowed = notification.object as? Bool {
            settingValue = isAllowed
            print(isAllowed ? "✅ 알림이 허용됨" : "❌ 알림이 거부됨")
            if isAllowed {
                reactor.action.onNext(.loadNotificationInfo)
            } else {
                reactor.action.onNext(.rejectAlarm)
            }
        }
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
    private func getToggleState(type: AlarmnType) -> Bool {
        switch type {
        case .all:
            return !reactor.currentState.allAlarm
        case .apply:
            return !reactor.currentState.applyAlarm
        case .chat:
            return !reactor.currentState.chatAlarm
        case .event:
            return !reactor.currentState.eventAlarm
        }
    }

    func bind(reactor: AlarmSettingReactor) {
        // 상태 바인딩: 테이블뷰 데이터 소스 설정
        reactor.state
            .map { state in
            [
                (AlarmnType.all, state.allAlarm),
                (AlarmnType.apply, state.applyAlarm),
                (AlarmnType.chat, state.chatAlarm),
                (AlarmnType.event, state.eventAlarm)
            ]
            }
            .bind(to: tableView.rx.items(cellIdentifier: "NotificationSettingCell", cellType: NotificationSettingCell.self)) { row, item, cell in
                let (type, state) = item
                cell.configData(type: type, state: state)
                cell.switchView.rx.controlEvent(.valueChanged)
                    .subscribe(onNext: { [weak self] in
                        guard let self = self else { return }
                        if !self.settingValue {
                            self.showSettingsAlert()
                        } else {
                            reactor.action.onNext(.toggleSwitch((type: type, state: !state)))
                        }
                    })
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        }
    private func showSettingsAlert() {
        showCMAlert(titleText: "설정에서 알림 권한을 허용해주세요.", importantButtonText: "설정", commonButtonText: "취소", importantAction:  {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        })

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
    let switchView = CMSwitch()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    
    func configData(type: AlarmnType, state: Bool) {
        // 상태가 다를 때만 업데이트
        if switchView.isOn != state {
            switchView.setOn(state, animated: false)
        }
        notiTitleLabel.text = type.settingViewName
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
