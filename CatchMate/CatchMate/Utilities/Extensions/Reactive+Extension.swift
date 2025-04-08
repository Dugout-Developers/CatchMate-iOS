//
//  Reactive+Extension.swift
//  CatchMate
//
//  Created by 방유빈 on 4/8/25.
//

import RxCocoa
import RxSwift
import UIKit

extension Reactive where Base: UITextField {
    /// UITextView처럼 text를 안정적으로 감지하는 커스텀 observable
    var endEditing: Observable<String> {
        return controlEvent([.editingDidEnd, .editingDidEndOnExit])
            .map { [weak base] in base?.text ?? "" }
            .distinctUntilChanged()
    }
}
