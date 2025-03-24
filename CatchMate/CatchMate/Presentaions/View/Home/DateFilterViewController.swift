//
//  DateFilterViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 6/15/24.
//

import UIKit
import SnapKit
import ReactorKit

extension Reactive where Base: DateFilterViewController {
    var selectedTime: Observable<PlayTime> {
        return base._selectedTime.asObservable()
    }
}
final class DateFilterViewController: BasePickerViewController, View {
    private let playTime = PlayTime.allCases
    var isAddViewFilter: Bool = false
    fileprivate var _selectedTime = PublishSubject<PlayTime>()
    private var selectedTimeIndex: Int? {
        didSet {
            if let index = selectedTimeIndex {
                timeButton.forEach { button in
                    button.isSelected = (button.tag == index)
                }
                _selectedTime.onNext(playTime[index])
            }
        }
    }
    let cmDatePicker = CMDatePicker()
    private let saveButton = CMDefaultFilledButton(title: "저장")
    private let resetButton: UIButton = {
        let button = UIButton()
        button.setTitle("초기화", for: .normal)
        button.applyStyle(textStyle: FontSystem.body02_semiBold)
        button.setTitleColor(.cmNonImportantTextColor, for: .normal)
        button.backgroundColor = .grayScale50
        button.clipsToBounds = true
        button.layer.cornerRadius = 8
        return button
    }()
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "경기 시간"
        label.textColor = .cmNonImportantTextColor
        label.applyStyle(textStyle: FontSystem.body02_medium)
        return label
    }()
    private let timeButton: [PaddingLabel] = {
        let times = PlayTime.allCases
        var paddingLabels = [PaddingLabel]()
        for i in 0..<times.count {
            let label = PaddingLabel(title: times[i].rawValue)
            label.tag = i
            paddingLabels.append(label)
        }
        return paddingLabels
    }()
    var disposeBag: DisposeBag
    var reactor: HomeReactor?
    var addReactor: AddReactor?
    
    init(reactor: any Reactor, disposeBag: DisposeBag, isAddView: Bool = false) {
        self.isAddViewFilter = isAddView
        self.disposeBag = disposeBag
        super.init(nibName: nil, bundle: nil)
        if let homeReactor = reactor as? HomeReactor {
            self.reactor = homeReactor
            bind(reactor: homeReactor)
        } else if let addReactor = reactor as? AddReactor {
            self.addReactor = addReactor
            bind(reactor: addReactor)
        }
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disable()
    }
    
    private func setupDatePicker() {
        cmDatePicker.minimumDate = Date()
    }
    
    private func setupButton() {
        if isAddViewFilter {
            timeButton.forEach { button in
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(clickTimeButton))
                button.addGestureRecognizer(tapGesture)
            }
        } else {
            saveButton.isEnabled = true
            saveButton.addTarget(self, action: #selector(clickSaveButton), for: .touchUpInside)
        }
    }
    @objc private func clickTimeButton(_ gesture: UITapGestureRecognizer) {
        guard let tapLabel = gesture.view as? PaddingLabel else { return }
        selectedTimeIndex = tapLabel.tag
    }

    @objc private func clickSaveButton(_ sender: UIButton) {
        if let selectedDate = cmDatePicker.selectedDate {
            itemSelected(DateHelper.shared.toString(from: selectedDate, format: "M월 d일 EEEE"))
        } else {
            itemSelected("")
        }
    }
}

// MARK: -
extension DateFilterViewController {
    func bind(reactor: AddReactor) {
        reactor.state.map{$0.datePickerSaveButtonState}
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, state in
                vc.saveButton.isEnabled = state
            })
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.selecteDate}
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, date in
                if let date = date {
                    vc.cmDatePicker.selectedDate = date
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.selecteTime}            
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe { vc, time in
                if let time = time {
                    vc.selectedTimeIndex = PlayTime.allCases.firstIndex(of: time)
                }
            }
            .disposed(by: disposeBag)
        saveButton.rx.tap
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe { vc, _ in
                vc.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        _selectedTime
            .map{AddReactor.Action.changeTime($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        cmDatePicker._selectedDate
            .map{AddReactor.Action.changeDate($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
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
        
        resetButton.rx.tap
            .withUnretained(self)
            .subscribe { vc, _ in
                reactor.action.onNext(.updateDateFilter(nil))
                vc.dismiss(animated: true)
            }
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
    private func setupUI(isHome: Bool = false) {
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
                view.addSubview(resetButton)
                resetButton.snp.makeConstraints { make in
                    make.top.equalTo(cmDatePicker.snp.bottom).offset(30)
                    make.leading.equalToSuperview().inset(ButtonGridSystem.getMargin())
                    make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-30)
                    make.width.equalTo(ButtonGridSystem.getColumnWidth(totalWidht: Screen.width))
                    make.height.equalTo(52)
                }
                saveButton.snp.makeConstraints { make in
                    make.top.bottom.height.equalTo(resetButton)
                    make.leading.equalTo(resetButton.snp.trailing).offset(ButtonGridSystem.getGutter())
                    make.trailing.equalToSuperview().inset(ButtonGridSystem.getMargin())
                }
            
        }
    }
}
