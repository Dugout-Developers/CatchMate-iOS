//
//  OpenSourceLibraryDetailViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 2/18/25.
//

import UIKit
import SnapKit

class OpenSourceLibraryDetailViewController: BaseViewController {
    private let library: OpenSourceLibrary
    override var useSnapKit: Bool {
        return true
    }
    override var buttonContainerExists: Bool {
        return false
    }
    init(library: OpenSourceLibrary) {
        self.library = library
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLeftTitle(library.name)

        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.isSelectable = true
        textView.dataDetectorTypes = .link
        textView.text = """
        📌 \(library.name) (v\(library.version))
        🔗 [원본 링크](\(library.url))
        
        \(library.licenseText)
        """
        textView.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.top.bottom.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.leading.trailing.equalToSuperview().inset(MainGridSystem.getMargin())
        }
    }
}
