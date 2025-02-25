//
//  Untitled.swift
//  CatchMate
//
//  Created by 방유빈 on 2/11/25.
//
import UIKit
import RxSwift
import SnapKit
import ReactorKit
final class CustomerServiceAddViewController: BaseViewController, View {
    private let reactor: CustomerServiceReactor
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "자유롭게 적어주세요 "
        label.textColor = .grayScale500
        label.applyStyle(textStyle: FontSystem.body02_medium)
        return label
    }()
    private let requiredImg: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "requiredMark")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let textCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0/500"
        label.textColor = .grayScale500
        label.applyStyle(textStyle: FontSystem.body02_medium)
        return label
    }()
    private let textView: CMTextView = {
        let textView = CMTextView()
        textView.backgroundColor = .grayScale50
        textView.placeholder = "내용을 입력해주세요"
        return textView
    }()
    
    private let submitButton = CMDefaultFilledButton(title: "문의하기")
    override var useSnapKit: Bool {
        return true
    }
    override var buttonContainerExists: Bool {
        return false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind(reactor: reactor)
    }
    
    init(menu: CustomerServiceMenu) {
        reactor = DIContainerService.shared.makeCustomerServiceReactor(menu: menu)
        super.init(nibName: nil, bundle: nil)
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: CustomerServiceReactor) {
        submitButton.rx.tap
            .throttle(.seconds(3), latest: false, scheduler: MainScheduler.instance)
            .subscribe { _ in
                reactor.action.onNext(.submitContent)
            }
            .disposed(by: disposeBag)
        textView.rx.text.orEmpty
            .distinctUntilChanged()
            .map { text in
                let string = String(text.prefix(500))
                return string
            }
            .map { Reactor.Action.changeText($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.isSubmit}
            .filter{$0}
            .withUnretained(self)
            .subscribe { vc, _ in
                vc.navigationController?.popToRootViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.text}
            .compactMap{$0}
            .withUnretained(self)
            .subscribe { vc, text in
                vc.textView.text = text
                vc.textView.updateTextStyle()
                vc.updateAddTextCount(text.count)
                
            }
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.text}
            .withUnretained(self)
            .subscribe { vc, text in
                if text?.isEmpty ?? true {
                    vc.submitButton.isEnabled = false
                } else {
                    vc.submitButton.isEnabled = true
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.count}
            .withUnretained(self)
            .subscribe { vc, count in
                vc.updateAddTextCount(count)
            }
            .disposed(by: disposeBag)
        
        reactor.state.compactMap{$0.error}
            .withUnretained(self)
            .subscribe { vc, error in
                vc.handleError(error)
            }
            .disposed(by: disposeBag)
    }
    
    private func updateAddTextCount(_ count: Int) {
        textCountLabel.text = "\(count)/500"
        textCountLabel.applyStyle(textStyle: FontSystem.body02_medium)
    }
    
    private func setupUI() {
        view.addSubviews(views: [infoLabel, requiredImg, textCountLabel, textView, submitButton])
        infoLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(MainGridSystem.getMargin())
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
        }
        requiredImg.snp.makeConstraints { make in
            make.leading.equalTo(infoLabel.snp.trailing)
            make.centerY.equalTo(infoLabel)
            make.size.equalTo(6)
        }
        textCountLabel.snp.makeConstraints { make in
            make.top.bottom.equalTo(infoLabel)
            make.trailing.equalToSuperview().offset(-MainGridSystem.getMargin())
        }
        textView.snp.makeConstraints { make in
            make.top.equalTo(infoLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(MainGridSystem.getMargin())
            make.height.equalTo(170)
        }
        submitButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(textView)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(30)
            make.height.equalTo(50)
        }
    }
}
