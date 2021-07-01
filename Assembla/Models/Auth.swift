//
//  Auth.swift
//  Assembla
//
//  Created by Brian Beversdorf on 11/29/20.
//

import Foundation
import KeychainSwift
import CoreData

struct Auth: Upsertable {
    func upsert(childContext: NSManagedObjectContext) {
        return
    }

    static private let key = "auth"

    let tokenType: String
    let accessToken: String
    let expiresIn: TimeInterval
    let refreshToken: String
    let expirationDate: Date

    enum CodingKeys: String, CodingKey {
        case tokenType = "token_type"
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        tokenType = try container.decode(String.self, forKey: .tokenType)
        accessToken = try container.decode(String.self, forKey: .accessToken)
        expiresIn = TimeInterval(try container.decode(Int.self, forKey: .expiresIn))
        refreshToken = (try? container.decode(String.self, forKey: .refreshToken)) ?? Auth.getRefreshToken() ?? ""
        expirationDate = Date().addingTimeInterval(expiresIn)
    }

    init(refresh: String) {
        tokenType = "oauth"
        accessToken = "201"
        expiresIn = TimeInterval(20000)
        refreshToken = refresh
        expirationDate = Date().addingTimeInterval(expiresIn)
    }

    func save() throws {
        let data = try JSONEncoder().encode(self)
        let keyChain = KeychainSwift()
        keyChain.set(data, forKey: Self.key)
    }

    static func clear() {
        let keyChain = KeychainSwift()
        keyChain.clear()
    }

    static func getAccessToken() -> String? {
        guard let auth = getAuth() else {
            return nil
        }
        return auth.accessToken
    }

    static func getRefreshToken() -> String? {
        guard let auth = getAuth() else {
            return nil
        }
        return auth.refreshToken
    }

    private static func getAuth() -> Self? {
        let keyChain = KeychainSwift()
        guard let data = keyChain.getData(Self.key) else {
            return nil
        }
        return try? JSONDecoder().decode(Auth.self, from: data)
    }
}

