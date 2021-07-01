//
//  Priority+CoreDataProperties.swift
//  Assembla
//
//  Created by Brian Beversdorf on 6/27/21.
//
//

import Foundation
import CoreData


extension Priority {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Priority> {
        return NSFetchRequest<Priority>(entityName: "Priority")
    }

    @NSManaged public var row: Int16
    @NSManaged public var section: PrioritySection?
    @NSManaged internal var ticket: Ticket?

}

extension Priority : Identifiable {

}
