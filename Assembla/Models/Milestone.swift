//
//  Milestone+CoreDataClass.swift
//  Assembla
//
//  Created by Brian Beversdorf on 12/8/20.
//
//

import Foundation
import CoreData
import UIKit

class Milestone: NSManagedObject, Codable, HasPrimaryKey {
    static var primaryKeyPath: String {
        return "id"
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
    }

    required convenience init(from decoder: Decoder) throws {
        guard let key = CodingUserInfoKey.managedObjectContext,
              let context = decoder.userInfo[key] as? NSManagedObjectContext,
              let entity = NSEntityDescription.entity(forEntityName: String(describing: Self.self), in: context) else {
            throw DecoderConfigurationError.missingManagedObjectContext
        }
        self.init(entity: entity, insertInto: nil)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int64.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
    }

    private static func get(context: NSManagedObjectContext, spaceId: String, milestoneId: Int) -> Operation? {
        guard let url = URL(string: "https://api.assembla.com/v1/spaces/\(spaceId)/milestones/\(milestoneId).json") else {
            return nil
        }
        let operation = RequestOperation<Milestone>(url: url, context: context)
        operation.completionBlock = {
            defer {
                operation.completionBlock = nil
            }
            let fetchRequest = NSFetchRequest<Ticket>(entityName: "Ticket")
            fetchRequest.predicate = NSPredicate(format: "milestoneId = %i", milestoneId)
            let milestoneFetchRequest = NSFetchRequest<Milestone>(entityName: "Milestone")
            milestoneFetchRequest.predicate = NSPredicate(format: "id = %i", milestoneId)
            context.performAndWait {
                let milestone = (try? context.fetch(milestoneFetchRequest))?.first
                let tickets = try? context.fetch(fetchRequest)
                tickets?.forEach { $0.milestone = milestone }
                try? context.save()
            }
        }
        return operation
    }

    static func getAll(context: NSManagedObjectContext) -> [Operation] {
        let ticketsFetchRequest = NSFetchRequest<Ticket>(entityName: "Ticket")
        let tickets = try? context.fetch(ticketsFetchRequest)
        let spaceStones = tickets?.reduce([Int: String]()) { (result, ticket) -> [Int: String]? in
            var results = result
            results?[ticket.milestoneId] = ticket.spaceId ?? "-1"
            return results
        }
        var operations: [Operation] = []
        spaceStones?.keys.forEach { spaceStoneKey in
            let spaceStoneValue = spaceStones?[spaceStoneKey] ?? "No results"
            guard let operation = Self.get(context: context, spaceId: spaceStoneValue, milestoneId: spaceStoneKey) else {
                return
            }
            operations.append(operation)
        }
        return operations
    }
}
