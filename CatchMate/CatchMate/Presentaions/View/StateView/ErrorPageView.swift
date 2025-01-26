//
//  ErrorPageView.swift
//  CatchMate
//
//  Created by 방유빈 on 9/24/24.
//

import UIKit
import SnapKit
import FlexLayout
import PinLayout

final class ErrorPageView: UIView {
    private let containerView = UIView()
    private let contentView = UIView()
    private let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Eyes"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "문제가 발생했어요\n다시 한 번 시도해주세요"
        label.textColor = .cmHeadLineTextColor
        label.applyStyle(textStyle: FontSystem.headline03_semiBold)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private var useSnapKit: Bool = true
    
    // 초기화 시점에 레이아웃 방식을 선택할 수 있게 함
    init(useSnapKit: Bool) {
        self.useSnapKit = useSnapKit
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupView() {
        addSubview(containerView)
        containerView.addSubview(contentView)
        contentView.addSubviews(views: [imageView, titleLabel])
        containerView.backgroundColor = .white
        if useSnapKit {
            setupSnapKitLayout()
        } else {
            setupFlexLayout()
        }
    }
    // SnapKit으로 레이아웃 설정
    private func setupSnapKitLayout() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        imageView.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.size.equalTo(82)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(34)
            make.center.equalToSuperview()
        }

    }
    
    // FlexLayout으로 레이아웃 설정
    private func setupFlexLayout() {
        containerView.flex.direction(.column).width(100%).height(100%).justifyContent(.center).alignItems(.center).define { flex in
            flex.addItem(contentView).direction(.column).justifyContent(.center).alignItems(.center).define { flex in
                flex.addItem(imageView).size(82).marginBottom(24)
                flex.addItem(titleLabel)
            }.marginBottom(82+24)
        }

        
        // FlexLayout의 레이아웃을 업데이트하는 부분
        containerView.flex.layout()
    }
}
