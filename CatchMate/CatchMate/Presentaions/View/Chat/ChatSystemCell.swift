//
//  ChatSystemCell.swift
//  CatchMate
//
//  Created by 방유빈 on 2/7/25.
//
import SnapKit
import UIKit
// MARK: - System Info Cell
final class StartChatInfoCell: UITableViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmNonImportantTextColor
        return label
    }()
    private let teamView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    private let teamStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 26
        return stackView
    }()
    private let homeTeamImageView: TeamImageView = {
        let imageview = TeamImageView()
        imageview.snp.makeConstraints { make in
            make.size.equalTo(50)
        }
        return imageview
    }()
    private let awayTeamImageView: TeamImageView = {
        let imageview = TeamImageView()
        imageview.snp.makeConstraints { make in
            make.size.equalTo(50)
        }
        return imageview
    }()
    private let vsLabel: UILabel = {
        let label = UILabel()
        label.text = "VS"
        label.textColor = .cmNonImportantTextColor
        label.applyStyle(textStyle: FontSystem.body03_medium)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(containerView)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        infoLabel.text = nil
    }
    
    func configData(_ post: SimplePost) {
        infoLabel.text = "\(post.date) | \(post.playTime) | \(post.location)"
        infoLabel.applyStyle(textStyle: FontSystem.body02_medium)
        homeTeamImageView.setupTeam(team: post.homeTeam, isMyTeam: post.cheerTeam == post.homeTeam)
        awayTeamImageView.setupTeam(team: post.awayTeam, isMyTeam: post.cheerTeam == post.awayTeam)
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubviews(views: [infoLabel, teamView])
        teamView.addSubview(teamStackView)
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(MainGridSystem.getMargin())
            // 임시 12 margin
            make.top.equalToSuperview().inset(12)
            make.bottom.equalToSuperview()
        }
        infoLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
        }
        teamView.snp.makeConstraints { make in
            make.top.equalTo(infoLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-12)
        }
        teamStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.center.equalToSuperview()
            make.height.equalTo(50)
        }
        [homeTeamImageView, vsLabel, awayTeamImageView].forEach { view in
            teamStackView.addArrangedSubview(view)
        }
    }
}

final class DateChatInfoCell: UITableViewCell {
    private let containerView = UIView()
    private var isStart: Bool = false
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmNonImportantTextColor
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configData(_ date: Date, _ isStart: Bool = false) {
        dateLabel.text = date.toString(format: "M월 d일")
        dateLabel.applyStyle(textStyle: FontSystem.body03_medium)
        if isStart {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.text = nil
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        let leftDivider = createDivider()
        let rightDivider = createDivider()
        containerView.addSubviews(views: [leftDivider, dateLabel, rightDivider])
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(MainGridSystem.getMargin())
            make.top.equalToSuperview().inset(isStart ? 16 : 12)
            make.bottom.equalToSuperview().inset(16)
        }
        leftDivider.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(leftDivider.snp.trailing).offset(12)
            make.top.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        rightDivider.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.leading.equalTo(dateLabel.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }
    
    private func createDivider() -> UIView {
        let view = UIView()
        view.backgroundColor = .cmStrokeColor
        return view
    }
}

final class EnterUserCell: UITableViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .grayScale600
        label.textAlignment = .center
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(containerView)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configData(_ nickName: String, type: String) {
        if type == ChatMessageType.enterUser.serverRequest {
            infoLabel.text = "\(nickName) 님이 채팅에 참여했어요"
        } else {
            infoLabel.text = "\(nickName) 님이 나갔어요"
        }
        infoLabel.applyStyle(textStyle: FontSystem.body03_medium)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        infoLabel.text = nil
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(infoLabel)
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(MainGridSystem.getMargin())
            make.top.equalToSuperview().inset(7)
            make.bottom.equalToSuperview().inset(20)
        }
        infoLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(10)
            make.width.lessThanOrEqualTo(containerView).offset(-24)
        }
    }
}
