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

final class ListCardViewTableViewCell: UITableViewCell {
    private let cardContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.withAlphaComponent(0.04).cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 10
        return view
    }()
    
    private let topInfoContainer = UIView()
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "06.09 | 17:00 | 사직"
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .black
        return label
    }()
    
    private let titleContainer = UIView()
    private let partyNumLabel: PaddingLabel = {
        let label = PaddingLabel(padding: UIEdgeInsets(top: 3.0, left: 8.0, bottom: 3.0, right: 8.0))
        label.text = "3/4"
        label.textColor = .cmPrimaryColor
        label.backgroundColor = UIColor(hex: "#FFF2F2")
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        return label
    }()
    
    private let postTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "카리나 시구 보러 같이 가실 분"
        label.numberOfLines = 1
        label.adjustsFontForContentSizeCategory = true
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .cmTextGeay
        return label
    }()
    
    private let teamContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .cmBackgroundColor
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let teamInfoContainer = UIView()
    private let homeTeamContainer = UIView()
    private let homeTeamImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "giants_fill")
        return imageView
    }()
    private let homeTeamLabel: UILabel = {
        let label = UILabel()
        label.text = "자이언츠"
        label.textColor = .cmTextGeay
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        return label
    }()
    private let vsLabel: UILabel = {
        let label = UILabel()
        label.text = "VS"
        label.textColor = .cmTextGeay
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        return label
    }()
    
    private let awayTeamContainer = UIView()
    private let awayTeamImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "landers_fill")
        return imageView
    }()
    private let awayTeamLabel: UILabel = {
        let label = UILabel()
        label.text = "랜더스"
        label.textAlignment = .center
        label.textColor = .cmTextGeay
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
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
}

// MARK: - UI
extension ListCardViewTableViewCell {
    private func setUI() {
        addSubview(cardContainerView)
        
        cardContainerView.flex.direction(.column).justifyContent(.start).alignContent(.start).padding(16).marginHorizontal(18).marginBottom(8).define { flex in
            flex.addItem(infoLabel)
            flex.addItem(titleContainer).marginVertical(8).direction(.row).justifyContent(.start).define { flex in
                flex.addItem(partyNumLabel).marginRight(6)
                flex.addItem(postTitleLabel)
            }
            flex.addItem(teamContainer).direction(.column).justifyContent(.center).alignContent(.center).define { flex in
                flex.addItem(teamInfoContainer).direction(.row).justifyContent(.center).alignContent(.center).paddingVertical(12).define { flex in
                    flex.addItem(homeTeamContainer).direction(.column).justifyContent(.start).alignContent(.center).define { flex in
                        flex.addItem(homeTeamImageView)
                            .size(48)
                            .marginBottom(6)
                        flex.addItem(homeTeamLabel)
                    }
                    flex.addItem(vsLabel).marginHorizontal(24)
                    flex.addItem(awayTeamContainer).direction(.column).justifyContent(.start).alignContent(.center).define { flex in
                        flex.addItem(awayTeamImageView)
                            .size(48)
                            .marginBottom(6)
                        flex.addItem(awayTeamLabel)
                    }
                }
            }
        }
    }
}

