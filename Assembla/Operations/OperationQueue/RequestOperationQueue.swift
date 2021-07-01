//
//  RequestOperationQueue.swift
//  Assembla
//
//  Created by Brian Beversdorf on 1/16/21.
//

import Foundation

class RequestOperationQueue: OperationQueue {
    override var name: String? {
        get {
            return "request operation queue"
        }
        set {}
    }

    static let shared = RequestOperationQueue()

    private override init() {
        super.init()
    }
}
