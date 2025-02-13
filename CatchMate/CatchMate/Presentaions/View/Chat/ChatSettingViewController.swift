//
//  ChatSettingViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 2/12/25.
//

import UIKit
import RxSwift
import SnapKit
import ReactorKit

final class ChatSettingViewController: BaseViewController, View {
    let imgPicker = UIImagePickerController()
    override var useSnapKit: Bool {
        return true
    }
    override var buttonContainerExists: Bool {
        return false
    }
    var reactor: ChatRoomReactor
    private let changeImageView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    private let navBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    private let exitButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "cm20close")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .grayScale700
        return button
    }()
    private let navTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "채팅방 설정"
        label.textColor = .grayScale800
        label.applyStyle(textStyle: FontSystem.headline03_medium)
        return label
    }()
    private let profileImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "profile"))
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 34
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    private let imageEditButton: ProfileImageEditButton = {
        let button = ProfileImageEditButton()
        button.layer.cornerRadius = 34
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imgPicker.delegate = self
        view.backgroundColor = .grayScale50
        navigationBarHidden()
        setupUI()
        bind(reactor: reactor)
    }
    
    init(reactor: ChatRoomReactor) {
        self.reactor = reactor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension ChatSettingViewController {
    private func openLibrary(){
        imgPicker.sourceType = .photoLibrary
        present(imgPicker, animated: false, completion: nil)
    }
    // MARK: - Bind
    func bind(reactor: ChatRoomReactor) {
        reactor.state.map{$0.image}
            .withUnretained(self)
            .subscribe { vc, image in
                vc.profileImageView.image = image
            }
            .disposed(by: disposeBag)
        exitButton.rx.tap
            .withUnretained(self)
            .subscribe { vc, _ in
                vc.dismiss(animated: false)
            }
            .disposed(by: disposeBag)
        imageEditButton.rx.tap
            .withUnretained(self)
            .subscribe { vc, _ in
                vc.openLibrary()
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - UI
    private func setupUI() {
        view.addSubviews(views: [navBarView, changeImageView])
        navBarView.addSubviews(views: [exitButton, navTitleLabel])
        changeImageView.addSubviews(views: [profileImageView, imageEditButton])
        navBarView.snp.makeConstraints { make in
            make.leading.trailing.top.equalTo(view.safeAreaLayoutGuide)
        }
        exitButton.snp.makeConstraints { make in
            make.size.equalTo(20)
            make.leading.equalToSuperview().offset(18)
            make.centerY.equalToSuperview()
        }
        navTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(exitButton.snp.trailing).offset(12)
            make.top.bottom.equalToSuperview().inset(9)
        }
        changeImageView.snp.makeConstraints { make in
            make.top.equalTo(navBarView.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        profileImageView.snp.makeConstraints { make in
            make.size.equalTo(68)
            make.center.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(16)
        }
        imageEditButton.snp.makeConstraints { make in
            make.edges.equalTo(profileImageView)
        }
    }
}

// MARK: - ImagePicker
extension ChatSettingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            if let validImage = UIImage(data: image.jpegData(compressionQuality: 0.5)!) {
                reactor.action.onNext(.changeImage(validImage))
            } else {
                print("이미지가 유효하지 않습니다.")
            }
        }
        dismiss(animated: true, completion: nil)
    }
}
