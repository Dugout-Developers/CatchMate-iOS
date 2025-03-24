//
//  ApplicationInfoViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 2/10/25.
//
import UIKit
import SnapKit
import RxSwift
final class ApplicationInfoViewController: BaseViewController {
    enum ApplicationInfo: String, CaseIterable {
        case openSourceLibrary = "Open Source Library"
    }
    private let applicationInfos = ApplicationInfo.allCases
    
    private let appVersionView = UIView()
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo_white")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let appNameLabel: UILabel = {
        let label = UILabel()
        label.text = "CatchMate"
        label.textColor = .grayScale800
        label.applyStyle(textStyle: FontSystem.headline03_medium)
        return label
    }()
    private let versionLabel: UILabel = {
        let label = UILabel()
        label.text = "v.1.0.0"
        label.textColor = .grayScale500
        label.applyStyle(textStyle: FontSystem.body02_medium)
        return label
    }()
    
    private let openSourceLibraryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Open Source Library", for: .normal)
        button.setTitleColor(.grayScale400, for: .normal)
        let underlineAttribute: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        button.applyStyle(textStyle: FontSystem.body02_medium, anyAttr: underlineAttribute)
        button.backgroundColor = .clear
        return button
    }()

    
    override var useSnapKit: Bool {
        return true
    }
    override var buttonContainerExists: Bool {
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLeftTitle("정보")
        setupAppVersion()
        setupUI()
        bind()
    }
    
    private func setupAppVersion() {
        if let version = AppVersionService.shared.getCurrentAppVersion() {
            versionLabel.text = "v.\(version)"
            versionLabel.applyStyle(textStyle: FontSystem.body02_medium)
        }
    }
    private func setupUI() {
        view.backgroundColor = .cmGrayBackgroundColor
        appVersionView.backgroundColor = .cmBackgroundColor
        view.addSubview(appVersionView)
        view.addSubview(openSourceLibraryButton)
        appVersionView.addSubviews(views: [logoImageView, appNameLabel, versionLabel])
        
        appVersionView.snp.makeConstraints { make in
            make.leading.trailing.top.equalTo(view.safeAreaLayoutGuide)
        }
        logoImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.centerX.equalToSuperview()
            make.size.equalTo(88)
        }
        appNameLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        versionLabel.snp.makeConstraints { make in
            make.top.equalTo(appNameLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(20)
        }
        
        openSourceLibraryButton.snp.makeConstraints { make in
            make.top.equalTo(appVersionView.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
        }
    }
    private func bind() {
        openSourceLibraryButton.rx.tap
            .withUnretained(self)
            .subscribe { vc, _ in
                let openSourceListVC = OpenSourceListViewController()
                vc.navigationController?.pushViewController(openSourceListVC, animated: true)
            }
            .disposed(by: disposeBag)
    }
}
