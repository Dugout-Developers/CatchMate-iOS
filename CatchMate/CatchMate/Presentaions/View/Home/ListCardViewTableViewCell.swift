//
//  ListCardViewTableViewCell.swift
//  CatchMate
//
//  Created by 방유빈 on 6/14/24.
//

import UIKit
import PinLayout
import FlexLayout
import SwiftUI
import RxSwift
import RxCocoa

final class ListCardViewTableViewCell: UITableViewCell {
    var tapEvent: ControlEvent<Void> {
        return favoriteButton.rx.tap
    }
    var post: Post?
    var disposeBag = DisposeBag()
    
    private let cardContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.04
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 10
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let partyNumLabel: UILabel = DefaultsPaddingLabel(padding: UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8))

    private let postTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmNonImportantTextColor
        return label
    }()
    
    private var homeTeamImageView: TeamImageView = TeamImageView()
    private let vsLabel: UILabel = {
        let label = UILabel()
        label.text = "VS"
        label.applyStyle(textStyle: FontSystem.body03_medium)
        label.textColor = .cmNonImportantTextColor
        return label
    }()
    private var awayTeamImageView: TeamImageView = TeamImageView()
    let favoriteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "cmFavorite_filled")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        post = nil
        partyNumLabel.text = ""
        postTitleLabel.text = ""
        infoLabel.text = ""
        homeTeamImageView.imageView.image = nil
        awayTeamImageView.imageView.image = nil
        partyNumLabel.flex.markDirty()
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cardContainerView.pin.all().marginVertical(4)
        cardContainerView.flex.layout(mode: .adjustHeight)
        
        // shadowPath 설정
        cardContainerView.layer.shadowPath = UIBezierPath(roundedRect: cardContainerView.bounds, cornerRadius: cardContainerView.layer.cornerRadius).cgPath
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        cardContainerView.pin.width(size.width - MainGridSystem.getMargin() * 2) // 마진을 고려한 너비 설정
        cardContainerView.flex.layout(mode: .adjustHeight)
        
        // cardContainerView 높이에 위아래 마진을 더한 크기 반환
        let height = cardContainerView.frame.height + 8 // 4 + 4 (위아래 마진 합산)
        return CGSize(width: size.width, height: height)
    }
    
    
    func setupData(_ post: Post, isFavoriteCell: Bool = false) {
        self.post = post
        favoriteButton.isHidden = !isFavoriteCell
        favoriteButton.isEnabled = isFavoriteCell
        homeTeamImageView.setupTeam(team: post.homeTeam, isMyTeam: post.writer.team == post.homeTeam, background: .grayScale50)
        awayTeamImageView.setupTeam(team: post.awayTeam, isMyTeam: post.writer.team == post.awayTeam, background: .grayScale50)
        
        //info
        postTitleLabel.text = post.title
        postTitleLabel.textColor = .cmHeadLineTextColor
        infoLabel.text = "\(post.date) | \(post.playTime) | \(post.location)"
        infoLabel.textColor = .cmPrimaryColor
        if post.isFinished {
            partyNumLabel.text = "\(post.currentPerson)/\(post.maxPerson) 마감"
            partyNumLabel.textColor = .cmNonImportantTextColor
            partyNumLabel.backgroundColor = .grayScale100
        } else {
            partyNumLabel.text = "\(post.currentPerson)/\(post.maxPerson)"
            partyNumLabel.textColor = .cmPrimaryColor
            partyNumLabel.backgroundColor = .brandColor50
        }
        partyNumLabel.layer.cornerRadius = 10
        // Font
        partyNumLabel.applyStyle(textStyle: FontSystem.body03_semiBold)
        postTitleLabel.applyStyle(textStyle: FontSystem.bodyTitle)
        postTitleLabel.lineBreakMode = .byTruncatingTail
        infoLabel.applyStyle(textStyle: FontSystem.body02_medium)
        postTitleLabel.textAlignment = .center
    }
}

// MARK: - UI
extension ListCardViewTableViewCell {
    private func setUI() {
        let margin = MainGridSystem.getMargin()
        
        // cardContainerView를 contentView에 추가
        contentView.addSubview(cardContainerView)
        
        // cardContainerView 레이아웃 설정
        cardContainerView.flex.direction(.column).paddingVertical(20).paddingHorizontal(16).justifyContent(.start).alignItems(.center).marginHorizontal(margin).define { flex in
            flex.addItem(partyNumLabel).marginBottom(12)
            flex.addItem(infoLabel).marginBottom(4)
            flex.addItem(postTitleLabel).marginBottom(12).width(100%)
            flex.addItem().direction(.row).justifyContent(.center).width(100%).alignItems(.center).paddingVertical(16).define { flex in
                flex.addItem(homeTeamImageView).width(48).aspectRatio(1)
                flex.addItem(vsLabel).marginHorizontal(24)
                flex.addItem(awayTeamImageView).width(48).aspectRatio(1)
            }
        }
        cardContainerView.addSubview(favoriteButton)
        favoriteButton.flex.position(.absolute).top(20).right(20).size(20)
        cardContainerView.flex.layout(mode: .adjustHeight)
    }
}
