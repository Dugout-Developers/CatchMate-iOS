//
//  MypageListCell.swift
//  CatchMate
//
//  Created by 방유빈 on 8/1/24.
//

import UIKit
import SnapKit
final class MypageListCell: UITableViewCell {
    private let containerView: UIView = UIView()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmHeadLineTextColor
        return label
    }()
    private let bedgeView: UIView = {
        let view = UIView()
        view.backgroundColor = .cmPrimaryColor
        view.isHidden = true
        view.layer.cornerRadius = 9
        view.clipsToBounds = true
        return view
    }()
    private let bedgeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.isEnabled = true
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        setupUI()
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        [bedgeLabel, bedgeView].forEach {
            $0.isHidden = true
        }
    }
    func configData(title: String, bedge: Int? = nil) {
        titleLabel.text = title
        titleLabel.applyStyle(textStyle: FontSystem.body01_medium)
        if let count = bedge, count > 0 {
            bedgeLabel.isHidden = false
            bedgeView.isHidden = false
            bedgeLabel.text = String(count)
            bedgeLabel.applyStyle(textStyle: FontSystem.bedgeText)
        }
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubviews(views: [titleLabel, bedgeView])
        bedgeView.addSubview(bedgeLabel)
        containerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(MainGridSystem.getMargin())
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
        }
        bedgeView.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(4)
            make.centerY.equalToSuperview()
            make.size.equalTo(18)
        }
        bedgeLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
