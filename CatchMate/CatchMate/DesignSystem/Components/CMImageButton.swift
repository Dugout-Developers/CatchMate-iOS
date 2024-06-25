//
//  CMImageButton.swift
//  CatchMate
//
//  Created by 방유빈 on 6/23/24.
//

import UIKit

final class CMImageButton: UIButton {
    
    init(frame: CGRect, image: UIImage?) {
        super.init(frame: frame)
        setupButton(with: image)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupButton(with image: UIImage?) {
        setImage(image, for: .normal)
        imageView?.contentMode = .scaleAspectFill
        setTitle(nil, for: .normal)
        setAttributedTitle(nil, for: .normal)
        contentVerticalAlignment = .fill
        contentHorizontalAlignment = .fill
    }
}
