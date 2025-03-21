//
//  Bundle+Extension.swift
//  CatchMate
//
//  Created by 방유빈 on 6/12/24.
//

import Foundation

extension Bundle {
    var logPath: String? {
        guard let file = self.path(forResource: "APIKeys", ofType: "plist"),
              let resource = NSDictionary(contentsOfFile: file),
              let key = resource["LOG_PATH"] as? String else {
            LoggerService.shared.log("logPath 얻기 실패")
            return nil
        }
        return key
    }
    var baseURL: String? {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String else {
            return nil
        }
        print("base_Url: \(key)")
        return key
    }
    var socketURL: String? {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "SOCKET_URL") as? String else {
            return nil
        }
        print("socketURL: \(key)")
        return key
    }
    var kakaoLoginAPPKey: String? {
           guard let file = self.path(forResource: "APIKeys", ofType: "plist"),
                 let resource = NSDictionary(contentsOfFile: file),
                 let key = resource["KAKAO_LOGIN_API"] as? String else {
               LoggerService.shared.log("Kakao Login App Key 얻기 실패")
               return nil
           }
           return key
       }
    var kakaoLoginRESTKey: String? {
           guard let file = self.path(forResource: "APIKeys", ofType: "plist"),
                 let resource = NSDictionary(contentsOfFile: file),
                 let key = resource["KAKAO_LOGIN_REST_API"] as? String else {
               LoggerService.shared.log("Kakao Login REST Key 실패")
               return nil
           }
           return key
       }
    var naverUrlScheme: String? {
           guard let file = self.path(forResource: "APIKeys", ofType: "plist"),
                 let resource = NSDictionary(contentsOfFile: file),
                 let key = resource["NAVER_URL_SCHEME"] as? String else {
               LoggerService.shared.log("naver UrlScheme 얻기 실패")
               return nil
           }
           return key
       }
    var naverLoginClientID: String? {
           guard let file = self.path(forResource: "APIKeys", ofType: "plist"),
                 let resource = NSDictionary(contentsOfFile: file),
                 let key = resource["NAVER_LOGIN_API_ClientID"] as? String else {
               LoggerService.shared.log("naver Login ID 얻기 실패")
               return nil
           }
           return key
       }
    
    var naverLoginClientSecret: String? {
           guard let file = self.path(forResource: "APIKeys", ofType: "plist"),
                 let resource = NSDictionary(contentsOfFile: file),
                 let key = resource["NAVER_LOGIN_API_ClientSecret"] as? String else {
               LoggerService.shared.log("Naver Login Key 얻기 실패")
               return nil
           }
           return key
       }
}
