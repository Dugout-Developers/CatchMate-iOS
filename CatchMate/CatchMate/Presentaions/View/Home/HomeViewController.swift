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
    var disposeBag: DisposeBag = DisposeBag()
    private let reactor: HomeReactor
    private let viewWillAppearPublisher = PublishSubject<Void>().asObserver()
    
    private let filterContainerView = UIView()
    private let allFilterButton = HomeFilterButton(icon: UIImage(systemName: "list.bullet"), title: "전체", filter: .all)
    private let dateFilterButton = HomeFilterButton(icon: UIImage(systemName: "calendar"), title: "경기 날짜", filter: .date)
    private let teamFilterButton = HomeFilterButton(icon: UIImage(systemName: "person.3.fill"), title: "응원 구단", filter: .team)
    
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
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .cmBackgroundColor
        setupUI()
        setupButton()
        bind(reactor: self.reactor)
        setupTableView()
    }
    private func setupTableView() {
        // MARK: - 임시 (바인드 시 지우기)
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(ListCardViewTableViewCell.self, forCellReuseIdentifier: "ListCardViewTableViewCell")
        tableView.tableHeaderView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 178
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
    }
}
// MARK: - 임시: 와이어프레임 확인용 테이블 뷰 데이터소스 및 델리게이트
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListCardViewTableViewCell", for: indexPath) as? ListCardViewTableViewCell else { return UITableViewCell() }
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        return cell
    }
    
    
}

// MARK: - Bind
extension HomeViewController {
    func bind(reactor: HomeReactor) {
        
    }
}
// MARK: - Button Event
extension HomeViewController {
    private func setupButton() {
        allFilterButton.addTarget(self, action: #selector(clickFilterButton(_:)), for: .touchUpInside)
        dateFilterButton.addTarget(self, action: #selector(clickFilterButton(_:)), for: .touchUpInside)
        teamFilterButton.addTarget(self, action: #selector(clickFilterButton(_:)), for: .touchUpInside)
    }
    
    @objc
    private func clickFilterButton(_ sender: HomeFilterButton) {
        switch sender.filterType {
        case .all:
            print("전체 필터 선택")
        case .date:
            print("날짜 필터 선택")
            let detentIdentifier = UISheetPresentationController.Detent.Identifier("customDetent")
            let customDetent = UISheetPresentationController.Detent.custom(identifier: detentIdentifier) { _ in
                return Screen.height / 2.0 + 50.0
            }
            let dateFilterVC = DateFilterViewController()
            if let sheet = dateFilterVC.sheetPresentationController {
                sheet.detents = [customDetent]
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            }
            present(dateFilterVC, animated: true)
        case .team:
            print("팀 필터 선택")
        case .none:
            // 잘못된 필터 값
            break
        }
    }
}

// MARK: - UI
extension HomeViewController {
    func setupUI() {
        // 필터 컨테이너 뷰 추가
        view.addSubview(filterContainerView)
        view.addSubview(tableView)
        
        filterContainerView.flex.direction(.row).justifyContent(.start).alignItems(.center).paddingHorizontal(18).paddingVertical(11).define { flex in
            flex.addItem(allFilterButton).marginRight(8)
            flex.addItem(dateFilterButton).marginRight(8)
            flex.addItem(teamFilterButton)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        filterContainerView.pin.top(view.pin.safeArea.top).left(view.pin.safeArea.left).right(view.pin.safeArea.right).height(50)
        tableView.pin.below(of: filterContainerView).marginTop(12).bottom(view.pin.safeArea.bottom).left().right()
        filterContainerView.flex.layout()
    }
}



