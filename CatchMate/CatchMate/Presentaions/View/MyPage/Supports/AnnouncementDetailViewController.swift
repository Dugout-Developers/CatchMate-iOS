//
//  AnnouncementDetailViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 8/8/24.
//

import UIKit
import FlexLayout
import PinLayout

final class AnnouncementDetailViewController: BaseViewController {
    override var useSnapKit: Bool {
        return false
    }
    override var buttonContainerExists: Bool {
        return false
    }
    
    private let announcement: Announcement
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .cmHeadLineTextColor
        return label
    }()
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmNonImportantTextColor
        return label
    }()
    private let contentsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .cmHeadLineTextColor
        return label
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLeftTitle("공지사항")
        setupUI()
    }
    
    init(announcement: Announcement) {
        self.announcement = announcement
        super.init(nibName: nil, bundle: nil)
        setupData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.pin.all(view.pin.safeArea)
        contentView.pin.top().left().right()
        
        contentView.flex.layout(mode: .adjustHeight)
        scrollView.contentSize = contentView.frame.size
    }
    
    private func setupData() {
        titleLabel.text = announcement.title
        infoLabel.text = announcement.writeDate
        contentsLabel.text = announcement.contents
        
        titleLabel.applyStyle(textStyle: FontSystem.headline03_medium)
        infoLabel.applyStyle(textStyle: FontSystem.body02_medium)
        contentsLabel.applyStyle(textStyle: FontSystem.body02_medium)
    }
    
    private func setupUI() {
        view.backgroundColor = .grayScale50
        scrollView.backgroundColor = .clear
        contentView.backgroundColor = .clear
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.flex.direction(.column).justifyContent(.start).alignItems(.start).define { flex in
            flex.addItem().width(100%).backgroundColor(.white).paddingHorizontal(MainGridSystem.getMargin()).paddingVertical(12).justifyContent(.start).alignItems(.start).define { flex in
                flex.addItem(titleLabel).marginBottom(16)
                flex.addItem(infoLabel)
            }.marginBottom(8)
            flex.addItem().width(100%).backgroundColor(.white).paddingHorizontal(MainGridSystem.getMargin()).paddingVertical(12).justifyContent(.start).alignItems(.start).define { flex in
                flex.addItem(contentsLabel)
            }
        }
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
