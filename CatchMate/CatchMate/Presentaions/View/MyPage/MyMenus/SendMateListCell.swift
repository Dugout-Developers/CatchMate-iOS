//
//  SendMateListCell.swift
//  CatchMate
//
//  Created by 방유빈 on 8/8/24.
//
import UIKit
import RxSwift
import FlexLayout
import PinLayout

final class SendMateListCell: UITableViewCell {
    private let containerView = UIView()
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmPrimaryColor
        return label
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmHeadLineTextColor
        label.numberOfLines = 1
        return label
    }()
    private let indicatorImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "cm20right")?.withTintColor(.grayScale500, renderingMode: .alwaysOriginal)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        backgroundColor = .clear
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        containerView.pin.width(size.width)
        containerView.flex.layout(mode: .adjustHeight)
        let height = containerView.frame.height
        return CGSize(width: size.width, height: height)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.pin.all()
        containerView.flex.layout(mode: .adjustHeight)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = ""
        infoLabel.text = ""
        titleLabel.flex.markDirty()
        infoLabel.flex.markDirty()
        containerView.flex.layout(mode: .adjustHeight)
    }
    
    func configData(apply: Apply) {
        titleLabel.text = apply.post.title
        titleLabel.applyStyle(textStyle: FontSystem.body01_medium)
        infoLabel.text = "\(apply.post.date) | \(apply.post.playTime) | \(apply.post.location)"
        infoLabel.applyStyle(textStyle: FontSystem.body03_medium)
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.flex.markDirty()
        infoLabel.flex.markDirty()
        containerView.flex.layout(mode: .adjustHeight)
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.flex.grow(1).direction(.row).paddingVertical(8).justifyContent(.start).alignItems(.center).define { flex in
            flex.addItem().grow(1).shrink(1).direction(.column).justifyContent(.start).alignItems(.start).define { flex in
                flex.addItem(infoLabel).marginBottom(4)
                flex.addItem(titleLabel)
            }
            flex.addItem(indicatorImageView).size(20).marginLeft(12)
        }
    }
}

