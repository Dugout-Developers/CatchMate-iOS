//
//  Bundle+Extension.swift
//  CatchMate
//
//  Created by 방유빈 on 6/12/24.
//

import Foundation

extension Bundle {
    var baseURL: String? {
           guard let file = self.path(forResource: "APIKeys", ofType: "plist"),
                 let resource = NSDictionary(contentsOfFile: file),
                 let key = resource["BASE_URL"] as? String else {
               print("baseURL 얻기 실패")
               return nil
           }
           return key
       }
    var kakaoLoginKey: String? {
           guard let file = self.path(forResource: "APIKeys", ofType: "plist"),
                 let resource = NSDictionary(contentsOfFile: file),
                 let key = resource["KAKAO_LOGIN_API"] as? String else {
               print("Kakao API Key 얻기 실패")
               return nil
           }
           return key
       }
    
    var naverLoginClientID: String? {
           guard let file = self.path(forResource: "APIKeys", ofType: "plist"),
                 let resource = NSDictionary(contentsOfFile: file),
                 let key = resource["NAVER_LOGIN_API_ClientID"] as? String else {
               print("Kakao API Key 얻기 실패")
               return nil
           }
           return key
       }
    
    var naverLoginClientSecret: String? {
           guard let file = self.path(forResource: "APIKeys", ofType: "plist"),
                 let resource = NSDictionary(contentsOfFile: file),
                 let key = resource["NAVER_LOGIN_API_ClientSecret"] as? String else {
               print("Kakao API Key 얻기 실패")
               return nil
           }
           return key
       }
}
