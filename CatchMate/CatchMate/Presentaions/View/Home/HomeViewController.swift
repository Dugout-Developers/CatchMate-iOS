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
    case all
    case date
    case team
    case none
}

final class HomeViewController: BaseViewController, View {
    
    private let reactor: HomeReactor
    private let viewWillAppearPublisher = PublishSubject<Void>().asObserver()
    private let filterScrollView = UIScrollView()
    private let filterContainerView = UIView()
    private let allFilterButton = HomeFilterButton(icon: UIImage(named: "cm20hamburger")?.withTintColor(.grayScale700, renderingMode: .alwaysOriginal), title: "전체", filter: .all)
    private let dateFilterButton = HomeFilterButton(title: "경기 날짜", filter: .date)
    private let teamFilterButton = HomeFilterButton(title: "응원 구단", filter: .team)
    
    private let tableView = UITableView()
    
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
        viewWillAppearPublisher.onNext(())
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
    }
}


// MARK: - Bind
extension HomeViewController {
    func bind(reactor: HomeReactor) {
        
        viewWillAppearPublisher
            .map { Reactor.Action.willAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .map { indexPath in
                let post = reactor.currentState.posts[indexPath.row]
                return HomeReactor.Action.selectPost(post)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.selectedPost}
            .distinctUntilChanged()
            .compactMap{$0}
            .withUnretained(self)
            .subscribe { vc, post in
                let postDetailVC = PostDetailViewController(postID: post.id)
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
    
    }
    private func updateFilterContainerLayout() {
        filterContainerView.flex.layout(mode: .adjustWidth)
        filterScrollView.contentSize = filterContainerView.frame.size
    }
}
// MARK: - Button Event
extension HomeViewController {
    private func setupButton() {
        allFilterButton.addTarget(self, action: #selector(clickFilterButton(_:)), for: .touchUpInside)
        dateFilterButton.addTarget(self, action: #selector(clickFilterButton(_:)), for: .touchUpInside)
        teamFilterButton.addTarget(self, action: #selector(clickFilterButton(_:)), for: .touchUpInside)
    }
    
    @objc private func clickNotiButton(_ sender: UIButton) {
        let notiViewController = NotiViewController()
        navigationController?.pushViewController(notiViewController, animated: true)
    }
    
    @objc private func clickFilterButton(_ sender: HomeFilterButton) {
        switch sender.filterType {
        case .all:
            print("전체 필터 선택")
            let allFilterVC = AllFilterViewController(reactor: reactor)
            navigationController?.pushViewController(allFilterVC, animated: true)
        case .date:
            let customDetent = returnCustomDetent(height: Screen.height / 2.0 + 50.0, identifier: "DateFilter")
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
        filterScrollView.addSubview(filterContainerView)
        filterContainerView.flex.direction(.row).paddingHorizontal(18).paddingVertical(11).justifyContent(.start).alignItems(.center).define { flex in
            flex.addItem(allFilterButton).marginRight(8)
            flex.addItem(dateFilterButton).marginRight(8)
            flex.addItem(teamFilterButton)
        }
    }
    

override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        filterScrollView.pin.top(view.pin.safeArea.top).left(view.pin.safeArea.left).right(view.pin.safeArea.right).height(50)
        filterContainerView.pin.all()
        
        filterContainerView.flex.layout(mode: .adjustWidth)
        filterScrollView.contentSize = filterContainerView.frame.size
        tableView.pin.below(of: filterContainerView).marginTop(12).bottom(view.pin.safeArea.bottom).left().right()
        filterContainerView.flex.layout()
    }
}

