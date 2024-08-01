//
//  MypageHeader.swift
//  CatchMate
//
//  Created by 방유빈 on 8/1/24.
//

import UIKit
import SnapKit

class MypageHeader: UITableViewHeaderFooterView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmNonImportantTextColor
        return label
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .white
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(MainGridSystem.getMargin())
            make.top.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(12)
        }
    }

    func configData(title: String) {
        titleLabel.text = title
        titleLabel.applyStyle(textStyle: FontSystem.body02_medium)
    }
}

final class DividerFooterView: UITableViewHeaderFooterView {

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .clear
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        contentView.backgroundColor = .clear
    }
}
