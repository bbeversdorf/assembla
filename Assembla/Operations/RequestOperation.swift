//
//  RequestOperation.swift
//  Assembla
//
//  Created by Brian Beversdorf on 1/16/21.
//

import Foundation
import CoreData

extension URLSession {
    static fileprivate let `default`: URLSession = {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        return URLSession(configuration: config)
    }()
}

class RequestOperation<T: Upsertable>: AsynchronousOperation {

    let url: URL
    let context: NSManagedObjectContext?
    let parse: Bool
    let method: String = "GET"
    var decodedObjectIds: T.ObjectID?

    required init(url: URL, context: NSManagedObjectContext? = nil, parse: Bool = true) {
        self.url = url
        self.context = context
        self.parse = parse
    }

    override func main() {
        var request = URLRequest(url: url)
        request.httpMethod = method
        addAuthentication(request: &request)
        let task = URLSession.default.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse, response.statusCode == 401 {
                self.cancel()
                self.reauthenticate()
                self.completeOperation()
                return
            }
            guard let data = data, error == nil, let context = self.context else {
                self.completeOperation(error: error)
                return
            }
            if self.parse {
                let parseOperation = ParseOperation<T>(context: context, data: data)
                parseOperation.completionBlock = {
                    defer {
                        parseOperation.completionBlock = nil
                    }
                    self.decodedObjectIds = parseOperation.decodedObjectIds
                    self.completeOperation()
                }
                ParseOperationQueue.shared.addOperation(parseOperation)
            } else {
                self.completeOperation()
            }
        }

        task.resume()
    }

    func addAuthentication(request: inout URLRequest) {
        guard let token = Auth.getAccessToken() else {
            return
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }

    private func reauthenticate() {
        let repeatOperation = Self.init(url: url, context: context)
        RequestOperationQueue.shared.isSuspended = true
        RequestOperationQueue.shared.operations.forEach {
            guard $0.isCancelled == false && $0.isExecuting == false else {
                return
            }
            guard $0.name != "AuthOperation" else {
                repeatOperation.addDependency($0)
                RequestOperationQueue.shared.addOperation(repeatOperation)
                return
            }
            $0.addDependency(repeatOperation)
        }
        if RequestOperationQueue.shared.operations.contains(where: { $0.name == "AuthOperation" }) == false,
           let authOperation = AuthOperation.getOAuthFromRefresh() {
            RequestOperationQueue.shared.operations.forEach {
                guard $0.isCancelled == false && $0.isExecuting == false else {
                    return
                }
                $0.addDependency(authOperation)
            }
            RequestOperationQueue.shared.addOperation(repeatOperation)
            RequestOperationQueue.shared.addOperation(authOperation)
        }
        RequestOperationQueue.shared.isSuspended = false
    }

}

/**
 Class for asynchrouns operation
 Must call `completeOperation(error: NSError?)` to finish
 */
class AsynchronousOperation: Operation {
    var executingOperation: Bool = false
    var finishedOperation: Bool = false
    var error: Error?

    override func start () {
        if isCancelled {
            // Move the operation to the finished state if it is canceled.
            willChangeValue(forKey: "isFinished")
            finishedOperation = true
            didChangeValue(forKey: "isFinished")
            return
        }

        // If the operation is not canceled, begin executing the task.
        willChangeValue(forKey: "isExecuting")
        Thread.detachNewThreadSelector(#selector(main), toTarget: self, with: nil)
        executingOperation = true
        didChangeValue(forKey: "isExecuting")
    }

    override func main() {
        super.main()
        if isCancelled {
            completeOperation()
            return
        }
    }

    override var isAsynchronous: Bool {
        return true
    }

    override var isExecuting: Bool {
        return executingOperation
    }

    override var isFinished: Bool {
        return finishedOperation
    }

    func completeOperation(error: Error? = nil) {
        willChangeValue(forKey: "isFinished")
        willChangeValue(forKey: "isExecuting")

        executingOperation = false
        finishedOperation = true
        self.error = error

        didChangeValue(forKey: "isExecuting")
        didChangeValue(forKey: "isFinished")
    }
}
