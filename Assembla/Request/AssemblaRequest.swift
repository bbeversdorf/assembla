//
//  AssemblaRequest.swift
//  Assembla
//
//  Created by Brian Beversdorf on 11/29/20.
//

import Foundation
import CoreData
import UIKit

struct AssemblaRequest: AuthorizedRequest {

    internal static func addOAuth2(request: inout URLRequest) {
        guard let token = Auth.getAccessToken() else {
            return
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }

    private static func retrieveNewTokenAndRetryRequest<T: Codable>(url: URL, completion: @escaping (T?, Error?) -> Void) {
        guard let authOperation = AuthOperation.getOAuthFromRefresh() else {
            let error = AssemblaError(message: "missing refresh token")
            completion(nil, error)
            return
        }
        authOperation.completionBlock = {
            Self.authorizedRequest(url: url, completion: completion)
            authOperation.completionBlock = nil
        }
        RequestOperationQueue.shared.addOperation(authOperation)
    }

    internal static func decode<T: Codable>(decoder: JSONDecoder, url: URL, data: Data?, response: URLResponse?, error: Error?, completion: @escaping (T?, Error?) -> Void) {
        guard let data = data, error == nil, let decodedResponse = try? decoder.decode(T.self, from: data) else {
            if let response = response as? HTTPURLResponse, response.statusCode == 401 {
                retrieveNewTokenAndRetryRequest(url: url, completion: completion)
                return
            }
            completion(nil, error)
            return
        }
        sleep(2)
        completion(decodedResponse, nil)
    }
}

struct AssemblaError: Error {
    let message: String
}
