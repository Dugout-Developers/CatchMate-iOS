//
//  PhotoPermissionService.swift
//  CatchMate
//
//  Created by 방유빈 on 2/25/25.
//
import UIKit
import Photos

final class PhotoPermissionService {
    static let shared = PhotoPermissionService()
    
    
    /// 갤러리 접근 권한 확인 및 요청
    func checkPermission(from viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()

        switch status {
        case .authorized, .limited:
            print("✅ 갤러리 접근 허용됨")
            completion(true)
        case .denied, .restricted:
            print("❌ 갤러리 접근 거부됨")
            self.showPermissionAlert(viewController: viewController)
            completion(false)
        case .notDetermined:
            print("❓ 아직 사용자가 선택하지 않음")
            requestPermission(viewController: viewController, completion: completion)
        @unknown default:
            completion(false)
        }
    }
    
    /// 처음 권한 요청
    private func requestPermission(viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                if status == .authorized || status == .limited {
                    completion(true) // ✅ 권한 허용됨
                } else {
                    self.showPermissionAlert(viewController: viewController) // ❌ 거부됨 → 설정 이동 유도
                    completion(false)
                }
            }
        }
    }

    /// 설정으로 이동 유도 (권한 거부 시)
    private func showPermissionAlert(viewController: UIViewController) {
        viewController.showCMAlert(titleText: "앱에서 사진을 업로드하려면 갤러리 접근이 필요합니다.\n설정에서 권한을 허용해주세요.", importantButtonText: "확인", commonButtonText: "취소", importantAction:  {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        })
    }
}
