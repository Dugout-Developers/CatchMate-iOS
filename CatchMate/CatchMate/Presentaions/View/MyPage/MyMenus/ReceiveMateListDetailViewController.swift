//
//  ReceiveMateListDetailViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 8/11/24.
//

import UIKit
import SnapKit
import FlexLayout
import PinLayout
import ReactorKit

final class ReceiveMateListDetailViewController: BaseViewController, UICollectionViewDelegateFlowLayout, View {
    override var useSnapKit: Bool {
        return true
    }
    override var buttonContainerExists: Bool {
        return false
    }
    var collectionView: UICollectionView!
    var reactor: RecevieMateReactor
    init(reactor: RecevieMateReactor) {
        self.reactor = reactor
        super.init(nibName: nil, bundle: nil)
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind(reactor: reactor)
    }
    
    private func setupView() {
        view.backgroundColor = .opacity400
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tappedView))
        view.addGestureRecognizer(gesture)
        // 컬렉션 뷰 레이아웃 설정
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 9
        print(view.frame.height)
        layout.itemSize = CGSize(width: view.frame.width * 0.8, height: 400)

        // 컬렉션 뷰 설정
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast // 스냅 효과
        collectionView.isPagingEnabled = false
        collectionView.register(DetailCardCell.self, forCellWithReuseIdentifier: "DetailCardCell")
        view.addSubview(collectionView)

        // 레이아웃 제약조건 설정
        collectionView.backgroundColor = .clear
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(400)
        }
    }

    @objc func tappedView(_ sender: UIGestureRecognizer) {
        dismiss(animated: false)
    }
    func bind(reactor: RecevieMateReactor) {
        reactor.state.map { $0.selectedPostApplies }
            .compactMap{$0}
            .bind(to: collectionView.rx.items(cellIdentifier: "DetailCardCell", cellType: DetailCardCell.self)) { index, apply, cell in
                cell.configData(apply: apply)
                cell.primaryButton.rx.tap
                    .throttle(.seconds(3), latest: false, scheduler: MainScheduler.instance)
                    .map { Reactor.Action.acceptApply(apply.enrollId) }
                    .bind(to: reactor.action)
                    .disposed(by: cell.disposeBag)
                
                cell.commonButton.rx.tap
                    .throttle(.seconds(3), latest: false, scheduler: MainScheduler.instance)
                    .map { Reactor.Action.rejectApply(apply.enrollId) }
                    .bind(to: reactor.action)
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        reactor.state.map { $0.selectedPostApplies }
            .compactMap{$0}
            .withUnretained(self)
            .subscribe { vc, list in
                if list.isEmpty {
                    vc.dismiss(animated: false)
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.error}
            .compactMap{$0}
            .withUnretained(self)
            .subscribe { vc, error in
                vc.handleError(error)
            }
            .disposed(by: disposeBag)
    }
}

extension ReceiveMateListDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let inset: CGFloat = 32 // 첫 번째와 마지막 카드에 적용할 여백
        return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }

}


final class DetailCardCell: UICollectionViewCell {
    var disposeBag = DisposeBag()
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.layer.cornerRadius = 12
        return view
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
    private let teamLabel = DefaultsPaddingLabel()
    private let styleLabel = DefaultsPaddingLabel()
    private let genderLabel = DefaultsPaddingLabel()
    private let ageLabel = DefaultsPaddingLabel()
    
    private let applyDateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmNonImportantTextColor
        return label
    }()
    private let textView: CMTextView = {
        let textView = CMTextView()
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.isUserInteractionEnabled = true
        textView.showsVerticalScrollIndicator = true
        return textView
    }()
    let primaryButton: UIButton = {
        let button = UIButton()
        button.setTitle("수락", for: .normal)
        button.setTitleColor(.cmPrimaryColor, for: .normal)
        button.applyStyle(textStyle: FontSystem.body02_medium)
        button.backgroundColor = .white
        button.tintColor = .clear
        return button
    }()
    
    let commonButton: UIButton = {
        let button = UIButton()
        button.setTitle("거절", for: .normal)
        button.setTitleColor(.cmHeadLineTextColor, for: .normal)
        button.applyStyle(textStyle: FontSystem.body02_medium)
        button.backgroundColor = .white
        button.tintColor = .clear
        return button
    }()
    private let verticalDivider = UIView()
    
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
        applyDateLabel.text = DateHelper.shared.toString(from: apply.requestDate, format: "M월d일 HH:mm")
        applyDateLabel.applyStyle(textStyle: FontSystem.body02_medium)
        textView.text = apply.addText
        textView.applyStyle(textStyle: FontSystem.body02_medium)
        retryUI()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.pin.all()
        containerView.flex.layout(mode: .adjustHeight)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nicknameLabel.text = ""
        teamLabel.text = ""
        styleLabel.text = ""
        genderLabel.text = ""
        ageLabel.text = ""
        textView.text = ""
        profileImageView.image = nil
        styleLabel.flex.width(nil).height(nil)
        disposeBag = DisposeBag()
        retryUI()
    }
    
    private func retryUI() {
        nicknameLabel.flex.markDirty()
        teamLabel.flex.markDirty()
        styleLabel.flex.markDirty()
        genderLabel.flex.markDirty()
        ageLabel.flex.markDirty()
        textView.flex.markDirty()
        containerView.flex.layout()
    }
    
    private func setupUI(){
        contentView.addSubview(containerView)
        containerView.flex.direction(.column).justifyContent(.start).alignItems(.center).define { flex in
            flex.addItem().direction(.column).width(100%).paddingTop(36).paddingBottom(7).paddingHorizontal(24).justifyContent(.start).alignItems(.center).define { flex in
                flex.addItem().direction(.column).justifyContent(.start).alignItems(.center).define { flex in
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
                flex.addItem(applyDateLabel).marginVertical(16)
                flex.addItem(textView).width(100%).height(100)
            }
            flex.addItem().direction(.row).justifyContent(.start).alignItems(.center).width(100%).paddingTop(16).paddingBottom(24).define { flex in
                flex.addItem(commonButton).grow(1).shrink(0).basis(0%)
                flex.addItem(verticalDivider).width(1).height(18).backgroundColor(.grayScale100)
                flex.addItem(primaryButton).grow(1).shrink(0).basis(0%)
            }
        }
    }
    
    
}
