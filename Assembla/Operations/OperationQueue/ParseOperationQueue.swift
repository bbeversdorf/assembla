//
//  ParseOperationQueue.swift
//  Assembla
//
//  Created by Brian Beversdorf on 1/16/21.
//

import Foundation

class ParseOperationQueue: OperationQueue {
    override var maxConcurrentOperationCount: Int {
        get {
            return 1
        }
        set {}
    }

    static let shared = ParseOperationQueue()

    private override init() {
        super.init()
    }
}
