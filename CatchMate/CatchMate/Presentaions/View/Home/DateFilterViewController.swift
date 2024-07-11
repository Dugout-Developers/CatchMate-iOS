//
//  DateFilterViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 6/15/24.
//

import UIKit
import SnapKit
import ReactorKit

final class DateFilterViewController: BasePickerViewController, View {
    private let cmDatePicker = CMDatePicker()
    private let saveButton = CMDefaultFilledButton(title: "저장")
    var disposeBag: DisposeBag
    private let reactor: HomeReactor
    
    init(reactor: HomeReactor, disposeBag: DisposeBag) {
        self.reactor = reactor
        self.disposeBag = disposeBag
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupDatePicker()
        setupButton()
        bind(reactor: reactor)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disable()
    }
    
    private func setupDatePicker() {
        cmDatePicker.minimumDate = Date()
    }
    
    private func setupButton() {
        saveButton.addTarget(self, action: #selector(clickSaveButton), for: .touchUpInside)
    }
    @objc private func clickSaveButton(_ sender: UIButton) {
        if let selectedDate = cmDatePicker.selectedDate {
            itemSelected(DateHelper.shared.toString(from: selectedDate, format: "M월 d일 EEEE"))
        } else {
            itemSelected("")
        }
    }
    func bind(reactor: HomeReactor) {
        saveButton.rx.tap
            .withUnretained(self)
            .map { ( vc, _ ) -> Date? in
                return vc.cmDatePicker.selectedDate
            }
            .map { Reactor.Action.updateDateFilter($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}

// MARK: - UI
extension DateFilterViewController {
    private func setupUI() {
        view.addSubviews(views: [cmDatePicker, saveButton])
        
        cmDatePicker.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.leading.trailing.equalToSuperview().inset(12)
        }
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(cmDatePicker.snp.bottom).offset(30)
            make.leading.trailing.equalTo(cmDatePicker)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-30)
            make.height.equalTo(50)
        }
    }
}
