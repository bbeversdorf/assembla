//
//  WorkamajigOperation.swift
//  Assembla
//
//  Created by Brian Beversdorf on 9/18/21.
//

import Foundation

class WorkamajigOperation<T: Upsertable>: RequestOperation<T> {

    override func addAuthentication(request: inout URLRequest) {
        guard let token = WorkamajigAuth.getUserToken() else {
            return
        }
        request.setValue(WorkamajigAuth.apiAccessToken, forHTTPHeaderField: "APIAccessToken")
        request.setValue(token, forHTTPHeaderField: "UserToken")
    }
}
