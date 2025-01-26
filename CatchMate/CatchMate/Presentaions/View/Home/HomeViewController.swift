//
//  ViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 6/11/24.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit

enum Filter {
    case date
    case team
    case number
    case none
}

final class HomeViewController: BaseViewController, View {
    private let reactor: HomeReactor
    override var useSnapKit: Bool {
        return false
    }
    override var buttonContainerExists: Bool {
        return false
    }
    private let emptyView = EmptyView(type: .home)
    private let filterScrollView = UIScrollView()
    private let filterContainerView = UIView()
    private let dateFilterButton = OptionButtonView(title: "경기 날짜", filter: .date)
    private let teamFilterButton = OptionButtonView(title: "응원 구단", filter: .team)
    private let numberFilterButton = OptionButtonView(title: "모집 인원", filter: .number)
    
    private let tableView = UITableView()
    private let footerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.tintColor = .cmPrimaryColor
        return control
    }()
    
    init(reactor: HomeReactor) {
        self.reactor = reactor
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tabBarController?.tabBar.isHidden = false
        reactor.action.onNext(.selectPost(nil))
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .grayScale50
        setupTableView()
        setupUI()
        setupNavigation()
        setupButton()
        setupLogo()
        bind(reactor: self.reactor)
        reactor.action.onNext(.viewDidLoad)
        filterScrollView.showsHorizontalScrollIndicator = false
    }
    private func setupNavigation() {
        let notiButton = UIButton()
        notiButton.setImage(UIImage(named: "notification")?.withTintColor(.cmHeadLineTextColor, renderingMode: .alwaysOriginal), for: .normal)
        notiButton.addTarget(self, action: #selector(clickNotiButton), for: .touchUpInside)
        customNavigationBar.addRightItems(items: [notiButton])
    }
    private func setupTableView() {
        tableView.register(ListCardViewTableViewCell.self, forCellReuseIdentifier: "ListCardViewTableViewCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 178
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        
        // 푸터에 로딩 인디케이터 추가
        footerView.addSubview(activityIndicator)
        activityIndicator.center = footerView.center
        footerView.isHidden = true
        tableView.tableFooterView = footerView
        
        
        // 새로고침 컨트롤 추가
        tableView.refreshControl = refreshControl
    }
}


// MARK: - Bind
extension HomeViewController {
    func bind(reactor: HomeReactor) {
        tableView.rx.itemSelected
            .map { indexPath in
                let post = reactor.currentState.posts[indexPath.row]
                return HomeReactor.Action.selectPost(post.id)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // MARK: - Pagenation
        tableView.rx.contentOffset
            .map { [weak self] _ in
                guard let self = self else { return false }
                let offsetY = self.tableView.contentOffset.y
                let contentHeight = self.tableView.contentSize.height
                let threshold = contentHeight - self.tableView.frame.size.height - (self.tableView.rowHeight * 4)
                return offsetY > threshold
            }
            .distinctUntilChanged()
            .filter { $0 }
            .map { _ in HomeReactor.Action.loadNextPage }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 로딩 상태에 따른 푸터 인디케이터 표시/숨김 제어
        reactor.state.map { $0.isLoadingNextPage }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isLoading in
                self?.footerView.isHidden = !isLoading
                if isLoading {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
            })
            .disposed(by: disposeBag)
        // MARK: - 새로고침
        // 새로고침 컨트롤 액션 바인딩
        refreshControl.rx.controlEvent(.valueChanged)
            .map { HomeReactor.Action.refreshPage }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // 새로고침 완료 시 인디케이터 숨김 처리
        reactor.state.map { $0.isRefreshing }
            .distinctUntilChanged()
            .filter { !$0 }
            .subscribe(onNext: { [weak self] _ in
                self?.refreshControl.endRefreshing()
            })
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.selectedPost}
            .distinctUntilChanged()
            .compactMap{$0}
            .withUnretained(self)
            .subscribe { vc, postId in
                let postDetailVC = PostDetailViewController(postID: postId)
                postDetailVC.hidesBottomBarWhenPushed = true
                vc.navigationController?.pushViewController(postDetailVC, animated: true)
            }
            .disposed(by: disposeBag)
        reactor.state.map{$0.dateFilterValue}
            .withUnretained(self)
            .bind { vc, date in
                vc.dateFilterButton.filterValue = date?.toString(format: "MM.dd")
                vc.updateFilterContainerLayout()
            }
            .disposed(by: disposeBag)
        
        reactor.state.map{ $0.posts }
            .bind(to: tableView.rx.items(cellIdentifier: "ListCardViewTableViewCell", cellType: ListCardViewTableViewCell.self)) {  (row, item, cell) in
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
                cell.setupData(item)
                cell.updateConstraints()
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.selectedTeams }
            .withUnretained(self)
            .bind { vc, teams in
                let teamNames = teams.map { $0.rawValue }.joined(separator: ", ")
                vc.teamFilterButton.filterValue = teamNames.isEmpty ? nil : teamNames
                vc.updateFilterContainerLayout()
            }
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.seletedNumberFilter}
            .withUnretained(self)
            .bind { vc, number in
                if let number = number {
                    vc.numberFilterButton.filterValue = "\(number)명"
                } else {
                    vc.numberFilterButton.filterValue = nil
                }
                vc.updateFilterContainerLayout()
            }
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.error}
            .compactMap{$0}
            .withUnretained(self)
            .subscribe { vc, error in
                vc.handleError(error)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.posts.isEmpty}
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe { vc, isEmpty in
                vc.changeView(isEmpty)
            }
            .disposed(by: disposeBag)
    
    }
    private func updateFilterContainerLayout() {
        filterContainerView.flex.layout(mode: .adjustWidth)
        filterScrollView.contentSize = filterContainerView.frame.size
    }
}
// MARK: - Button Event
extension HomeViewController {
    private func setupButton() {
        dateFilterButton.addTarget(self, action: #selector(clickFilterButton(_:)), for: .touchUpInside)
        teamFilterButton.addTarget(self, action: #selector(clickFilterButton(_:)), for: .touchUpInside)
        numberFilterButton.addTarget(self, action: #selector(clickFilterButton(_:)), for: .touchUpInside)

    }
    
    @objc private func clickNotiButton(_ sender: UIButton) {
        let notiViewController = NotiViewController(reactor: DIContainerService.shared.makeNotiListReactor())
        notiViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(notiViewController, animated: true)
    }
    
    @objc private func clickFilterButton(_ sender: OptionButtonView) {
        switch sender.filterType {
        case .date:
            let customDetent = returnCustomDetent(height: SheetHeight.dateFilter, identifier: "DateFilter")
            let dateFilterVC = DateFilterViewController(reactor: reactor, disposeBag: disposeBag)
            if let sheet = dateFilterVC.sheetPresentationController {
                sheet.detents = [customDetent]
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            }
            present(dateFilterVC, animated: true)
        case .team:
            let teamFilterVC = TeamFilterViewController(reactor: reactor)
            let customDetent = returnCustomDetent(height: Screen.height * 3/4, identifier: "TeamFilter")
            if let sheet = teamFilterVC.sheetPresentationController {
                sheet.detents = [customDetent]
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            }
            present(teamFilterVC, animated: true)
        case .number:
            let numberFilterVC = NumberPickerViewController(reactor: reactor)
            let customDetent = returnCustomDetent(height: SheetHeight.numberFilter, identifier: "NumberFilter")
            if let sheet = numberFilterVC.sheetPresentationController {
                sheet.detents = [customDetent]
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            }
            present(numberFilterVC, animated: true)
        case .none:
            // 잘못된 필터 값
            break
        }
    }
    
    private func returnCustomDetent(height: CGFloat, identifier: String) -> UISheetPresentationController.Detent {
        let detentIdentifier = UISheetPresentationController.Detent.Identifier(identifier)
        let customDetent = UISheetPresentationController.Detent.custom(identifier: detentIdentifier) { _ in
            return height
        }
        return customDetent
    }
}

// MARK: - UI
extension HomeViewController {
    func setupUI() {
        // 필터 컨테이너 뷰 추가
        view.addSubview(filterScrollView)
        view.addSubview(tableView)
        view.addSubview(emptyView)
        emptyView.isHidden = true
        filterScrollView.addSubview(filterContainerView)
        filterContainerView.flex.direction(.row).paddingHorizontal(18).paddingVertical(11).justifyContent(.start).alignItems(.center).define { flex in
            flex.addItem(dateFilterButton).marginRight(8)
            flex.addItem(teamFilterButton).marginRight(8)
            flex.addItem(numberFilterButton)
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        filterScrollView.pin.top(view.pin.safeArea.top).left(view.pin.safeArea.left).right(view.pin.safeArea.right).height(50)
        filterContainerView.pin.all()
        
        filterContainerView.flex.layout(mode: .adjustWidth)
        filterScrollView.contentSize = filterContainerView.frame.size
        tableView.pin.below(of: filterContainerView).marginTop(12).bottom(view.pin.safeArea.bottom).left().right()
        // SnapKit 기반 EmptyView를 FlexLayout에 맞게 크기 계산
        emptyView.layoutIfNeeded() // SnapKit 제약 조건에 따라 레이아웃 적용
        let emptyViewSize = emptyView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize) // 콘텐츠 크기 계산
        emptyView.pin.size(emptyViewSize).center()
        emptyView.flex.layout()
        filterContainerView.flex.layout()
    }
    
    private func changeView(_ isEmpty: Bool) {
        if isEmpty {
            tableView.isHidden = true
            emptyView.isHidden = false
        } else {
            tableView.isHidden = false
            emptyView.isHidden = true
        }
    }
}

