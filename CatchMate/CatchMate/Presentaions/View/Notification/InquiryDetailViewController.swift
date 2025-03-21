//
//  InquiryDetailViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 3/17/25.
//

import UIKit
import SnapKit
import FlexLayout
import PinLayout
import RxSwift
import ReactorKit

final class InquiryDetailViewController: BaseViewController, View {
    override var useSnapKit: Bool {
        return true
    }
    override var buttonContainerExists: Bool {
        return false
    }
    var reactor: InquiryReactor
    private let inquiryId: Int
    private let scrollView = UIScrollView()
    private let containerView = UIView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grayScale800
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grayScale500
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let contentTitleLabel = {
        let label = UILabel()
        label.textColor = .grayScale500
        label.adjustsFontSizeToFitWidth = true
        label.text = "문의 내용"
        label.applyStyle(textStyle: FontSystem.body02_medium)
        return label
    }()
    private let contentLabel = {
        let label = UILabel()
        label.textColor = .grayScale800
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    private let answerTitleLabel = {
        let label = UILabel()
        label.textColor = .grayScale500
        label.adjustsFontSizeToFitWidth = true
        label.text = "답변"
        label.applyStyle(textStyle: FontSystem.body02_medium)
        return label
    }()
    private let answerLabel = {
        let label = UILabel()
        label.textColor = .grayScale800
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    init(inquiryId: Int) {
        self.inquiryId = inquiryId
        self.reactor = InquiryReactor(inquiryId: inquiryId, inquiryUsecase: DIContainerService.shared.makeInquiryUseCase())
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLeftTitle("알림")
        setupUI()
        bind(reactor: reactor)
        reactor.action.onNext(.loadInquiryDetail)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.pin.all(view.pin.safeArea)
        containerView.pin.top().left().right()
        containerView.flex.layout(mode: .adjustHeight)
        scrollView.contentSize = containerView.frame.size
    }
    func bind(reactor: InquiryReactor) {
        reactor.state.map{$0.inquiryDetail}
            .compactMap{$0}
            .withUnretained(self)
            .subscribe { vc, inquiry in
                vc.setupStyle(inquiry: inquiry)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.error}
            .compactMap{$0}
            .withUnretained(self)
            .subscribe { vc, error in
                vc.handleError(error)
            }
            .disposed(by: disposeBag)
    }
    private func setupStyle(inquiry: Inquiry) {
        titleLabel.text = "\(inquiry.nickName) 님의 문의에 대한 답변입니다"
        titleLabel.applyStyle(textStyle: FontSystem.headline03_medium)
        dateLabel.text = inquiry.createAt
        dateLabel.applyStyle(textStyle: FontSystem.body02_medium)
        contentLabel.text = inquiry.content
        contentLabel.applyStyle(textStyle: FontSystem.body02_medium)
        answerLabel.text = inquiry.answer
        answerLabel.applyStyle(textStyle: FontSystem.body02_medium)
        
        titleLabel.flex.markDirty()
        dateLabel.flex.markDirty()
        contentLabel.flex.markDirty()
        answerLabel.flex.markDirty()
        containerView.flex.markDirty()
        containerView.flex.layout(mode: .adjustHeight)
    }

    private func setupUI() {
        view.backgroundColor = .cmGrayBackgroundColor
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubviews(views: [titleLabel, dateLabel, contentTitleLabel, contentLabel, answerTitleLabel, answerLabel])
        
        containerView.flex.direction(.column).justifyContent(.start).alignItems(.start).define { flex in
            flex.addItem().direction(.column).paddingVertical(12).define { flex in
                flex.addItem(titleLabel).marginBottom(16)
                flex.addItem(dateLabel)
            }
            .backgroundColor(.white).width(100%).paddingHorizontal(18)
            flex.addItem().direction(.column).paddingVertical(16).define { flex in
                flex.addItem(contentTitleLabel).marginBottom(12)
                flex.addItem(contentLabel)
            }
            .backgroundColor(.white).width(100%).paddingHorizontal(18).marginVertical(8)
            flex.addItem().direction(.column).paddingVertical(16).define { flex in
                flex.addItem(answerTitleLabel).marginBottom(12)
                flex.addItem(answerLabel)
            }
            .backgroundColor(.white).width(100%).paddingHorizontal(18)
        }

    }
}
