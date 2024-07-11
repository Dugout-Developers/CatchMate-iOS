//
//  TeamFilterCollectionViewCell.swift
//  CatchMate
//
//  Created by 방유빈 on 6/18/24.
//

import UIKit
import SnapKit

final class TeamFilterCollectionViewCell: UICollectionViewCell {
    private var team: Team?
    private var isSelect: Bool = false
    private let teamLogoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .grayScale50
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor.cmPrimaryColor.cgColor
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(clickImage))
        addGestureRecognizer(tapGesture)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupData(team: Team) {
        self.team = team
        teamLogoImage.image = team.getLogoImage
    }
    @objc
    private func clickImage() {
        isSelect.toggle()
        if isSelect {
            teamLogoImage.layer.borderWidth = 1
        } else {
            teamLogoImage.layer.borderWidth = 0
        }
    }
    
    private func setupUI() {
        addSubview(teamLogoImage)
        
        teamLogoImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
