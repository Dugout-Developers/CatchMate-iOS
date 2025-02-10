//
//  ReceiveMateListCell.swift
//  CatchMate
//
//  Created by 방유빈 on 8/8/24.
//

import UIKit
import RxSwift
import FlexLayout
import PinLayout
import Kingfisher

final class ReceiveMateListCell: UITableViewCell {
    private var disposedBag = DisposeBag()
    private var appliesSubject = PublishSubject<[RecivedApplyData]>()
    private let containerView = UIView()
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmPrimaryColor
        return label
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmHeadLineTextColor
        label.numberOfLines = 1
        return label
    }()
    private let indicatorImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "cm20right")?.withTintColor(.grayScale500, renderingMode: .alwaysOriginal)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private var collectionView: UICollectionView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCollectionView()
        setupUI()
        backgroundColor = .clear
        collectionViewBind()
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        containerView.pin.width(size.width)
        containerView.flex.layout(mode: .adjustHeight)
        let height = containerView.frame.height
        return CGSize(width: size.width, height: height)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.pin.all()
        containerView.flex.layout(mode: .adjustHeight)
    }
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumLineSpacing = MainGridSystem.getGutter()
        layout.minimumInteritemSpacing = MainGridSystem.getGutter()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.register(ReceiveCollectionViewCell.self, forCellWithReuseIdentifier: "ReceiveCollectionViewCell")
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = ""
        infoLabel.text = ""
        titleLabel.flex.markDirty()
        infoLabel.flex.markDirty()
        containerView.flex.layout(mode: .adjustHeight)
    }
    
    func configData(apply: RecivedApplies) {
        let post = apply.post
        titleLabel.text = post.title
        titleLabel.applyStyle(textStyle: FontSystem.body01_medium)
        infoLabel.text = "\(post.date) | \(post.playTime) | \(post.location)"
        infoLabel.applyStyle(textStyle: FontSystem.body03_medium)
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.flex.markDirty()
        infoLabel.flex.markDirty()
        appliesSubject.onNext(apply.applies)
        containerView.flex.layout(mode: .adjustHeight)
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.flex.direction(.column).width(100%).paddingVertical(16).define { flex in
            flex.addItem().width(100%).direction(.row).paddingVertical(8).justifyContent(.start).alignItems(.center).define { flex in
                flex.addItem().grow(1).shrink(1).direction(.column).justifyContent(.start).alignItems(.start).define { flex in
                    flex.addItem(infoLabel).marginBottom(4)
                    flex.addItem(titleLabel)
                }
                flex.addItem(indicatorImageView).size(20).marginLeft(12)
            }.marginBottom(12)
            flex.addItem(collectionView).width(100%).minHeight(200)
        }
    }

        
    private func collectionViewBind() {
        appliesSubject.bind(to: collectionView.rx.items(cellIdentifier: "ReceiveCollectionViewCell", cellType: ReceiveCollectionViewCell.self)) { (row, apply, cell) in
            cell.configData(apply: apply)
        }
        .disposed(by: disposedBag)
    }
}
extension ReceiveMateListCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = MainGridSystem.getGridSystem(totalWidht: UIScreen.main.bounds.width, startIndex: 1, columnCount: 3).length
        return CGSize(width: cellWidth, height: collectionView.frame.height)
    }
}

final class ReceiveCollectionViewCell: UICollectionViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.layer.cornerRadius = 12
        return view
    }()
    private let newBedge: UILabel = {
        let label = UILabel()
        label.text = "N"
        label.applyStyle(textStyle: FontSystem.caption01_semiBold)
        label.textColor = .cmPrimaryColor
        return label
    }()
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmHeadLineTextColor
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    private let teamLabel = DefaultsPaddingLabel(padding: UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4))
    private let styleLabel = DefaultsPaddingLabel(padding: UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4))
    private let genderLabel = DefaultsPaddingLabel(padding: UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4))
    private let ageLabel = DefaultsPaddingLabel(padding: UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    func configData(apply: RecivedApplyData) {
        let user = apply.user
        if let urlString = user.picture, let url = URL(string: urlString) {
            profileImageView.kf.setImage(with: url)
        } else {
            profileImageView.image = UIImage(named: "defaultImg")
        }
        nicknameLabel.text = user.nickName
        nicknameLabel.applyStyle(textStyle: FontSystem.body02_medium)
        teamLabel.text = user.favGudan.rawValue
        teamLabel.applyStyle(textStyle: FontSystem.caption01_medium)
        teamLabel.backgroundColor = user.favGudan.getTeamColor
        teamLabel.textColor = .white
        if let style = user.cheerStyle {
            styleLabel.text = style.rawValue
            styleLabel.backgroundColor = .cmPrimaryColor
            styleLabel.applyStyle(textStyle: FontSystem.caption01_medium)
            styleLabel.textColor = .white
        } else {
            styleLabel.flex.width(0).height(0)
        }
        genderLabel.text = user.gender.rawValue
        genderLabel.backgroundColor = .grayScale100
        genderLabel.applyStyle(textStyle: FontSystem.caption01_medium)
        genderLabel.textColor = .cmNonImportantTextColor
        let ageDecade = (user.age / 10) * 10
        ageLabel.text = "\(ageDecade)대"
        ageLabel.backgroundColor = .grayScale100
        ageLabel.textColor = .cmNonImportantTextColor
        ageLabel.applyStyle(textStyle: FontSystem.caption01_medium)
        
        newBedge.isHidden = !apply.new
        retryUI()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.pin.all()
        newBedge.pin.topRight(12).height(15).width(8)
        containerView.flex.layout(mode: .adjustHeight)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nicknameLabel.text = ""
        teamLabel.text = ""
        styleLabel.text = ""
        genderLabel.text = ""
        ageLabel.text = ""
        profileImageView.image = nil
        newBedge.isHidden = true
        styleLabel.flex.width(nil).height(nil)
        retryUI()
    }
    
    private func retryUI() {
        nicknameLabel.flex.markDirty()
        teamLabel.flex.markDirty()
        styleLabel.flex.markDirty()
        genderLabel.flex.markDirty()
        ageLabel.flex.markDirty()
        newBedge.flex.markDirty()
        containerView.flex.layout(mode: .adjustHeight)
    }
    
    private func setupUI(){
        contentView.addSubview(containerView)
        contentView.addSubview(newBedge)
        containerView.flex.direction(.column).justifyContent(.start).alignItems(.center).paddingVertical(20).paddingHorizontal(27).define { flex in
            flex.addItem(profileImageView).size(56).cornerRadius(56/2).marginBottom(12)
            flex.addItem(nicknameLabel).marginBottom(8)
            flex.addItem().direction(.row).define { flex in
                flex.addItem(teamLabel).marginRight(4)
                flex.addItem(styleLabel)
            }.marginBottom(6)
            flex.addItem().direction(.row).define { flex in
                flex.addItem(genderLabel).marginRight(4)
                flex.addItem(ageLabel)
            }
        }
    }
}
