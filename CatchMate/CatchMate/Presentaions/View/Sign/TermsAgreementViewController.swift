//
//  TermsAgreementViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 3/3/25.
//

import UIKit
import FlexLayout
import PinLayout
import ReactorKit
import RxSwift
import RxCocoa
import SafariServices

enum AgreementMenu: CaseIterable {
    case terms
    case personalInfo
    case adsPush
    
    var title: String {
        switch self {
        case .terms:
            "[필수] 캐치메이트 이용약관 동의"
        case .personalInfo:
            "[필수] 개인정보 수집 이용 동의"
        case .adsPush:
            "[선택] 광고성 푸시알림 수신 동의"
        }
    }
    
    var isRequired: Bool {
        switch self {
        case .terms:
            return true
        case .personalInfo:
            return true
        case .adsPush:
            return false
        }
    }
    
    var siteURL: String {
        switch self {
        case .personalInfo:
            return "https://catchmate.notion.site/19690504ec15804ba163fcf8fa0ab937?pvs=4"
        case .terms:
            return "https://catchmate.notion.site/19690504ec15803588a7ca69b306bf3e?pvs=4"
        case .adsPush:
            return "https://catchmate.notion.site/1b890504ec15805fa95ef55c252d53e6?pvs=4"
        }
    }
}

final class TermsAgreementViewController: BaseViewController, View {
    var reactor: AgreementReactor
    var signReactor: SignReactor
    private let allAgreeTapGesture = UITapGestureRecognizer()
    let allAgreeTapSubject = PublishSubject<Void>()

    private let menus = AgreementMenu.allCases
    override var useSnapKit: Bool {
        return false
    }
    override var buttonContainerExists: Bool {
        return true
    }
    private let containerView = UIView()
    private let titleLabel1: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = "딱맞는 직관 친구를 구하기 위한"
        label.adjustsFontSizeToFitWidth = true
        label.applyStyle(textStyle: FontSystem.highlight)
        label.textColor = .cmHeadLineTextColor
        return label
    }()
    private let titleLabel2: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = "동의가 필요해요"
        label.adjustsFontSizeToFitWidth = true
        label.applyStyle(textStyle: FontSystem.highlight)
        label.textColor = .cmHeadLineTextColor
        return label
    }()
    private let requiredMark: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "requiredMark")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let allAgreeView = UIView()
    private let allAgreeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "circle_default")?.withTintColor(.grayScale300, renderingMode: .alwaysOriginal), for: .normal)
        return button
    }()
    private let allAgreeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = "필수 항목 모두 체크하기"
        label.adjustsFontSizeToFitWidth = true
        label.applyStyle(textStyle: FontSystem.body01_semiBold)
        label.textColor = .cmHeadLineTextColor
        return label
    }()
    private let sectionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = "캐치메이트 이용약관"
        label.adjustsFontSizeToFitWidth = true
        label.applyStyle(textStyle: FontSystem.body02_semiBold)
        label.textColor = .cmNonImportantTextColor
        return label
    }()
    private let tableView = UITableView()
    private let nextButton = CMDefaultFilledButton(title: "다음")
    
    init(signReactor: SignReactor) {
        self.reactor = AgreementReactor()
        self.signReactor = signReactor
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableview()
        setupUI()
        setupNavigation()
        setupGesture()
        bind(reactor: reactor)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.pin.all(view.pin.safeArea).marginBottom(BottomMargin.safeArea-view.safeAreaInsets.bottom)
        containerView.flex.layout()
    }
    private func setupGesture() {
        allAgreeLabel.isUserInteractionEnabled = true
        allAgreeLabel.addGestureRecognizer(allAgreeTapGesture)
        
       
        allAgreeTapGesture.rx.event
            .map{ _ in }
            .bind(to: allAgreeTapSubject)
            .disposed(by: disposeBag)
        
        allAgreeButton.rx.tap
            .bind(to: allAgreeTapSubject)
            .disposed(by: disposeBag)
    }
    private func setupTableview() {
        tableView.register(TermsAgreementCell.self, forCellReuseIdentifier: "TermsAgreementCell")
        tableView.tableHeaderView = UIView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
    }
    
    private func setupNavigation() {
        let indicatorImage = UIImage(named: "indicator01")
        let indicatorImageView = UIImageView(image: indicatorImage)
        indicatorImageView.contentMode = .scaleAspectFit
        
        indicatorImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            indicatorImageView.heightAnchor.constraint(equalToConstant: 6),
            indicatorImageView.widthAnchor.constraint(equalToConstant: indicatorImage?.getRatio(height: 6) ?? 30.0)
        ])
        
        customNavigationBar.addRightItems(items: [indicatorImageView])
    }
    private func checkAllAgreement(_ state: Bool) {
        nextButton.isEnabled = state
        if state {
            allAgreeButton.setImage(UIImage(named: "circle_check"), for: .normal)
        } else {
            allAgreeButton.setImage(UIImage(named: "circle_default")?.withTintColor(.grayScale300, renderingMode: .alwaysOriginal), for: .normal)
        }
    }
}

extension TermsAgreementViewController {
    private func updateCellCheckbutton(index: Int, state: Bool) {
        if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? TermsAgreementCell {
            cell.isClicked = state
        }
    }
    func bind(reactor: AgreementReactor) {
        nextButton.rx.tap
            .throttle(.seconds(3), latest: false, scheduler: MainScheduler.instance)
            .withUnretained(self)
            .subscribe {  vc, _ in
                let signUpViewController = SignUpViewController(reactor: vc.signReactor)
                vc.navigationController?.pushViewController(signUpViewController, animated: true)
            }
            .disposed(by: disposeBag)
        reactor.state.map{$0.currentAgreements}
            .withUnretained(self)
            .subscribe { vc, states in
                for i in 0..<states.count {
                    vc.updateCellCheckbutton(index: i, state: states[i])
                }
                vc.signReactor.action.onNext(.updateIsEventAlarm(states[2]))
            }
            .disposed(by: disposeBag)
        reactor.state.map{$0.isNextEnabled}
            .withUnretained(self)
            .subscribe { vc, state in
                vc.checkAllAgreement(state)
            }
            .disposed(by: disposeBag)
        
        allAgreeTapSubject
            .subscribe { _ in
                reactor.action.onNext(.requiredAgreementChecked)
            }
            .disposed(by: disposeBag)

        
        Observable.just(menus)
            .bind(to: tableView.rx.items(cellIdentifier: "TermsAgreementCell", cellType: TermsAgreementCell.self)) { (row, item, cell) in
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
                cell.configData(item)  // menu
                
                
                cell.tapSubject
                    .subscribe(onNext: { [weak reactor] _ in
                        guard let reactor = reactor else { return }
                        let current = reactor.currentState.currentAgreements[row]
                        cell.isClicked = !current
                        reactor.action.onNext(.selectAgreement(row))
                    })
                    .disposed(by: cell.disposeBag)
                
                cell.navgatorSubject
                    .withUnretained(self)
                    .subscribe(onNext: { vc, _ in
                        let urlString = item.siteURL
                        vc.openSafari(urlString)
                    })
                    .disposed(by: cell.disposeBag)
                
            }
            .disposed(by: disposeBag)
    }
}

extension TermsAgreementViewController: SFSafariViewControllerDelegate {
    private func openSafari(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let safariVC = SFSafariViewController(url: url)
        safariVC.delegate = self
        present(safariVC, animated: true)
    }
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        // Safari 뷰가 닫힐 때 호출됨
        dismiss(animated: true)
    }
}

// MARK: - UI
extension TermsAgreementViewController {
    private func setupUI() {
        view.addSubview(containerView)
        
        containerView.flex.direction(.column).marginHorizontal(24)
            .justifyContent(.start).alignItems(.start).define { flex in
                flex.addItem(titleLabel1).marginTop(52)
                flex.addItem(allAgreeView).direction(.row).alignItems(.center).define { flex in
                    flex.addItem(titleLabel2).marginRight(6).shrink(1)
                    flex.addItem(requiredMark).size(6)
                }.marginBottom(40)
                flex.addItem().backgroundColor(.grayScale50).cornerRadius(8).direction(.row).width(100%).justifyContent(.start).alignItems(.center).padding(17, 16).define { flex in
                    flex.addItem(allAgreeButton).marginRight(6).size(20)
                    flex.addItem(allAgreeLabel)
                }.marginBottom(20)
                flex.addItem(sectionLabel).marginBottom(10)
                flex.addItem(tableView)
                flex.addItem().grow(1)
                flex.addItem().width(100%).direction(.column).justifyContent(.end).define { flex in
                    flex.addItem(nextButton).width(100%).height(50)
                }
            }
    }
}

final class TermsAgreementCell: UITableViewCell {
    private let tapGesture = UITapGestureRecognizer()
    private let navgatorTapGesture = UITapGestureRecognizer()
    var disposeBag = DisposeBag()
    let tapSubject = PublishSubject<Void>()
    let navgatorSubject = PublishSubject<Void>()
    var menu: AgreementMenu?
    var isClicked: Bool = false {
        didSet {
            checkMenu()
        }
    }
    private let containerView = UIView()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grayScale700
        return label
    }()
    
    private let checkButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "circle_default")?.withTintColor(.grayScale300, renderingMode: .alwaysOriginal), for: .normal)
        return button
    }()
    
    private let navgatorImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "cm20right")?.withTintColor(.grayScale500, renderingMode: .alwaysOriginal)
        return image
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupTapGesture()
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        disposeBag = DisposeBag()
        menu = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.pin.all()
        containerView.flex.layout(mode: .adjustHeight)
        contentView.frame.size.height = 36
    }
    private func checkMenu() {
        if isClicked {
            checkButton.setImage(UIImage(named: "circle_check"), for: .normal)
        } else {
            checkButton.setImage(UIImage(named: "circle_default")?.withTintColor(.grayScale300, renderingMode: .alwaysOriginal), for: .normal)
        }
    }
    func configData(_ menu: AgreementMenu) {
        self.menu = menu
        titleLabel.text = menu.title
        titleLabel.applyStyle(textStyle: FontSystem.body01_medium)
        titleLabel.flex.markDirty()

        containerView.flex.layout(mode: .adjustHeight)
    }
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.flex.direction(.row).justifyContent(.start)
            .alignItems(.center).paddingVertical(8).width(100%)
            .define { flex in
                flex.addItem(checkButton).size(20).marginRight(6)
                flex.addItem(titleLabel).grow(1)
                flex.addItem(navgatorImage).size(20)
            }
    }
    
    private func setupTapGesture() {
        titleLabel.isUserInteractionEnabled = true
        titleLabel.addGestureRecognizer(tapGesture)
        navgatorImage.isUserInteractionEnabled = true
        navgatorImage.addGestureRecognizer(navgatorTapGesture)
       
        navgatorTapGesture.rx.event
            .map { _ in }
            .bind(to: navgatorSubject)
            .disposed(by: disposeBag)
        
        tapGesture.rx.event
            .map { _ in }
            .bind(to: tapSubject)
            .disposed(by: disposeBag)

        checkButton.rx.tap
            .bind(to: tapSubject)
            .disposed(by: disposeBag)
    }
}
