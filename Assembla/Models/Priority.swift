//
//  Priority+CoreDataClass.swift
//  Assembla
//
//  Created by Brian Beversdorf on 6/27/21.
//
//

import UIKit
import CoreData

class Priority: NSManagedObject, Identifiable {
    static var primaryKeyPath: String {
        return "id"
    }

    static func createPriority(context: NSManagedObjectContext, ticketId: Int) -> Priority {
        let priorityFetchRequest = NSFetchRequest<Priority>(entityName: "Priority")
        priorityFetchRequest.predicate = NSPredicate(format: "ticketId = %i", ticketId)
        let oldPriority = (try? context.fetch(priorityFetchRequest))?.first
        guard oldPriority == nil else {
            return oldPriority!
        }
        let priority = Priority(context: context)
        priority.ticketId = ticketId

        let fetchRequest = NSFetchRequest<PrioritySection>(entityName: "PrioritySection")
        fetchRequest.predicate = NSPredicate(format: "id = %i", -9999)
        guard let section = (try? context.fetch(fetchRequest))?.first else {
            return priority
        }
        priority.section = section
        return priority
    }

    var color: UIColor? {
        guard let ticket = ticket else {
            return nil
        }
        switch ticket.priority {
        case 1:
            return .red
        case 2:
            return .orange
        case 3:
            return nil
        case 4:
            return .systemTeal
        case 5:
            return .systemIndigo
        default:
            return nil
        }
    }
    var textColor: UIColor {
        guard let ticket = ticket else {
            return .tertiaryLabel
        }
        switch ticket.priority {
        case 1:
            return .white
        case 2:
            return .black
        case 4:
            return .black
        case 5:
            return .white
        default:
            return .label
        }
    }
}
