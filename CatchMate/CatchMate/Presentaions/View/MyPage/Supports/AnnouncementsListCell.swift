//
//  AnnouncementsListCell.swift
//  CatchMate
//
//  Created by 방유빈 on 8/8/24.
//

import UIKit
import RxSwift
import FlexLayout
import PinLayout

final class AnnouncementsListCell: UITableViewCell {
    var disposeBag = DisposeBag()
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.04
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 10
        view.layer.cornerRadius = 8
        return view
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .cmHeadLineTextColor
        return label
    }()
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmNonImportantTextColor
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
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        containerView.pin.width(size.width)
        containerView.flex.layout(mode: .adjustHeight)
        let height = containerView.frame.height + 8
        return CGSize(width: size.width, height: height)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.pin.all()
        containerView.flex.layout(mode: .adjustHeight)
        
        containerView.layer.shadowPath = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: containerView.layer.cornerRadius).cgPath
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        titleLabel.text = ""
        infoLabel.text = ""
        titleLabel.flex.markDirty()
        infoLabel.flex.markDirty()
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func configData(announcement: Announcement) {
        titleLabel.text = announcement.title
        titleLabel.applyStyle(textStyle: FontSystem.body01_medium)
        infoLabel.text = "\(announcement.writer) | \(announcement.writeDate)"
        infoLabel.applyStyle(textStyle: FontSystem.body03_reguler)
        titleLabel.flex.markDirty()
        infoLabel.flex.markDirty()
        containerView.flex.layout(mode: .adjustHeight)
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.flex.direction(.column).padding(16).justifyContent(.start).alignItems(.start).define { flex in
            flex.addItem(titleLabel).marginBottom(8)
            flex.addItem(infoLabel)
        }
    }
}
