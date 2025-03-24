//
//  NumberPickerView.swift
//  CatchMate
//
//  Created by 방유빈 on 6/18/24.
//

import UIKit
import RxSwift
import ReactorKit

final class NumberPickerViewController: BasePickerViewController , View {
    private let picker: UIPickerView = UIPickerView()
    private var selectedNum: Int = 1
    private let numberArr: [Int] = [2,3,4,5,6,7,8]
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
    private let saveButton = CMDefaultFilledButton(title: "저장")
    
    var reactor: HomeReactor?
    var addReactor: AddReactor?
    var disposeBag = DisposeBag()
    
    init(reactor: any Reactor) {
        super.init(nibName: nil, bundle: nil)
        
        if let homeReactor = reactor as? HomeReactor {
            self.reactor = homeReactor
        } else if let addReactor = reactor as? AddReactor {
            self.addReactor = addReactor
        }
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupPicker()
        setupButton()
        if let homeReactor = reactor {
            bind(reactor: homeReactor)
            setupUI(isHome: true)
        } else if let addReactor = addReactor {
            bind(reactor: addReactor)
            setupUI()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disable()
    }
    
    private func setupPicker() {
        picker.delegate = self
        picker.dataSource = self
    }
    
    private func setupButton() {
        saveButton.addTarget(self, action: #selector(clickSaveButton), for: .touchUpInside)
    }
    @objc
    private func clickSaveButton(_ sender: UIButton) {
        itemSelected(String(selectedNum))
    }
}
// MARK: - Bind
extension NumberPickerViewController {
    func bind(reactor: HomeReactor) {
        reactor.state.map{$0.seletedNumberFilter}
            .compactMap{$0}
            .withUnretained(self)
            .subscribe(onNext: { vc, number in
                vc.selectedNum = number
                vc.picker.selectRow(number-1, inComponent: 0, animated: false)
            })
            .disposed(by: disposeBag)
        saveButton.rx.tap
            .withUnretained(self)
            .map { ( vc, _ ) -> Int? in
                return vc.selectedNum
            }
            .map { Reactor.Action.updateNumberFilter($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        resetButton.rx.tap
            .withUnretained(self)
            .subscribe { vc, _ in
                reactor.action.onNext(.updateNumberFilter(nil))
                vc.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    func bind(reactor: AddReactor) {
        reactor.state.map{$0.partyNumber}
            .compactMap{$0}
            .withUnretained(self)
            .subscribe(onNext: { vc, number in
                vc.selectedNum = number
                vc.picker.selectRow(number-1, inComponent: 0, animated: false)
            })
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .withUnretained(self)
            .subscribe { vc, _ in
                reactor.action.onNext(.changePartyNumber(vc.selectedNum))
                vc.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
}
// MARK: - Picker
extension NumberPickerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return numberArr.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedNum = numberArr[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(numberArr[row])명"
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40.0
    }
}
// MARK: - UI
extension NumberPickerViewController {
    private func setupUI(isHome: Bool = false) {
        view.addSubviews(views: [picker, saveButton])
        
        picker.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.leading.trailing.equalToSuperview().inset(12)
        }
        if isHome {
            view.addSubview(resetButton)
            resetButton.snp.makeConstraints { make in
                make.top.equalTo(picker.snp.bottom).offset(30)
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
        } else {
            saveButton.snp.makeConstraints { make in
                make.top.equalTo(picker.snp.bottom).offset(30)
                make.leading.trailing.equalTo(picker)
                make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-30)
                make.height.equalTo(50)
            }
        }
    }
}



