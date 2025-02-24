//
//  CMSwitch.swift
//  CatchMate
//
//  Created by 방유빈 on 8/22/24.
//

import UIKit
import RxSwift
import RxCocoa

class CMSwitch: UIControl {
    let disposeBag = DisposeBag()
    private var previousOffset: CGFloat?
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.brandColor50
        view.layer.cornerRadius = 17
        return view
    }()
    
    private let thumbView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 14
        return view
    }()
    
    private var thumbLeadingConstraint: NSLayoutConstraint!
    
    private(set) var isOn: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupGestures()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupGestures()
    }
    
    private func setupView() {
        addSubview(backgroundView)
        addSubview(thumbView)
        
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        thumbView.translatesAutoresizingMaskIntoConstraints = false
        
        // Background view constraints
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Thumb view constraints
        thumbLeadingConstraint = thumbView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 3)
        NSLayoutConstraint.activate([
            thumbLeadingConstraint,
            thumbView.centerYAnchor.constraint(equalTo: centerYAnchor),
            thumbView.widthAnchor.constraint(equalToConstant: 28),
            thumbView.heightAnchor.constraint(equalToConstant: 28)
        ])
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func didTap() {
//        isOn.toggle()
        sendActions(for: .valueChanged)
//        updateUI(animated: true)
    }
    
    private func updateUI(animated: Bool) {
        let offset = isOn ? bounds.width - 31 : 3
        
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.thumbLeadingConstraint.constant = offset
                self.backgroundView.backgroundColor = self.isOn ? UIColor.cmPrimaryColor : UIColor.brandColor50
                self.layoutIfNeeded()
            }
        } else {
            self.thumbLeadingConstraint.constant = offset
            self.backgroundView.backgroundColor = self.isOn ? UIColor.cmPrimaryColor : UIColor.brandColor50
            self.layoutIfNeeded()
        }
    }
    
    func setOn(_ on: Bool, animated: Bool) {
        guard isOn != on else { return }
        self.isOn = on
        print(animated)
        updateUI(animated: animated)
    }
    
    func rx_isOn() -> ControlProperty<Bool> {
        return ControlProperty<Bool>(
            values: self.rx.controlEvent(.valueChanged)
                .map { self.isOn },
            valueSink: Binder(self) { control, value in
                control.setOn(value, animated: false)
            }
        )
    }
}
