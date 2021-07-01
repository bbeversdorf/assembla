//
//  AuthOperation.swift
//  Assembla
//
//  Created by Brian Beversdorf on 1/17/21.
//

import Foundation

class AuthOperation: RequestOperation<Auth> {
    // To register a new application, go to:
    // https://app.assembla.com/user/edit/manage_clients
    static let clientId = ""
    private static let clientSecret = ""

    override var name: String? {
        get {
            return "AuthOperation"
        }
        set {}
    }

    static func postPin(pin: String) -> AuthOperation? {
        guard let url = URL(string: "https://api.assembla.com/token?grant_type=pin_code&pin_code=\(pin)") else {
            return nil
        }
        return AuthOperation(url: url)
    }

    static func getOAuthFromRefresh() -> AuthOperation? {
        guard let refreshToken = Auth.getRefreshToken(), let url = URL(string: "https://api.assembla.com/token?grant_type=refresh_token&refresh_token=\(refreshToken)") else {
            Auth.clear()
            return nil
        }
        return AuthOperation(url: url)
    }

    override func main() {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        addBasicAuth(request: &request)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                self.completeOperation(error: error)
                return
            }
            guard error == nil else {
                Auth.clear()
                self.completeOperation(error: error)
                return
            }
            let auth: Auth
            do {
                auth = try JSONDecoder().decode(Auth.self, from: data)
            } catch let error {
                Auth.clear()
                self.completeOperation(error: error)
                return
            }

            do {
                try auth.save()
            } catch {
                Auth.clear()
            }
            self.completeOperation()
        }
        task.resume()
    }

    private func addBasicAuth(request: inout URLRequest) {
        let client = String(format: "%@:%@", Self.clientId, Self.clientSecret)
        guard let data = client.data(using: String.Encoding.utf8) else {
            return
        }
        let base64Client = data.base64EncodedString()
        request.setValue("Basic \(base64Client)", forHTTPHeaderField: "Authorization")
    }
}
