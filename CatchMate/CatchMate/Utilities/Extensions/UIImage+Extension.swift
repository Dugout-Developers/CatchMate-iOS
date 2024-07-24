//
//  UIImage+Extension.swift
//  CatchMate
//
//  Created by 방유빈 on 6/14/24.
//

import UIKit

extension UIImage {
    /// 이미지 비율에 맞춰서 가로 세로 높이 구하기
    func getRatio(height: CGFloat = 0, width: CGFloat = 0) -> CGFloat {
        let widthRatio = CGFloat(self.size.width / self.size.height)
        let heightRatio = CGFloat(self.size.height / self.size.width)
        
        if height != 0 {
            return height / heightRatio
        }
        if width != 0 {
            return width / widthRatio
        }
        return 0
    }
    
    /// 흑백 필터 적용
    func applyBlackAndWhiteFilter() -> UIImage? {
        guard let ciImage = CIImage(image: self) else { return nil }
        
        // CIFilter로 흑백 필터 생성
        guard let filter = CIFilter(name: "CIPhotoEffectMono") else { return nil }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        
        // 필터 결과 이미지 생성
        guard let outputImage = filter.outputImage else { return nil }
        
        // CIContext를 사용하여 UIImage로 변환
        let context = CIContext()
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }

}
