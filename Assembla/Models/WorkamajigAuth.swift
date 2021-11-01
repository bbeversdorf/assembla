//
//  c.swift
//  Assembla
//
//  Created by Brian Beversdorf on 9/18/21.
//

import Foundation
import KeychainSwift
import CoreData

struct WorkamajigAuth {

    static private let key = "workamajig_auth"
    static let apiAccessToken = ""

    static func save(auth: String) throws {
        guard let data = auth.data(using: .utf8) else {
            throw WorkamajigError.invalidString
        }
        let keyChain = KeychainSwift()
        keyChain.set(data, forKey: Self.key)
    }


    static func getUserToken() -> String? {
        let keyChain = KeychainSwift()
        guard let data = keyChain.getData(Self.key) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}

enum WorkamajigError: Error {
    case invalidString
}
