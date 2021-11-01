//
//  TicketsListView.swift
//  Assembla
//
//  Created by Brian Beversdorf on 6/23/21.
//

import SwiftUI

struct TicketsListView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Ticket.entity(),
                  sortDescriptors: [
                    NSSortDescriptor(keyPath: \Ticket.milestoneId, ascending: false)]) var tickets: FetchedResults<Ticket>
    var ticketsModel: TicketsModel = TicketsModel()

    var body: some View {
        VStack {
            List {
                ForEach(update(tickets), id: \.self) { section in
                    if let milestone = section[0].milestone {
                        TicketSectionView(milestone: milestone, tickets: section)
                    } else {
                        TicketSectionNoneView(tickets: section)
                    }
                }
            }.listStyle(GroupedListStyle())
            .onAppear {
                ticketsModel.fetch(context: managedObjectContext)
            }
        }
        .navigationBarItems(trailing:
            Button(action: {
                ticketsModel.fetch(context: managedObjectContext)
            }) {
                Image(systemName: "arrow.clockwise").imageScale(.large)
            }
        )
    }

    func update(_ result: FetchedResults<Ticket>)-> [[Ticket]]{
        return Dictionary(grouping: result) { $0.milestoneId }
            .values
            .map { $0 }
            .sorted(by: { $0[0].milestoneId < $1[0].milestoneId })
    }

}

struct TicketsListView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
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
        return TicketsListView()
            .environment(\.managedObjectContext, context)
    }
}
