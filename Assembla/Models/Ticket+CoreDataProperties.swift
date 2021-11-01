//
//  Ticket+CoreDataProperties.swift
//  Assembla
//
//  Created by Brian Beversdorf on 12/1/20.
//
//

import Foundation
import CoreData


extension Ticket {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Ticket> {
        return NSFetchRequest<Ticket>(entityName: "Ticket")
    }

    internal var space: Space? {
        return spaces?.first
    }

    internal var myPriority: Priority {
        guard let priority = priorities?.first else {
            let newPriority = Priority.createPriority(context: managedObjectContext!, ticketId: ticketId)
            return newPriority
        }
        return priority
    }

    @NSManaged public var ticketId: Int
    @NSManaged public var number: Int
    @NSManaged public var totalEstimate: Double
    @NSManaged public var priority: Int
    @NSManaged public var componentId: String?
    @NSManaged public var storyImportance: Int
    @NSManaged public var spaceId: String?
    @NSManaged public var milestoneId: Int
    @NSManaged public var status: String?
    @NSManaged public var isStory: Bool
    @NSManaged public var notificationList: String?
    @NSManaged public var permissionType: Int
    @NSManaged public var details: String?
    @NSManaged public var completedDate: Date?
    @NSManaged public var importance: Double
    @NSManaged public var createdOn: Date?
    @NSManaged public var totalInvestedHours: Double
    @NSManaged public var updatedAt: Date?
    @NSManaged public var summary: String?
    @NSManaged public var totalWorkingHours: Double
    @NSManaged public var estimate: Double
    @NSManaged public var assignedToId: String?
    @NSManaged public var statusName: Int
    @NSManaged public var workingHours: Double
    @NSManaged public var numberWithPrefix: String?
    @NSManaged internal var milestone: Milestone?
    @NSManaged internal var priorities: [Priority]?
    @NSManaged internal var spaces: [Space]?
}

extension Ticket : Identifiable {

}
