//
//  SpaceTool.swift
//  Assembla
//
//  Created by Brian Beversdorf on 12/10/20.
//
//

import Foundation
import CoreData

class SpaceTool: NSManagedObject, HasPrimaryKey {
    static var primaryKeyPath: String {
        return "id"
    }
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case spaceId = "space_id"
        case active
        case toolId = "tool_id"
        case space = "space"
    }

    required convenience init(from decoder: Decoder) throws {
        guard let key = CodingUserInfoKey.managedObjectContext,
              let context = decoder.userInfo[key] as? NSManagedObjectContext,
              let entity = NSEntityDescription.entity(forEntityName: String(describing: Self.self), in: context) else {
            throw DecoderConfigurationError.missingManagedObjectContext
        }
        self.init(entity: entity, insertInto: nil)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        spaceId = try container.decode(String.self, forKey: .spaceId)
        active = try container.decode(Bool.self, forKey: .active)
        toolId = try container.decode(Int16.self, forKey: .toolId)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(spaceId, forKey: .spaceId)
        try container.encode(active, forKey: .active)
        try container.encode(toolId, forKey: .toolId)
        try container.encode(space, forKey: .space)
    }

    static func get(context: NSManagedObjectContext, spaceId: String) -> Operation? {
        guard let url = URL(string: "https://api.assembla.com/v1/spaces/\(spaceId)/space_tools/repo.json") else {
            return nil
        }
        let operation = RequestOperation<Self>(url: url, context: context)
        let childContext = context.newChildContext()
        operation.completionBlock = {
            defer {
                operation.completionBlock = nil
            }
            let fetchRequest = NSFetchRequest<Self>(entityName: "SpaceTool")
            fetchRequest.predicate = NSPredicate(format: "space = nil")
            let spaceFetchRequest = NSFetchRequest<Space>(entityName: "Space")
            spaceFetchRequest.predicate = NSPredicate(format: "id = %@", spaceId)
            guard let space = try? childContext.fetch(spaceFetchRequest).first,
                  let tools = (try? childContext.fetch(fetchRequest)),
                  tools.isEmpty == false else {
                return
            }
            tools.forEach { tool in
                tool.space = space
            }
        }
        return operation
    }
}
