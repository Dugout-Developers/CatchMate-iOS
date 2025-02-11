//
//  DefualtTabelViewCell.swift
//  CatchMate
//
//  Created by 방유빈 on 2/11/25.
//
import UIKit
import SnapKit

final class DefualtTabelViewCell: UITableViewCell {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grayScale800
        return label
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
    func configData(_ title: String) {
        titleLabel.text = title
        titleLabel.applyStyle(textStyle: FontSystem.body01_medium)
    }
    func setupUI() {
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(18)
            make.top.bottom.equalToSuperview().inset(16)
        }
    }
}
