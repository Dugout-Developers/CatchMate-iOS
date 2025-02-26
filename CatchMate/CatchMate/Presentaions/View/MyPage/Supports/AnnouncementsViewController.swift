//
//  AnnouncementsViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 8/8/24.
//

import UIKit
import RxSwift
import ReactorKit
import SnapKit
final class AnnouncementsViewController: BaseViewController, View {
    override var useSnapKit: Bool {
        return true
    }
    override var buttonContainerExists: Bool {
        return false
    }
    
    var reactor: AnnouncementsReactor
    private let tableView = UITableView()
    
    init(reactor: AnnouncementsReactor) {
        self.reactor = reactor
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reactor.action.onNext(.selectAnnouncement(nil))
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLeftTitle("공지사항")
        setupUI()
        setupTableView()
        bind(reactor: reactor)
        reactor.action.onNext(.loadAnnouncements)
    }
    
    private func setupTableView() {
        tableView.register(AnnouncementsListCell.self, forCellReuseIdentifier: "AnnouncementsListCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
    }
    private func setupUI() {
        view.backgroundColor = .grayScale50
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.bottom.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview().inset(MainGridSystem.getMargin())
        }
    }
}

extension AnnouncementsViewController {
    func bind(reactor: AnnouncementsReactor) {
        reactor.state.map{$0.announcements}
            .bind(to: tableView.rx.items(cellIdentifier: "AnnouncementsListCell", cellType: AnnouncementsListCell.self)) {  (row, item, cell) in
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
                cell.configData(announcement: item)
                cell.updateConstraints()
            }
            .disposed(by: disposeBag)
        tableView.rx.contentOffset
            .skip(1)
            .distinctUntilChanged()
            .withUnretained(self)
            .map { vc, offset in
                let offsetY = offset.y
                let contentHeight = vc.tableView.contentSize.height
                let threshold = contentHeight - vc.tableView.frame.size.height - (vc.tableView.rowHeight * 4)
                return (vc, offsetY, threshold)
            }
            .filter { vc, offsetY, threshold in
                offsetY > threshold &&
                !reactor.currentState.isLoading &&
                !reactor.currentState.isLast
            }
            .subscribe(onNext: { vc, _, _ in
                reactor.action.onNext(.loadNextPage)
            })
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.error}
            .compactMap{$0}
            .withUnretained(self)
            .subscribe { vc, error in
                vc.handleError(error)
            }
            .disposed(by: disposeBag)
        tableView.rx.itemSelected
            .map { indexPath in
                let announcement = reactor.currentState.announcements[indexPath.row]
                return AnnouncementsReactor.Action.selectAnnouncement(announcement)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.selectedAnnouncement}
            .distinctUntilChanged()
            .compactMap{$0}
            .withUnretained(self)
            .subscribe { vc, announcement in
                let announcementDetailVC = AnnouncementDetailViewController(announcement: announcement)
                vc.navigationController?.pushViewController(announcementDetailVC, animated: true)
            }
            .disposed(by: disposeBag)
    }
}
