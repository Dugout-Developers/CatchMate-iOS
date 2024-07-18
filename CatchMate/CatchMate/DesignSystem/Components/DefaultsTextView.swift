//
//  DefaultsTextView.swift
//  CatchMate
//
//  Created by 방유빈 on 7/17/24.
//

import UIKit
import SnapKit

class DefaultsTextView: UITextView {
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grayScale400
        label.numberOfLines = 0
        return label
    }()

    var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
            placeholderLabel.applyStyle(textStyle: FontSystem.body02_semiBold)
            setNeedsLayout()
        }
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupView()
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupUI()
    }

    private func setupView() {
        layer.cornerRadius = 8
        
        textContainerInset = UIEdgeInsets(top: 18, left: 12, bottom: 18, right: 12)
        textColor = .cmHeadLineTextColor
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextView.textDidChangeNotification, object: self)
    }
    
    private func setupUI() {
        addSubview(placeholderLabel)
        
        placeholderLabel.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview().inset(16)
        }

    }
    
    @objc private func textDidChange() {
        placeholderLabel.isHidden = !text.isEmpty
        if let currentText = self.text {
            self.attributedText = NSAttributedString(string: currentText, attributes: FontSystem.body02_medium.getAttributes())
        }
    }
    // Remove observer
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // Layout subviews
    override func layoutSubviews() {
        super.layoutSubviews()
        placeholderLabel.isHidden = !text.isEmpty
    }
}
