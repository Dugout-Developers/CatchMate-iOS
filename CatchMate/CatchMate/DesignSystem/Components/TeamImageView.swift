//
//  TeamImageView\.swift
//  CatchMate
//
//  Created by 방유빈 on 7/25/24.
//

import UIKit
import PinLayout
import FlexLayout

final class TeamImageView: UIView {
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
        imageView.image = isMyTeam ? team.getLogoImage : team.getLogoImage?.applyBlackAndWhiteFilter()
        containerView.backgroundColor = isMyTeam ? team.getTeamColor : .white
    }
    
    private func settupUI() {
        addSubview(containerView)
        containerView.flex.direction(.column).justifyContent(.center).alignItems(.center).cornerRadius(8).define { flex in
            flex.addItem(imageView).width(100%).aspectRatio(1)
        }
    }
    
    func setBacgroundColor(_ color: UIColor) {
        containerView.backgroundColor = color
    }
}
