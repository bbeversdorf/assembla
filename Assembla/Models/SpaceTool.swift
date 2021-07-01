//
//  SpaceTool.swift
//  Assembla
//
//  Created by Brian Beversdorf on 12/10/20.
//
//

import Foundation
import CoreData

class SpaceTool: NSManagedObject, Codable {
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

    static func getAll(context: NSManagedObjectContext, spaceId: String, completion: (([SpaceTool]?, Error?) -> Void)? = nil) {
        guard let url = URL(string: "https://api.assembla.com/v1/spaces/\(spaceId)/space_tools/repo.json") else {
            return
        }
        let childContext = context.newChildContext()
        AssemblaRequest.authorizedRequest(url: url, context: childContext) { (spaceTools: [Self]?, error: Error?) in
            let mappedSpaces = spaceTools?.compactMap { spaceTool -> NSManagedObjectID in
                let fetchRequest = NSFetchRequest<Self>(entityName: "SpaceTool")
                fetchRequest.predicate = NSPredicate(format: "id = %@", spaceTool.id)
                let spaceFetchRequest = NSFetchRequest<Space>(entityName: "Space")
                spaceFetchRequest.predicate = NSPredicate(format: "id = %@", spaceId)
                let space = try? childContext.fetch(spaceFetchRequest).first
                if let tool = (try? childContext.fetch(fetchRequest).first) {
                    tool.update(updatedEntity: spaceTool)
                    tool.space = space
                    try? childContext.savePrivateContext()
                    return tool.objectID
                }
                childContext.parent?.performAndWait {
                    childContext.parent?.insert(spaceTool)
                }
                spaceTool.space = space
                return spaceTool.objectID
            } ?? []
            DispatchQueue.main.async {
                let fetchRequest = NSFetchRequest<Self>(entityName: "SpaceTool")
                fetchRequest.predicate = NSPredicate(format: "self = %@", mappedSpaces)
                completion?(try? context.fetch(fetchRequest), error)
            }
        }
    }
}
