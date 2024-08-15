//
//  ChatSideSheetViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 8/13/24.
//

import UIKit
import PinLayout
import FlexLayout

final class ChatSideSheetViewController: BaseViewController {
    private let chat: Chat
    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = .opacity400
        return view
    }()
    private let containerView = UIView()
    private let infoView = UIView()
    private let topDivider = UIView()
    private let tableView = UITableView()
    private let bottomDivider = UIView()
    private let buttonView = UIView()
    private let titleLabel = UILabel()    
    private let indicatorImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "cm20right")?.withTintColor(.grayScale500, renderingMode: .alwaysOriginal)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let infoLabel = UILabel()
    private let partyNumLabel: UILabel = DefaultsPaddingLabel(padding: UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8))
    private let homeTeamImageView = TeamImageView()
    private let awayTeamImageView = TeamImageView()
    private let vsLabel: UILabel = {
        let label = UILabel()
        label.text = "VS"
        label.textColor = .cmNonImportantTextColor
        label.applyStyle(textStyle: FontSystem.body03_medium)
        return label
    }()
    private let exitButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "cm20leave")?.withTintColor(.grayScale500, renderingMode: .alwaysOriginal), for: .normal)
        return button
    }()
    private let notiButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "notification")?.withTintColor(.grayScale500, renderingMode: .alwaysOriginal), for: .normal)
        return button
    }()
    private let settingButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "setting")?.withTintColor(.grayScale500, renderingMode: .alwaysOriginal), for: .normal)
        return button
    }()
    private func setupStyle() {
        if let date = DateHelper.shared.toDate(from: chat.post.date, format: "MM.dd") {
            let string = DateHelper.shared.toString(from: date, format: "M월 d일 EEEE")
            infoLabel.text = "\(string) | \(chat.post.playTime) | \(chat.post.location)"
        } else {
            infoLabel.text = "0월 0일 요일 | \(chat.post.playTime) | \(chat.post.location)"
        }
        infoLabel.applyStyle(textStyle: FontSystem.body03_medium)
        infoLabel.textColor = .cmPrimaryColor
        partyNumLabel.text = "\(chat.post.currentPerson/chat.post.maxPerson)"
        partyNumLabel.textColor = .cmPrimaryColor
        partyNumLabel.backgroundColor = .brandColor50
        titleLabel.text = chat.post.title
        titleLabel.textColor = .cmHeadLineTextColor
        titleLabel.applyStyle(textStyle: FontSystem.body01_medium)
        homeTeamImageView.setupTeam(team: chat.post.homeTeam, isMyTeam: chat.post.writer.favGudan == chat.post.homeTeam)
        awayTeamImageView.setupTeam(team: chat.post.awayTeam, isMyTeam: chat.post.writer.favGudan == chat.post.awayTeam)
    }
    
    private func setupTableView() {
        
    }
    init(chat: Chat) {
        self.chat = chat
        super.init(nibName: nil, bundle: nil)
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        dimView.pin.all()
        containerView.pin.top(view.pin.safeArea).bottom().right().width(80%)
        infoView.pin.top().horizontally().height(135)
            .marginTop(24).marginHorizontal(20)
        tableView.pin.below(of: infoView).horizontally().above(of: buttonView)
        buttonView.pin
            .bottom(view.pin.safeArea)
            .horizontally()
            .height(52)
    }
    
    private func setupUI() {
        view.addSubview(dimView)
        view.addSubview(containerView)
        containerView.addSubviews(views: [infoView, tableView, buttonView])
    }
}
