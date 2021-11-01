//
//  Ticket.swift
//  Assembla
//
//  Created by Brian Beversdorf on 12/1/20.
//
//

import Foundation
import CoreData

class Ticket: NSManagedObject, Codable, HasPrimaryKey {
    static var primaryKeyPath: String {
        return "ticketId"
    }

    var primaryKey: String {
        return String(describing: self[keyPath: \.ticketId])
    }

    // Transient property to delete old tickets
    internal var deleteMe: Bool = false

    enum CodingKeys: String, CodingKey {
        case ticketId = "id"
        case number
        case totalEstimate = "total_estimate"
        case priority
        case componentId = "component_id"
        case storyImportance = "story_importance"
        case spaceId = "space_id"
        case reporterId = "reporter_id"
        case milestoneId = "milestone_id"
        case status
        case isStory = "is_story"
        case notificationList = "notification_list"
        case permissionType = "permission_type"
        case details = "description"
        case completedDate = "completed_date"
        case importance
        case createdOn = "created_on"
        case totalInvestedHours = "total_invested_hours"
        case updatedAt = "updated_at"
        case summary
        case totalWorkingHours = "total_working_hours"
        case estimate
        case assignedToId = "assigned_to_id"
        case statusName = "status_name"
        case workingHours = "working_hours"
        case numberWithPrefix = "number_with_prefix"
        case space = "space"
        // "custom_fields":{"Text Field":"","list":""},
    }

    required public convenience init(from decoder: Decoder) throws {
        guard let key = CodingUserInfoKey.managedObjectContext,
              let context = decoder.userInfo[key] as? NSManagedObjectContext,
              let entity = NSEntityDescription.entity(forEntityName: String(describing: Self.self), in: context) else {
            throw DecoderConfigurationError.missingManagedObjectContext
        }
        self.init(entity: entity, insertInto: nil)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        ticketId = try container.decode(Int.self, forKey: .ticketId)
        number = try container.decode(Int.self, forKey: .number)
        totalEstimate = try container.decode(Double.self, forKey: .totalEstimate)
        priority = try container.decode(Int.self, forKey: .priority)
        componentId = try container.decode(String?.self, forKey: .componentId)
        storyImportance = try container.decodeIfPresent(Int.self, forKey: .storyImportance) ?? -1
        spaceId = try container.decode(String?.self, forKey: .spaceId)
        milestoneId = try container.decodeIfPresent(Int.self, forKey: .milestoneId) ?? -1
        status = try container.decode(String?.self, forKey: .status)
        isStory = try container.decode(Bool.self, forKey: .isStory)
        notificationList = try container.decode(String?.self, forKey: .notificationList)
        permissionType = try container.decode(Int.self, forKey: .permissionType)
        details = try container.decode(String?.self, forKey: .details)
        completedDate = try container.decode(Date?.self, forKey: .completedDate)
        importance = try container.decode(Double.self, forKey: .importance)
        createdOn = try container.decode(Date?.self, forKey: .createdOn)
        totalInvestedHours = try container.decode(Double.self, forKey: .totalInvestedHours)
        updatedAt = try container.decode(Date?.self, forKey: .updatedAt)
        summary = try container.decode(String?.self, forKey: .summary)
        totalWorkingHours = try container.decode(Double.self, forKey: .totalWorkingHours)
        estimate = try container.decode(Double.self, forKey: .estimate)
        assignedToId = try container.decode(String?.self, forKey: .assignedToId)
        statusName = try container.decodeIfPresent(Int.self, forKey: .statusName) ?? -1
        workingHours = try container.decode(Double.self, forKey: .workingHours)
        numberWithPrefix = try container.decode(String?.self, forKey: .numberWithPrefix)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(ticketId, forKey: .ticketId)
        try container.encode(number, forKey: .number)
        try container.encode(totalEstimate, forKey: .totalEstimate)
        try container.encode(priority, forKey: .priority)
        try container.encode(componentId, forKey: .componentId)
        try container.encode(storyImportance, forKey: .storyImportance)
        try container.encode(spaceId, forKey: .spaceId)
        try container.encode(milestoneId, forKey: .milestoneId)
        try container.encode(status, forKey: .status)
        try container.encode(isStory, forKey: .isStory)
        try container.encode(notificationList, forKey: .notificationList)
        try container.encode(permissionType, forKey: .permissionType)
        try container.encode(details, forKey: .details)
        try container.encode(completedDate, forKey: .completedDate)
        try container.encode(importance, forKey: .importance)
        try container.encode(createdOn, forKey: .createdOn)
        try container.encode(totalInvestedHours, forKey: .totalInvestedHours)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(summary, forKey: .summary)
        try container.encode(totalWorkingHours, forKey: .totalWorkingHours)
        try container.encode(estimate, forKey: .estimate)
        try container.encode(assignedToId, forKey: .assignedToId)
        try container.encode(statusName, forKey: .statusName)
        try container.encode(workingHours, forKey: .workingHours)
        try container.encode(numberWithPrefix, forKey: .numberWithPrefix)
    }

    static func getTickets(context: NSManagedObjectContext, spaceId: String) -> RequestOperation<[Ticket]>? {
        guard var url = URL(string: "https://api.assembla.com/v1/spaces/\(spaceId)/tickets/my_active") else {
            return nil
        }
        url.appendQueryItem(name: "per_page", value: "100")
        return RequestOperation<[Ticket]>(url: url, context: context)
    }

    static func getAll(context: NSManagedObjectContext) -> [Operation] {
        let spaceFetchRequest = NSFetchRequest<Space>(entityName: "Space")
        var results: [Space]
        do {
            results = try context.fetch(spaceFetchRequest)
        } catch {
            results = []
        }
        var operations: [Operation] = []
        results.forEach { space in
            let spaceId = space.id
            guard let operation = getTickets(context: context, spaceId: space.id) else {
                return
            }
            let ticketsFetchRequest = NSFetchRequest<Ticket>(entityName: "Ticket")
            ticketsFetchRequest.predicate = NSPredicate(format: "spaceId = %@", spaceId)
            operation.completionBlock = {
                defer {
                    operation.completionBlock = nil
                }
                guard operation.error == nil else {
                    return
                }
                context.performAndWait {
                    if let decodedObjectIds = operation.decodedObjectIds {
                        let fetchRequest = NSFetchRequest<Ticket>(entityName: "Ticket")
                        fetchRequest.predicate = NSPredicate(format: "spaceId = %@ AND NOT(self IN %@)", spaceId, decodedObjectIds)
                        (try? context.fetch(fetchRequest))?.forEach {
                            context.delete($0)
                        }
                    }
                    // Load or create priority
                    (try? context.fetch(ticketsFetchRequest))?.forEach {
                        _ = $0.myPriority
                    }
                }
            }
            operations.append(operation)
        }
        return operations
    }
}

extension NSManagedObjectContext {
    public func newChildContext() -> NSManagedObjectContext{
        let childContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        childContext.parent = self
        childContext.automaticallyMergesChangesFromParent = true
        return childContext
    }

    func savePrivateContext() throws {
        guard let parent = parent else {
            try save()
            return
        }
        try save()
        parent.performAndWait {
            do {
                try parent.save()
            } catch let err {
                print(err)
            }
        }
    }
}
