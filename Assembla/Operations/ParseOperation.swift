//
//  ParseOperation.swift
//  Assembla
//
//  Created by Brian Beversdorf on 1/16/21.
//

import Foundation
import CoreData

class ParseOperation<T: Upsertable>: Operation {

    let context: NSManagedObjectContext
    let childContext: NSManagedObjectContext
    let data: Data
    var error: Error?
    var decodedObjectIds: T.ObjectID?

    init(context: NSManagedObjectContext, data: Data) {
        self.context = context
        childContext = context.newChildContext()
        self.data = data
    }

    override func main() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601)
        childContext.performAndWait {
            if let key = CodingUserInfoKey.managedObjectContext {
                decoder.userInfo[key] = self.childContext
            }
            do {
                let decoded = try self.decode(decoder: decoder, data: self.data)
                self.decodedObjectIds = decoded?.upsert(childContext: self.childContext)
                try self.childContext.savePrivateContext()
            } catch let error {
                self.error = error
            }
        }
    }

    private func decode(decoder: JSONDecoder, data: Data?) throws -> T? {
        guard let data = data else {
            return nil
        }
        return try decoder.decode(T.self, from: data)
    }
}

protocol HasPrimaryKey: Upsertable, NSManagedObject, Identifiable where ObjectID == NSManagedObjectID {
    static var primaryKeyPath: String { get }
    var primaryKey: String { get }
}

extension HasPrimaryKey {

    var primaryKey: String {
        return String(describing: self[keyPath: \.id])
    }

    func upsert(childContext: NSManagedObjectContext) -> NSManagedObjectID {
        let decoded = self
        let fetchRequest = NSFetchRequest<Self>(entityName: String(describing: Self.self))
        fetchRequest.predicate = NSPredicate(format: "%K == %@", Self.primaryKeyPath, decoded.primaryKey)
        if let object = (try? childContext.fetch(fetchRequest).first) {
            object.update(updatedEntity: decoded)
            try? childContext.savePrivateContext()
            return object.objectID
        }
        childContext.parent?.performAndWait {
            childContext.parent?.insert(decoded)
        }
        return decoded.objectID
    }

}

protocol Upsertable: Codable {
    func upsert(childContext: NSManagedObjectContext) -> ObjectID
    associatedtype ObjectID
}

extension Array: Upsertable where Element: HasPrimaryKey {
    typealias ObjectID = [NSManagedObjectID]
    func upsert(childContext: NSManagedObjectContext) -> [NSManagedObjectID] {
        self.map { element in
            element.upsert(childContext: childContext)
        }
    }
}
