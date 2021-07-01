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

class Milestone: NSManagedObject, Codable {

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

    static func get(context: NSManagedObjectContext, spaceId: String, milestoneId: Int,  completion: ((Milestone?, Error?) -> Void)? = nil) {
        guard let url = URL(string: "https://api.assembla.com/v1/spaces/\(spaceId)/milestones/\(milestoneId).json") else {
            return
        }
        let childContext = context.newChildContext()
        AssemblaRequest.authorizedRequest(url: url, context: childContext) { (milestone: Self?, error: Error?) in
            guard let milestone = milestone else {
                DispatchQueue.main.async {
                    completion?(nil, error)
                }
                return
            }
            let milestoneObjectId: NSManagedObjectID = {
                let fetchRequest = NSFetchRequest<Self>(entityName: "Milestone")
                fetchRequest.predicate = NSPredicate(format: "id = %i", milestoneId)
                if let milestone = (try? childContext.fetch(fetchRequest).first) {
                    milestone.update(updatedEntity: milestone)
                    try? childContext.savePrivateContext()
                    return milestone.objectID
                }
                childContext.parent?.performAndWait {
                    childContext.parent?.insert(milestone)
                }
                return milestone.objectID
            }()
            DispatchQueue.main.async {
                let milestone = context.object(with: milestoneObjectId) as? Self
                completion?(milestone, error)
            }
        }
    }
}
