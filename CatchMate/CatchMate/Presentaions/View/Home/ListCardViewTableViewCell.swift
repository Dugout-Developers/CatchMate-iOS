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
    var post: Post?
    var tapEvent: ControlEvent<Void> {
        return favoriteButton.rx.tap
    }
    var disposeBag = DisposeBag()
    
    private let cardContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.04
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 10
        view.layer.cornerRadius = 8
        // view.clipsToBounds = true // 이 부분은 shadowPath 설정 시 제거해야 합니다.
        return view
    }()
    
    private let partyNumLabel: UILabel  = DefaultsPaddingLabel(padding: UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8))
    let favoriteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "cmFavorite_filled")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
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
    
    private let homeTeamImageView: TeamImageView = TeamImageView()
    private let vsLabel: UILabel = {
        let label = UILabel()
        label.text = "VS"
        label.applyStyle(textStyle: FontSystem.body03_medium)
        label.textColor = .cmNonImportantTextColor
        return label
    }()
    private let awayTeamImageView: TeamImageView = TeamImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
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
        cardContainerView.pin.width(size.width)
        cardContainerView.flex.layout(mode: .adjustHeight)
        return CGSize(width: size.width, height: cardContainerView.frame.height + 8)
    }
    
    func setupData(_ post: Post, isFavoriteCell: Bool = false) {
        self.post = post
        favoriteButton.isHidden = !isFavoriteCell
        homeTeamImageView.setupTeam(team:  post.homeTeam, isMyTeam: post.writer.team == post.homeTeam)
        awayTeamImageView.setupTeam(team:  post.awayTeam, isMyTeam: post.writer.team == post.awayTeam)
        
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
        
        // Font
        partyNumLabel.applyStyle(textStyle: FontSystem.body03_semiBold)
        postTitleLabel.applyStyle(textStyle: FontSystem.bodyTitle)
        postTitleLabel.lineBreakMode = .byTruncatingTail
        infoLabel.applyStyle(textStyle: FontSystem.body02_medium)
    }
}

// MARK: - UI
extension ListCardViewTableViewCell {
    private func setUI() {
        let margin = MainGridSystem.getMargin()
        
        // cardContainerView를 contentView에 추가
        contentView.addSubview(cardContainerView)
        
        // cardContainerView 레이아웃 설정
        cardContainerView.flex.direction(.column).padding(16).marginHorizontal(margin).define { flex in
            flex.addItem().direction(.column).width(100%).justifyContent(.start).alignItems(.start).define { flex in
                flex.addItem(infoLabel).marginBottom(4)
                flex.addItem().width(100%).direction(.row).justifyContent(.start).alignItems(.center).define { flex in
                    flex.addItem(partyNumLabel).marginRight(6)
                    flex.addItem(postTitleLabel).grow(1).shrink(1)
                }
            }.marginBottom(12)
            flex.addItem().direction(.row).justifyContent(.center).alignItems(.center).backgroundColor(.grayScale50).cornerRadius(8).paddingVertical(16).define { flex in
                flex.addItem(homeTeamImageView).width(48).aspectRatio(1)
                flex.addItem(vsLabel).marginHorizontal(24)
                flex.addItem(awayTeamImageView).width(48).aspectRatio(1)
            }
        }
        
        // 레이아웃 적용
        cardContainerView.flex.layout(mode: .adjustHeight)
    }
}
