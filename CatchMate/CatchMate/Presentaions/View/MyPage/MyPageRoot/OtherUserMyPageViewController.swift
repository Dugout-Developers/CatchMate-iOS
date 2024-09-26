//
//  OtherUserMyPageViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 8/11/24.
//
import UIKit
import RxSwift
import ReactorKit

final class OtherUserMyPageViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, View  {
    private var user: SimpleUser
    private let tableview = UITableView()
    private let reactor: OtherUserpageReactor
    private var posts: [SimplePost] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reactor.action.onNext(.loadPost)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupTableView()
        setupUI()
        bind(reactor: reactor)
    }
    
    init(user: SimpleUser, reactor: OtherUserpageReactor) {
        self.user = user
        self.reactor = reactor
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupNavigation() {
        if user.userId != SetupInfoService.shared.getUserInfo(type: .id) {
            let menuButton = UIButton()
            menuButton.setImage(UIImage(named: "cm20kebab")?.withTintColor(.grayScale700, renderingMode: .alwaysOriginal), for: .normal)
            menuButton.addTarget(self, action: #selector(clickMenuButton), for: .touchUpInside)
            customNavigationBar.addRightItems(items: [menuButton])
        }

    }
    @objc private func clickMenuButton(_ sender: UIButton) {

    }
    
    private func setupTableView() {
        tableview.delegate = self
        tableview.dataSource = self
        tableview.separatorStyle = .none
        tableview.register(MyPageProfileCell.self, forCellReuseIdentifier: "MyPageProfileCell")
        tableview.register(ListCardViewTableViewCell.self, forCellReuseIdentifier: "ListCardViewTableViewCell")
        tableview.estimatedSectionHeaderHeight = 0
         tableview.estimatedSectionFooterHeight = 0
        tableview.sectionHeaderTopPadding = 0
    }
    private func setupUI() {
        tableview.backgroundColor = .grayScale50
        view.addSubview(tableview)
        tableview.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return posts.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyPageProfileCell", for: indexPath) as? MyPageProfileCell else {
                return UITableViewCell()
            }
            cell.configData(user, indicatorIsHidden: true)
            cell.selectionStyle = .none
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListCardViewTableViewCell", for: indexPath) as? ListCardViewTableViewCell else {
                return UITableViewCell()
            }
            let post = posts[indexPath.row]
            cell.setupData(post)
            cell.selectionStyle = .none
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            break
        case 1:
            let post = posts[indexPath.row]
            let detailVC = PostDetailViewController(postID: post.id)
            navigationController?.pushViewController(detailVC, animated: true)
        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 88 : UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 88 : 174
    }
}

// MARK: - Bind
extension OtherUserMyPageViewController {
    func bind(reactor: OtherUserpageReactor) {
        reactor.state.map{$0.posts}
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe { vc, posts in
                vc.posts = posts
                let indexSet = IndexSet(integer: 1)
                vc.tableview.reloadSections(indexSet, with: .automatic)
            }
            .disposed(by: disposeBag)
        
        tableview.rx.contentOffset
            .skip(1)
            .map { $0.y }
            .withUnretained(self)
            .bind { vc, offsetY in
                vc.scrollSetupNavigation(offsetY)
            }.disposed(by: disposeBag)
    }
    
    func scrollSetupNavigation(_ offsetY: CGFloat) {
        if offsetY > 88 {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                setupLeftTitle("\(user.nickName)", font: FontSystem.body01_semiBold)
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                setupLeftTitle("")
            }
        }
    }
}

