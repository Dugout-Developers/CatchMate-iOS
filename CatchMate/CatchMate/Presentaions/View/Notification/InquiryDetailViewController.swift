//
//  InquiryDetailViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 3/17/25.
//

import UIKit
import SnapKit
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
    
    private let titleView = UIView()
    private let contentView = UIView()
    private let answerView = UIView()
    
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
        self.reactor = InquiryReactor(inquiryId: inquiryId)
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLeftTitle("알림")
        bind(reactor: reactor)
        reactor.action.onNext(.loadInquiryDetail)
        
    }
    
    func bind(reactor: InquiryReactor) {
        reactor.state.map{$0.inquiryDetail}
            .compactMap{$0}
            .withUnretained(self)
            .subscribe { vc, inquiry in
                vc.setupUI()
                vc.setupStyle(inquiry: inquiry)
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
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubviews(views: [titleView, contentView, answerView])
        titleView.addSubviews(views: [titleLabel, dateLabel])
        contentView.addSubviews(views: [contentTitleLabel, contentLabel])
        answerView.addSubviews(views: [answerTitleLabel, answerLabel])

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        containerView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(view.snp.width)
        }
        
        titleView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.trailing.equalToSuperview().inset(18)
        }
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalTo(titleLabel)
            make.bottom.equalToSuperview().inset(12)
        }
        contentView.snp.makeConstraints { make in
            make.top.equalTo(titleView.snp.bottom).offset(8)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        contentTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(18)
        }
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(contentTitleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalTo(contentTitleLabel)
            make.bottom.equalToSuperview().inset(16)
        }
        answerView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.bottom).offset(8)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview().inset(16)
        }
        answerTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(18)
        }
        answerLabel.snp.makeConstraints { make in
            make.top.equalTo(answerTitleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalTo(answerTitleLabel)
            make.bottom.equalToSuperview()
        }
    }
}
