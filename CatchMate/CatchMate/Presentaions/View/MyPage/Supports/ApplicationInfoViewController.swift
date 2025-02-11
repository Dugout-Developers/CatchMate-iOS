//
//  ApplicationInfoViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 2/10/25.
//
import UIKit
import SnapKit
import RxSwift
final class ApplicationInfoViewController: BaseViewController {
    enum ApplicationInfo: String, CaseIterable {
        case openSourceLibrary = "Open Source Library"
    }
    private let applicationInfos = ApplicationInfo.allCases
    private let tableView = UITableView()
    
    override var useSnapKit: Bool {
        return true
    }
    override var buttonContainerExists: Bool {
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLeftTitle("정보")
        setupTableView()
        setupUI()
        bind()
    }
    
    private func setupTableView() {
        tableView.register(DefualtTabelViewCell.self, forCellReuseIdentifier: "DefualtTabelViewCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
    }
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    private func bind() {
        Observable.just(applicationInfos)
            .bind(to: tableView.rx.items(cellIdentifier: "DefualtTabelViewCell", cellType: DefualtTabelViewCell.self)) {  (row, item, cell) in
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
                cell.configData(item.rawValue)
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .withUnretained(self)
            .subscribe { vc, indexPath in
                print("오픈소스라이브러리")
            }
            .disposed(by: disposeBag)
    }
}
