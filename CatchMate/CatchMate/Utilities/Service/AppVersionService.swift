//
//  AppVersionService.swift
//  CatchMate
//
//  Created by 방유빈 on 2/25/25.
//
import Foundation

final class AppVersionService {
    static let shared = AppVersionService()
    func fetchLatestVersion(completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "https://itunes.apple.com/lookup?bundleId=com.tori.CatchMate") else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let results = json["results"] as? [[String: Any]],
                   let latestVersion = results.first?["version"] as? String {
                    completion(latestVersion)
                } else {
                    completion(nil)
                }
            } catch {
                completion(nil)
            }
        }.resume()
    }
    
    func getCurrentAppVersion() -> String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
}
