//
//  CheerStylePickerViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 11/15/24.
//

import UIKit
import RxSwift
import ReactorKit
import SnapKit

final class CheerStylePickerViewController: BasePickerViewController, View {
    private let allStyles: [CheerStyles] = CheerStyles.allCases
    private var selectedStyle: CheerStyles?
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 9 // 아이템 간 가로 간격
        layout.minimumLineSpacing = 12 // 아이템 간 세로 간격
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    private let saveButton = CMDefaultFilledButton(title: "저장")
    
    var reactor: ProfileEditReactor
    var disposeBag = DisposeBag()
    
    init(reactor: ProfileEditReactor) {
        self.reactor = reactor
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedStyle = reactor.currentState.cheerStyle
        collectionView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        bind(reactor: reactor)
        setupUI()
        setupCollectionView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disable()
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CheerStyleCollecionViewCell.self, forCellWithReuseIdentifier: "CheerStyleCell")
        collectionView.backgroundColor = .white
    }
}

// MARK: - UICollectionView DataSource
extension CheerStylePickerViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allStyles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CheerStyleCell", for: indexPath) as? CheerStyleCollecionViewCell else {
            return UICollectionViewCell()
        }
        let item = allStyles[indexPath.item]
        cell.setupData(item)
        
        if item == selectedStyle {
            cell.toggleButtonState(true)
        } else {
            cell.toggleButtonState(false)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = allStyles[indexPath.item]
        guard let cells = collectionView.visibleCells as? [CheerStyleCollecionViewCell] else { return }
        for cell in cells {
            guard let cellStyle = cell.cheerStyle else { continue }
            if cellStyle == item || cellStyle == selectedStyle {
                cell.toggleButtonState()
            }
        }
        if selectedStyle != item {
            selectedStyle = item
        } else {
            selectedStyle = nil
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalHorizontalSpacing = 9
        let itemWidth = (collectionView.frame.width - CGFloat(totalHorizontalSpacing)) / 2
        return CGSize(width: itemWidth, height: 200)
    }
}
// MARK: - Bind
extension CheerStylePickerViewController {
    func bind(reactor: ProfileEditReactor) {
        saveButton.rx.tap
            .withUnretained(self)
            .subscribe { vc, _ in
                reactor.action.onNext(.changeCheerStyle(vc.selectedStyle))
                vc.disable()
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UI
extension CheerStylePickerViewController {
    private func setupUI() {
        view.addSubviews(views: [collectionView, saveButton])

        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(34)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(30)
            make.leading.trailing.equalTo(collectionView)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-30)
            make.height.equalTo(50)
        }
    }
}

final class CheerStyleCollecionViewCell: UICollectionViewCell {
    var cheerStyle: CheerStyles? {
        didSet {
            if let cheerStyle {
                self.styleButton.updateData(cheerStyle)
            }
        }
    }
    private let styleButton: CheerStyleButton = CheerStyleButton(item: nil)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.cheerStyle = nil
    }
    
    func toggleButtonState(_ state: Bool? = nil) {
        if let state {
            styleButton.isSelected = state
        } else {
            styleButton.isSelected.toggle()
        }
    }
    
    func setupData(_ style: CheerStyles) {
        cheerStyle = style
    }
    private func setupUI() {
        contentView.addSubview(styleButton)
        
        styleButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}
