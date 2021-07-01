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
        ticket.id = 123
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
        _ = Space.getAll(context: context) { spaces, _ in
            self.getTickets(context: context)
        }

    }

    private func getTickets(context: NSManagedObjectContext) {
        _ = Ticket.getAll(context: context) { tickets, error in
            guard error == nil else {
                print(error ?? "No error")
                return
            }
            let spaceStones = tickets?.reduce([Int: String]()) { (result, ticket) -> [Int: String]? in
                var results = result
                results?[ticket.milestoneId] = ticket.spaceId ?? "-1"
                return results
            }
            spaceStones?.keys.forEach { spaceStoneKey in
                let spaceStoneValue = spaceStones?[spaceStoneKey] ?? "No results"
                Milestone.get(context: context, spaceId: spaceStoneValue, milestoneId: spaceStoneKey) { milestone, error in
                    guard error == nil else {
                        print(error ?? "No error")
                        return
                    }
                    let fetchRequest = NSFetchRequest<Ticket>(entityName: "Ticket")
                    fetchRequest.predicate = NSPredicate(format: "milestoneId = %i", milestone?.id ?? 0)
                    let tickets = try? context.fetch(fetchRequest)
                    tickets?.forEach { $0.milestone = milestone }
                    try? context.save()
                }
            }
        }
    }

    private func getSpaceTools(context: NSManagedObjectContext, spaces: [Space]?) {
        spaces?.forEach { space in
            SpaceTool.getAll(context: context, spaceId: space.id)
        }
    }
}
