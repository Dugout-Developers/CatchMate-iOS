//
//  AllFilterViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 6/17/24.
//

import UIKit
import SnapKit
import ReactorKit
import RxSwift

final class AllFilterViewController: BaseViewController, View {
    private let allTeams: [Team] = Team.allTeam
    var reactor: HomeReactor
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "경기 날짜"
        label.textColor = .cmNonImportantTextColor
        label.applyStyle(textStyle: FontSystem.body02_medium)
        return label
    }()
    
    private let datePickerTextField = CMPickerTextField(placeHolder: "경기 날짜 및 시간을 입력해주세요.")
    
    private let teamSelectedLabel: UILabel = {
        let label = UILabel()
        label.text = "응원 구단"
        label.textColor = .cmNonImportantTextColor
        label.applyStyle(textStyle: FontSystem.body02_medium)
        return label
    }()
    
    private let teamCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    private let peopleNumLabel: UILabel = {
        let label = UILabel()
        label.text = "모집 인원 수"
        label.textColor = .cmNonImportantTextColor
        label.applyStyle(textStyle: FontSystem.body02_medium)
        return label
    }()
    
    private let numberPickerTextField = CMPickerTextField(rightAccessoryView: {
        let label = UILabel()
        label.text = "명"
        label.textColor = .grayScale400
        label.applyStyle(textStyle: FontSystem.body02_semiBold)
        return label
    }(), placeHolder: "본인 포함 인원")
    
    private let saveButton = CMDefaultFilledButton(title: "저장")
    
    init(reactor: HomeReactor) {
        self.reactor = reactor
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .cmBackgroundColor
        setupUI()
        setupPickerView()
        setupCollectionView()
        setupButton()
        bind(reactor: reactor)
    }
    
    private func setupButton() {
        saveButton.addTarget(self, action: #selector(clickSaveButton), for: .touchUpInside)
    }
    
    private func setupCollectionView() {
        teamCollectionView.register(TeamFilterCollectionViewCell.self, forCellWithReuseIdentifier: "TeamFilterCollectionViewCell")
        teamCollectionView.backgroundColor = .clear
    }
    
    private func setupPickerView() {
        // datePicker Setup
        datePickerTextField.parentViewController = self
        datePickerTextField.pickerViewController = DateFilterViewController(reactor: HomeReactor(), disposeBag: disposeBag)
        datePickerTextField.customDetent = BasePickerViewController.returnCustomDetent(height: Screen.height / 2.0 + 50.0, identifier: "DateFilter")
        
        // numberPicker Setup
        numberPickerTextField.parentViewController = self
        numberPickerTextField.pickerViewController = NumberPickerViewController()
        numberPickerTextField.customDetent = BasePickerViewController.returnCustomDetent(height: Screen.height / 3.0 + 10.0, identifier: "NumberFilter")
    }
    
    @objc
    private func clickSaveButton(_ sender: UIButton) {
        print("저장")
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Bind
extension AllFilterViewController {
    func bind(reactor: HomeReactor) {
        reactor.state.map{$0.selectedTeams}
            .bind(onNext: updateSelectedTeams)
            .disposed(by: disposeBag)
        
        Observable.just(allTeams)
            .bind(to: teamCollectionView.rx.items(cellIdentifier: "TeamFilterCollectionViewCell", cellType: TeamFilterCollectionViewCell.self)) { row, team, cell in
                let isSelected = reactor.currentState.selectedTeams.contains(team)
                cell.setupData(team: team, isSelect: isSelected)
            }
            .disposed(by: disposeBag)
        
        teamCollectionView.rx.itemSelected
            .withUnretained(self)
            .map { vc, indexPath in
                vc.tapTeamImage(vc.allTeams[indexPath.row])
                let team = vc.allTeams[indexPath.row]
                return Reactor.Action.toggleTeamSelection(team)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        teamCollectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    private func tapTeamImage(_ team: Team) {
        guard let cells = teamCollectionView.visibleCells as? [TeamFilterCollectionViewCell] else { return }
        for cell in cells {
            guard let team = cell.team else { continue }
            if cell.team == team {
                cell.isSelect.toggle()
            }
        }
    }
    
    private func updateSelectedTeams(_ selectedTeams: [Team]) {
        guard let cells = teamCollectionView.visibleCells as? [TeamFilterCollectionViewCell] else { return }
        for cell in cells {
            guard let team = cell.team else { continue }
            cell.isSelect = selectedTeams.contains(team)
        }
    }
}

// MARK: - Team Collection View 
extension AllFilterViewController: UICollectionViewDelegateFlowLayout {
    // UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard collectionViewLayout is UICollectionViewFlowLayout else {
            return CGSize(width: 52, height: 52)
        }

        let itemsPerRow: CGFloat = CGFloat(MainGridSystem.getColumn())
        let widthPerItem = MainGridSystem.getColumnWidth(totalWidht: Screen.width)
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return MainGridSystem.getGutter()
    }
}

// MARK: - UI
extension AllFilterViewController {
    private func setupUI() {
        let collectionViewHeight = MainGridSystem.getColumnWidth(totalWidht: Screen.width) * 2 + 8
        let labelBottomMargin = 12
        let sectionMargin = 32
        let headerMargin = 20
        view.addSubviews(views: [dateLabel, datePickerTextField, teamSelectedLabel, teamCollectionView, peopleNumLabel, numberPickerTextField, saveButton])
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(headerMargin)
            make.leading.trailing.equalToSuperview().inset(MainGridSystem.getMargin())
        }
        datePickerTextField.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(labelBottomMargin)
            make.leading.trailing.equalTo(dateLabel)
        }
        teamSelectedLabel.snp.makeConstraints { make in
            make.top.equalTo(datePickerTextField.snp.bottom).offset(sectionMargin)
            make.leading.trailing.equalTo(dateLabel)
        }
        teamCollectionView.snp.makeConstraints { make in
            make.top.equalTo(teamSelectedLabel.snp.bottom).offset(labelBottomMargin)
            make.leading.trailing.equalTo(dateLabel)
            make.height.equalTo(collectionViewHeight)
        }
        peopleNumLabel.snp.makeConstraints { make in
            make.top.equalTo(teamCollectionView.snp.bottom).offset(sectionMargin)
            make.leading.trailing.equalTo(dateLabel)
        }
        numberPickerTextField.snp.makeConstraints { make in
            make.top.equalTo(peopleNumLabel.snp.bottom).offset(labelBottomMargin)
            make.leading.trailing.equalTo(dateLabel)
        }
        saveButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-34)
            make.leading.trailing.equalToSuperview().inset(12)
            make.height.equalTo(52)
        }
    }
}
