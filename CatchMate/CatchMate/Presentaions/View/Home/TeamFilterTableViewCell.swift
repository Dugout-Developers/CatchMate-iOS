//
//  TeamFilterTableViewCell.swift
//  CatchMate
//
//  Created by 방유빈 on 6/16/24.
//

import UIKit
import RxSwift
import PinLayout
import FlexLayout

final class TeamFilterTableViewCell: UITableViewCell{
    var disposeBag = DisposeBag()

    var team: Team?
    var isClicked: Bool = false {
        didSet {
            checkTeam()
        }
    }
    var isUnable: Bool = false {
        didSet {
            checkUnable()
        }
    }
    private let containerView = UIView()
    private let teamImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let teamNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .cmHeadLineTextColor
        label.textAlignment = .left
        return label
    }()
    
    let checkButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "circle_default")?.withTintColor(.grayScale300, renderingMode: .alwaysOriginal), for: .normal)
        return button
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
        bind()
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
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        containerView.pin.width(size.width)
        containerView.flex.layout(mode: .adjustHeight)
        return CGSize(width: size.width, height: containerView.frame.height)
    }
    
    private func checkTeam() {
        if isClicked {
            teamImageView.image = team?.getFillImage
            checkButton.setImage(UIImage(named: "circle_check")?.withRenderingMode(.alwaysOriginal), for: .normal)
        } else {
            teamImageView.image = team?.getLogoImage
            checkButton.setImage(UIImage(named: "circle_default")?.withTintColor(.grayScale300, renderingMode: .alwaysOriginal), for: .normal)
        }
    }
    func checkUnable() {
        if isUnable {
            checkButton.isEnabled = false
            teamNameLabel.textColor = .cmNonImportantTextColor
            self.isClicked = false
        } else {
            checkButton.isEnabled = true
            teamNameLabel.textColor = .cmHeadLineTextColor
        }
    }
    
    func configure(with team: Team, isClicked: Bool, isUnable: Bool = false) {
        self.team = team
        self.isClicked = isClicked
        teamImageView.image = team.getLogoImage
        teamNameLabel.text = team.rawValue
        self.isUnable = isUnable
        teamNameLabel.applyStyle(textStyle: FontSystem.bodyTitle)
    }

    private func bind() {
        checkButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.isClicked.toggle()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UI
extension TeamFilterTableViewCell {
    private func setUI() {
        contentView.addSubview(containerView)
        
        containerView.flex.direction(.row).justifyContent(.spaceBetween).alignContent(.center).padding(10).define { flex in
            flex.addItem(teamImageView).size(50).backgroundColor(.grayScale50).cornerRadius(8)
            flex.addItem(teamNameLabel).marginHorizontal(16).grow(1)
            flex.addItem(checkButton).size(20).alignSelf(.center)
        }
    }
}


