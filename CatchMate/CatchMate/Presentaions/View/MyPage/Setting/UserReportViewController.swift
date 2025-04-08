//
//  UserReportViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 10/2/24.
//

import UIKit
import FlexLayout
import PinLayout
import RxSwift
import ReactorKit

enum ReportType: String, CaseIterable {
    case profanity = "욕설 / 비하발언"
    case defaming = "선수 혹은 특정인 비방"
    case privacyInvasion = "개인 사생활 침해"
    case bumpingPosts = "게시글 도배"
    case promotedPosts = "홍보성 게시글"
    case falsehoods = "허위사실유포"
    case others = "기타"
    
    static let allType = ReportType.allCases
    
    var servserRequest: String {
        switch self {
        case .profanity:
            return "PROFANITY"
        case .defaming:
            return "DEFAMATION"
        case .privacyInvasion:
            return "PRIVACY_INVASION"
        case .bumpingPosts:
            return "SPAM"
        case .promotedPosts:
            return "ADVERTISEMENT"
        case .falsehoods:
            return "FALSE_INFORMATION"
        case .others:
            return "OTHER"
        }
    }
}
final class UserReportViewController: BaseViewController, View {
    override var useSnapKit: Bool {
        return false
    }
    override var buttonContainerExists: Bool {
        return true
    }
    var toastSubject: PublishSubject<Void>?
    private let reactor: ReportReactor
    private let reportType = BehaviorSubject<[ReportType]>(value: ReportType.allType)
    private var selectedReportType: ReportType?
    private let containerView = UIView()
    private let titleNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .cmHeadLineTextColor
        return label
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = "신고 사유를 알려주세요"
        label.adjustsFontSizeToFitWidth = true
        label.applyStyle(textStyle: FontSystem.highlight)
        label.textColor = .cmHeadLineTextColor
        return label
    }()
    private let tableView: UITableView = UITableView()
    private let textView: DefaultsTextView = {
        let textView = DefaultsTextView()
        textView.backgroundColor = .grayScale50
        textView.placeholder = "신고 사유에 대한 설명이 필요한 경우 입력해주세요"
        return textView
    }()
    private let reportButton = CMDefaultFilledButton(title: "신고")
    private let reportUser: SimpleUser
    init(reportUser: SimpleUser) {
        self.reportUser = reportUser
        self.reactor = DIContainerService.shared.makeReportUserReactor(reportUser)
        super.init(nibName: nil, bundle: nil)
        titleNameLabel.text = "\(reportUser.nickName)님의"
        titleNameLabel.applyStyle(textStyle: FontSystem.highlight)
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupUI()
        bind(reactor: reactor)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.pin.all(view.pin.safeArea).marginBottom(BottomMargin.safeArea-view.safeAreaInsets.bottom)
        containerView.flex.layout()
    }
    
    private func setupTableView() {
        tableView.register(ReportTypeTableViewCell.self, forCellReuseIdentifier: "ReportTypeTableViewCell")
        tableView.tableHeaderView = UIView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = 56
        // TextView FooterView로 설정
        let width = tableView.frame.width
        let height: CGFloat = 100
        textView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        tableView.tableFooterView = textView
        tableView.showsVerticalScrollIndicator = false
    }

}

// MARK: - TableView Bind
extension UserReportViewController{
    private func updateSelectedType(_ selectedType: ReportType) {
        selectedReportType = selectedType
        guard let cells = tableView.visibleCells as? [ReportTypeTableViewCell] else { return }
        for cell in cells {
            guard let type = cell.reportType else { return }
            cell.isClicked = (type == selectedType)
        }
    }
    func bind(reactor: ReportReactor) {
        reportType
            .bind(to: tableView.rx.items(cellIdentifier: "ReportTypeTableViewCell", cellType: ReportTypeTableViewCell.self)) { (row, type, cell) in
                cell.selectionStyle = .none
                cell.setupData(type: type)
            }
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(ReportType.self)
            .withUnretained(self)
            .subscribe(onNext: { vc, selectedReportType in
                vc.updateSelectedType(selectedReportType)
                reactor.action.onNext(.selectReportType(selectedReportType))
            })
            .disposed(by: disposeBag)
        textView.rx.text
            .distinctUntilChanged()
            .subscribe { text in
                reactor.action.onNext(.changeContent(text ?? ""))
            }
            .disposed(by: disposeBag)
        reportButton.rx.tap
            .withUnretained(self)
            .subscribe { vc, _ in
                vc.showCMAlert(titleText: "\(vc.reportUser.nickName)님을 신고하시겠습니까?", importantButtonText: "신고하기", commonButtonText: "취소", importantAction:  {
                    reactor.action.onNext(.reportUser)
                })
            }
            .disposed(by: disposeBag)
        reactor.state.map{$0.reportButtonEnable}
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe { vc, state in
                vc.reportButton.isEnabled = state
            }
            .disposed(by: disposeBag)
        reactor.state.map{$0.finishedReport}
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe { vc, state in
                if state {
                    vc.toastSubject?.onNext(())
                    vc.navigationController?.popViewController(animated: true)
                }
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UI
extension UserReportViewController {
    private func setupUI() {
        view.addSubview(containerView)
        containerView.flex.direction(.column).marginHorizontal(18).justifyContent(.start).alignItems(.start).define { flex in
            flex.addItem(titleNameLabel).marginTop(20)
            flex.addItem(titleLabel)
            flex.addItem(tableView).marginTop(48).grow(1).shrink(1)
            flex.addItem(reportButton).marginTop(56).width(100%).height(52)
        }
    }
}

final class ReportTypeTableViewCell: UITableViewCell {
    let disposeBag = DisposeBag()
    var isClicked: Bool = false {
        didSet {
            checkCell()
        }
    }
    var reportType: ReportType?
    
    private let containerView = UIView()
    private let reportTypeLabel: UILabel = {
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
        setupUI()
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
        contentView.frame.size.height = 56
    }
    
    private func checkCell() {
        if isClicked {
            checkButton.setImage(UIImage(named: "circle_check")?.withRenderingMode(.alwaysOriginal), for: .normal)
        } else {
            checkButton.setImage(UIImage(named: "circle_default")?.withTintColor(.grayScale300, renderingMode: .alwaysOriginal), for: .normal)
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        containerView.pin.width(size.width)
        containerView.flex.layout(mode: .adjustHeight)
        return CGSize(width: size.width, height: containerView.frame.height)
    }
    
    func setupData(type: ReportType) {
        self.reportType = type
        self.reportTypeLabel.text = type.rawValue
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        
        containerView.flex.direction(.row).justifyContent(.spaceBetween).alignItems(.center).define { flex in
            flex.addItem(reportTypeLabel).grow(1)
            flex.addItem(checkButton).size(20)
        }
    }
    
    private func bind() {
        checkButton.rx.tap
            .subscribe { [weak self] _ in
                self?.isClicked.toggle()
            }
            .disposed(by: disposeBag)
    }
}
