//
//  TeamPaddingLabel.swift
//  CatchMate
//
//  Created by 방유빈 on 7/15/24.
//

import UIKit


final class TeamPaddingLabel: DefaultsPaddingLabel {
    override init(frame: CGRect) {
            super.init(frame: frame)
            self.textColor = .white
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            self.textColor = .white
        }
        
        convenience init() {
            self.init(frame: .zero)
        }

    func setTeam(team: Team) {
        self.text = team.rawValue
        self.backgroundColor = team.getTeamColor
    }
}
