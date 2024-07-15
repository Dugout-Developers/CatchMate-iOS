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
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let divider = UIView()
    
    private let infoContainer = UIView()
    private let partyNumLabel: UILabel  = UILabel()
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

    
    private let homeTeamImageView: ListTeamImageView = ListTeamImageView()
    private let awayTeamImageView: ListTeamImageView = ListTeamImageView()
   
    
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
        cardContainerView.pin.all()
        cardContainerView.flex.layout()
    }
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        cardContainerView.pin.width(size.width)
        cardContainerView.flex.layout(mode: .adjustHeight)
        return CGSize(width: size.width, height: cardContainerView.frame.height)
    }
    

    
    func setupData(_ post: Post, isFavoriteCell: Bool = false) {
        self.post = post
        favoriteButton.isHidden = !isFavoriteCell
        homeTeamImageView.setupTeam(team:  post.homeTeam, isMyTeam: post.writer.team == post.homeTeam)
        awayTeamImageView .setupTeam(team:  post.awayTeam, isMyTeam: post.writer.team == post.awayTeam)
        
        //info
        postTitleLabel.text = post.title
        infoLabel.text = "\(post.date) | \(post.playTime) | \(post.location)"
        if post.isFinished {
            partyNumLabel.text = "\(post.currentPerson)/\(post.maxPerson) 인원 마감"
            partyNumLabel.textColor = .cmNonImportantTextColor
            postTitleLabel.textColor = .cmNonImportantTextColor
        } else {
            partyNumLabel.text = "\(post.currentPerson)/\(post.maxPerson)"
            partyNumLabel.textColor = .cmPrimaryColor
            postTitleLabel.textColor = .cmHeadLineTextColor
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
        contentView.addSubview(cardContainerView)
        
        cardContainerView.flex.direction(.column).paddingTop(20).marginHorizontal(margin).define { flex in
            flex.addItem().direction(.row).width(100%).justifyContent(.start).alignItems(.start).define { flex in
                flex.addItem(homeTeamImageView).width(50).height(67).marginRight(4)
                flex.addItem(awayTeamImageView).width(50).height(67).marginRight(16)
                flex.addItem(infoContainer).direction(.column).justifyContent(.spaceBetween).alignItems(.start).height(67).define { flex in
                    flex.addItem().direction(.row).justifyContent(.spaceBetween).width(100%).alignItems(.center).define { flex in
                        flex.addItem(partyNumLabel)
                        flex.addItem(favoriteButton).width(20).aspectRatio(1)
                    }
                    flex.addItem(postTitleLabel).width(100%)
                    flex.addItem(infoLabel)
                }.grow(1).shrink(1)
            }.marginBottom(20)
            flex.addItem(divider).width(100%).height(1).backgroundColor(.grayScale50)

        }
    }
}


final class ListTeamImageView: UIView {
    private let containerView: UIView = UIView()
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    
    init() {
        super.init(frame: .zero)
        settupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.pin.all()
        containerView.flex.layout()
    }
    
    func setupTeam(team: Team, isMyTeam: Bool) {
        imageView.image = team.getLogoImage
        containerView.backgroundColor = isMyTeam ? team.getTeamColor : .grayScale50
    }
    
    private func settupUI() {
        addSubview(containerView)
        containerView.flex.direction(.column).justifyContent(.center).alignItems(.center).cornerRadius(8).define { flex in
            flex.addItem(imageView).width(100%).aspectRatio(1)
        }
    }
}
