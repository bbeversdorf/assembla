//
//  TicketSectionView.swift
//  Assembla
//
//  Created by Brian Beversdorf on 12/8/20.
//

import SwiftUI
import CoreData

struct TicketSectionView: View {
    private let section: [Ticket]
    @ObservedObject var milestone: Milestone
    @Environment(\.managedObjectContext) private var managedObjectContext
    init(milestone: Milestone, tickets: [Ticket]) {
        self.section = tickets
        self.milestone = milestone
    }
    var body: some View {
        return Section(header: ListHeader(milestone: milestone)) {
            ForEach(section, id: \.id) { item in
                TicketRowView(ticket: item)
            }
        }
    }
}

struct ListHeader: View {
    @ObservedObject var milestone: Milestone
    @Environment(\.managedObjectContext) private var managedObjectContext

    var body: some View {
        Text(milestone.title ?? "No results..")
    }
}

struct TicketSectionNoneView: View {
    private let section: [Ticket]
    init(tickets: [Ticket]) {
        self.section = tickets
    }
    var body: some View {
        return Section(header: Text("No results...")) {
            ForEach(section, id: \.id) { item in
                TicketRowView(ticket: item)
            }
        }
    }
}

struct TicketSectionView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let milestone = Milestone(context: context)
        milestone.title = "Test"
        milestone.id = -1
        let ticket = Ticket(context: context)
        ticket.ticketId = 123
        ticket.number = 123
        ticket.totalEstimate = 123
        ticket.priority = 1
        ticket.storyImportance = 1
        ticket.milestoneId = 1
        ticket.isStory = false
        ticket.permissionType = 1
        ticket.importance = 1
        ticket.totalInvestedHours = 1
        ticket.totalWorkingHours = 1
        ticket.estimate = 1
        ticket.statusName = 1
        ticket.workingHours = 1
        ticket.numberWithPrefix = "FLOAT-123"
        ticket.summary = "Ticket summary here"
        ticket.componentId = ""
        ticket.spaceId = "123"
        ticket.status = "123"
        ticket.notificationList = "123"
        ticket.details = "123"
        ticket.completedDate = Date()
        ticket.createdOn = Date()
        ticket.updatedAt = Date()
        ticket.assignedToId = "123"
        ticket.milestone = milestone
        return TicketSectionView(milestone: milestone, tickets: [ticket])
    }
}

class TicketsModel {
    func fetch(context: NSManagedObjectContext) {
        guard let spaceOperation = Space.get(context: context) else {
            return
        }
        let milestoneOperation = BlockOperation {
            context.perform {
                let milestoneOperations = Milestone.getAll(context: context)
                milestoneOperations.forEach {
                    RequestOperationQueue.shared.addOperation($0)
                }
            }
        }
        let ticketOperation = BlockOperation {
            context.perform {
                let ticketOperations = Ticket.getAll(context: context)
                ticketOperations.forEach {
                    RequestOperationQueue.shared.addOperation($0)
                }
                ticketOperations.forEach { milestoneOperation.addDependency($0) }
                RequestOperationQueue.shared.addOperation(milestoneOperation)
            }
        }
        ticketOperation.addDependency(spaceOperation)
        RequestOperationQueue.shared.addOperation(spaceOperation)
        RequestOperationQueue.shared.addOperation(ticketOperation)
    }
}
