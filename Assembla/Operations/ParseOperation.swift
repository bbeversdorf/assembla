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

    init(context: NSManagedObjectContext, data: Data) {
        self.context = context
        childContext = context.newChildContext()
        self.data = data
    }

    override func main() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601)
        childContext.perform {
            if let key = CodingUserInfoKey.managedObjectContext {
                decoder.userInfo[key] = self.childContext
            }
            do {
                let decoded = try self.decode(decoder: decoder, data: self.data)
                decoded?.upsert(childContext: self.childContext)
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

protocol HasPrimaryKey: Upsertable, NSManagedObject, Identifiable {
    var primaryKey: String { get }
}

extension HasPrimaryKey {
    var primaryKey: String {
        return String(describing: self[keyPath: \.id])
    }

    func upsert(childContext: NSManagedObjectContext) {
        let decoded = self
        let fetchRequest = NSFetchRequest<Self>(entityName: String(describing: Self.self))
        fetchRequest.predicate = NSPredicate(format: "%K == %@", "id", decoded.primaryKey)
        if let object = (try? childContext.fetch(fetchRequest).first) {
            object.update(updatedEntity: decoded)
            try? childContext.savePrivateContext()
            return
        }
        childContext.parent?.performAndWait {
            childContext.parent?.insert(decoded)
        }
    }

}

protocol Upsertable: Codable {
    func upsert(childContext: NSManagedObjectContext)
}

extension Array: Upsertable where Element: HasPrimaryKey {
    func upsert(childContext: NSManagedObjectContext) {
        self.forEach { element in
            element.upsert(childContext: childContext)
        }
    }
}
