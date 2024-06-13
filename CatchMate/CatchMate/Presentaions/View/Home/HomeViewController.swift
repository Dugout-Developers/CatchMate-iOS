//
//  ViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 6/11/24.
//

import UIKit

enum Filter {
    case all
    case date
    case team
    case none
}

final class HomeViewController: UIViewController {
    private let filterContainerView = UIView()
    private let allFilterButton = HomeFilterButton(icon: UIImage(systemName: "list.bullet"), title: "전체", filter: .all)
    private let dateFilterButton = HomeFilterButton(icon: UIImage(systemName: "calendar"), title: "경기 날짜", filter: .date)
    private let teamFilterButton = HomeFilterButton(icon: UIImage(systemName: "person.3.fill"), title: "응원 구단", filter: .team)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .cmBackgroundColor
        setupUI()
        setupButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        filterContainerView.pin.top(view.pin.safeArea.top).left(view.pin.safeArea.left).right(view.pin.safeArea.right).height(50)
        filterContainerView.flex.layout()
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
        
        filterContainerView.flex.direction(.row).justifyContent(.start).alignItems(.center).paddingHorizontal(18).paddingVertical(11).define { flex in
            flex.addItem(allFilterButton).marginRight(8)
            flex.addItem(dateFilterButton).marginRight(8)
            flex.addItem(teamFilterButton)
        }
    }
}



