//
//  TermViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 2/10/25.
//
import UIKit
import RxSwift
import SnapKit
import SafariServices

final class TermViewController: BaseViewController {
    enum Terms: String, CaseIterable {
        case personalInfo = "개인 정보 처리 방침"
        case service = "서비스 이용 약관"
        case community = "커뮤니티 이용 가이드"
        
        var siteURL: String {
            switch self {
            case .personalInfo:
                return "https://catchmate.notion.site/19690504ec15804ba163fcf8fa0ab937?pvs=4"
            case .service:
                return "https://catchmate.notion.site/19690504ec15803588a7ca69b306bf3e?pvs=4"
            case .community:
                return "https://catchmate.notion.site/19690504ec1580d6b2d0e38eb46c5536?pvs=4"
            }
        }
    }
    private let terms = Terms.allCases
    override var useSnapKit: Bool {
        return true
    }
    override var buttonContainerExists: Bool {
        return false
    }
    private let tableView = UITableView()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLeftTitle("약관 및 정책")
        setupUI()
        setupTableView()
        bind()
    }
    private func setupTableView() {
        tableView.register(DefualtTabelViewCell.self, forCellReuseIdentifier: "DefualtTabelViewCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
    }
    private func bind() {
        Observable.just(terms)
            .bind(to: tableView.rx.items(cellIdentifier: "DefualtTabelViewCell", cellType: DefualtTabelViewCell.self)) {  (row, item, cell) in
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
                cell.configData(item.rawValue)
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .withUnretained(self)
            .subscribe { vc, indexPath in
                let urlString = vc.terms[indexPath.row].siteURL
                vc.openSafari(urlString)
            }
            .disposed(by: disposeBag)
        
    }
    private func openSafari(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let safariVC = SFSafariViewController(url: url)
        safariVC.delegate = self
        present(safariVC, animated: true)
    }
}
extension TermViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        // Safari 뷰가 닫힐 때 호출됨
        dismiss(animated: true)
    }
}
