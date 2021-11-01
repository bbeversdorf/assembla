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

    @NSManaged public var row: Int16
    @NSManaged public var ticketId: Int
    @NSManaged public var section: PrioritySection?
    @NSManaged var tickets: [Ticket]?

    var ticket: Ticket? {
        return tickets?.first
    }
}
