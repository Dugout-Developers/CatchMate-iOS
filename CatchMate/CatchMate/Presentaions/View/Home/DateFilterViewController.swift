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
    var isAddViewFilter: Bool = false
    var selectedTime: Int? = nil
    let cmDatePicker = CMDatePicker()
    private let saveButton = CMDefaultFilledButton(title: "저장")
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "경기 시간"
        label.textColor = .cmNonImportantTextColor
        label.applyStyle(textStyle: FontSystem.body02_medium)
        return label
    }()
    private let timeButton: [PaddingLabel] = {
        let times = ["14:00", "17:00", "18:00" ,"18:30"]
        var paddingLabels = [PaddingLabel]()
        times.forEach { time in
            paddingLabels.append(PaddingLabel(title: time))
        }
        return paddingLabels
    }()
    var disposeBag: DisposeBag
    private let reactor: HomeReactor
    
    init(reactor: HomeReactor, disposeBag: DisposeBag, isAddView: Bool = false) {
        self.isAddViewFilter = isAddView
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
        reactor.state.map{$0.dateFilterValue}
            .withUnretained(self)
            .subscribe(onNext: { vc, date in
                if let date = date {
                    vc.cmDatePicker.selectedDate = date
                }
            })
            .disposed(by: disposeBag)
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
            make.leading.trailing.equalToSuperview().inset(MainGridSystem.getMargin())
        }
        if isAddViewFilter {
            let stackView = UIStackView()
            view.addSubviews(views: [timeLabel, stackView])
            timeLabel.snp.makeConstraints { make in
                make.top.equalTo(cmDatePicker.snp.bottom).offset(30)
                make.leading.trailing.equalTo(cmDatePicker)
            }
            stackView.axis = .horizontal
            stackView.distribution = .equalSpacing
            stackView.spacing = 8
            timeButton.forEach { button in
                stackView.addArrangedSubview(button)
            }
            stackView.snp.makeConstraints { make in
                make.top.equalTo(timeLabel.snp.bottom).offset(12)
                make.leading.equalTo(cmDatePicker)
            }
            saveButton.snp.makeConstraints { make in
                make.top.equalTo(stackView.snp.bottom).offset(36)
                make.leading.trailing.equalToSuperview().inset(12)
                make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-34)
                make.height.equalTo(52)
            }
        } else {
            saveButton.snp.makeConstraints { make in
                make.top.equalTo(cmDatePicker.snp.bottom).offset(30)
                make.leading.trailing.equalToSuperview().inset(12)
                make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-34)
                make.height.equalTo(52)
            }
        }
    }
}
