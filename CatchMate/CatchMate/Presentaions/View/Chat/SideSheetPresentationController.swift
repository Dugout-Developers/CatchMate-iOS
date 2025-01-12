//
//  SideSheetPresentationController.swift
//  CatchMate
//
//  Created by 방유빈 on 1/10/25.
//
import UIKit

class SideSheetPresentationController: UIPresentationController {
    private let dimmingView = UIView()
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        setupDimmingView()
    }

    private func setupDimmingView() {
        dimmingView.backgroundColor = .grayScale50
        dimmingView.alpha = 1
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissController))
        dimmingView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissController() {
        presentedViewController.dismiss(animated: true)
    }

    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }
        
        DispatchQueue.main.async {
            self.dimmingView.frame = containerView.bounds
            containerView.insertSubview(self.dimmingView, at: 0)
        }

        let sheetWidth = containerView.bounds.width * 0.7
        
        presentedView?.frame = CGRect(
            x: containerView.bounds.width,
            y: 0,
            width: sheetWidth,
            height: containerView.bounds.height
        )
        

        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let self = self else { return }
            self.presentedView?.frame = CGRect(
                x: containerView.bounds.width - sheetWidth,
                y: 0,
                width: sheetWidth,
                height: containerView.bounds.height
            )
        })
    }
    
    override func dismissalTransitionWillBegin() {
        guard let containerView = containerView else { return }
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
            let sheetWidth = containerView.bounds.width * 0.7
            self?.dimmingView.alpha = 0
            self?.presentedView?.frame = CGRect(
                x: containerView.bounds.width,
                y: 0,  // 상단에 고정
                width: sheetWidth,
                height: containerView.bounds.height  // 전체 높이
            )
        })
    }
    
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        guard let containerView = containerView else { return }

        let sheetWidth = containerView.bounds.width * 0.7

        // 프레임이 재설정되지 않도록 조건 추가
        if !presentedViewController.isBeingDismissed {
            presentedView?.frame = CGRect(
                x: containerView.bounds.width - sheetWidth,
                y: 0,
                width: sheetWidth,
                height: containerView.bounds.height
            )
        }
    }
}
class SideSheetTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return SideSheetPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
