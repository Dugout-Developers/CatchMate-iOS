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
    
    private let appVersionView = UIView()
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo_white")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let appNameLabel: UILabel = {
        let label = UILabel()
        label.text = "CatchMate"
        label.textColor = .grayScale800
        label.applyStyle(textStyle: FontSystem.headline03_medium)
        return label
    }()
    private let versionLabel: UILabel = {
        let label = UILabel()
        label.text = "v.1.0.0"
        label.textColor = .grayScale500
        label.applyStyle(textStyle: FontSystem.body02_medium)
        return label
    }()
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
        view.backgroundColor = .grayScale50
        appVersionView.backgroundColor = .clear
    }
    
    private func setupTableView() {
        tableView.register(DefualtTabelViewCell.self, forCellReuseIdentifier: "DefualtTabelViewCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
    }
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(appVersionView)
        view.addSubview(tableView)
        appVersionView.addSubviews(views: [logoImageView, appNameLabel, versionLabel])
        
        appVersionView.snp.makeConstraints { make in
            make.leading.trailing.top.equalTo(view.safeAreaLayoutGuide)
        }
        logoImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.centerX.equalToSuperview()
            make.size.equalTo(88)
        }
        appNameLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        versionLabel.snp.makeConstraints { make in
            make.top.equalTo(appNameLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(20)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(appVersionView.snp.bottom).offset(20)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
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
