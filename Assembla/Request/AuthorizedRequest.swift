//
//  Request.swift
//  Assembla
//
//  Created by Brian Beversdorf on 9/18/21.
//

import Foundation
import CoreData

extension URLSession {
    static let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        return URLSession(configuration: config)
    }()
}

protocol AuthorizedRequest {
    static func addOAuth2(request: inout URLRequest)
    static func decode<T: Codable>(decoder: JSONDecoder, url: URL, data: Data?, response: URLResponse?, error: Error?, completion: @escaping (T?, Error?) -> Void)
}

extension AuthorizedRequest {
    static func authorizedRequest<T: Codable>(url: URL, method: String = "GET", context: NSManagedObjectContext? = nil, completion: @escaping (T?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = method
        Self.addOAuth2(request: &request)
        let task = URLSession.session.dataTask(with: request) { data, response, error in
            let decoder = JSONDecoder()
            if let key = CodingUserInfoKey.managedObjectContext, let context = context {
                decoder.userInfo[key] = context
            }
            decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601)
            if let context = context {
                context.perform {
                    decode(decoder: decoder, url: url, data: data, response: response, error: error, completion: completion)
                }
                return
            }
            decode(decoder: decoder, url: url, data: data, response: response, error: error, completion: completion)
        }

        task.resume()
    }
}

extension Formatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
}
extension URL {

    mutating func appendQueryItem(name: String, value: String?) {
        guard var urlComponents = URLComponents(string: absoluteString) else {
            return
        }
        // Create array of existing query items
        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []
        // Create query item
        let queryItem = URLQueryItem(name: name, value: value)
        // Append the new query item in the existing query items array
        queryItems.append(queryItem)
        // Append updated query items array in the url component object
        urlComponents.queryItems = queryItems
        // Returns the url from new url components
        self = urlComponents.url!
    }
}
