//
//  EmptyView.swift
//  CatchMate
//
//  Created by 방유빈 on 1/26/25.
//
import UIKit
import SnapKit

enum EmptyViewType {
    case favorite
    case chat
    
    var title: String {
        switch self {
        case .favorite:
            return "찜한 게시물이 없어요"
        case .chat:
            return "참여한 채팅이 없어요"
        }
    }
    
    var subTitle: String {
        switch self {
        case .favorite:
            return "야구 팬들이 올린 다양한 글을 둘러보고\n마음에 드는 직관 글을 저장해보세요!"
        case .chat:
            return "마음에 드는 직관 글에 참여하여\n채팅을 시작해보세요!"
        }
    }
}
final class EmptyView: UIView {
    private let type: EmptyViewType
    private let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "favoriteNone"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmHeadLineTextColor
        return label
    }()
    private let subLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .cmNonImportantTextColor
        return label
    }()
    
    init(type: EmptyViewType) {
        self.type = type
        super.init(frame: .zero)
        setupView()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        titleLabel.text = type.title
        subLabel.text = type.subTitle
        titleLabel.applyStyle(textStyle: FontSystem.headline03_semiBold)
        subLabel.applyStyle(textStyle: FontSystem.contents)
        subLabel.textAlignment = .center
    }
    
    private func setupUI() {
        self.addSubviews(views: [imageView, titleLabel, subLabel])
        
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.size.equalTo(88)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(48)
            make.centerX.equalToSuperview()
        }
        subLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
