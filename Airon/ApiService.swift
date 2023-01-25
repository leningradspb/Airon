//
//  ApiService.swift
//  Airon
//
//  Created by Eduard Kanevskii on 20.01.2023.
//

import Foundation

class APIService {
    
}


extension Dictionary {
    func percentEscaped() -> String {
        return map { (key, value) in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
            }
            .joined(separator: "&")
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@"
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}

extension URLRequest {
    mutating func configure(
        _ method: HttpMethod,
        _ parameters: [String: Any?]? = nil
    ) {
        self.addValue("Bearer \(AuthenticationService.shared.accessToken)",
            forHTTPHeaderField: "Authorization")
        self.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        self.httpMethod = method.rawValue
        if let strongParameters = parameters, !strongParameters.isEmpty {
            self.httpBody = try? JSONSerialization.data(withJSONObject: strongParameters)
        }
    }
}

class AuthenticationService {
    static let shared = AuthenticationService()
    
    var accessToken = "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"
}

enum HttpMethod: String {
    case post = "POST"
    case get = "GET"
    case put = "PUT"
}
