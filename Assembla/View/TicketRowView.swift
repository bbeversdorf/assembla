//
//  TicketRowView.swift
//  Assembla
//
//  Created by Brian Beversdorf on 12/8/20.
//

import SwiftUI

struct TicketRowView: View {
    private let ticket: Ticket
    init(ticket: Ticket) {
        self.ticket = ticket
    }
    var body: some View {
        HStack(spacing: 10) {
            Text("#\(ticket.numberWithPrefix ?? "no ticket") - \(ticket.summary ?? "")")
            Spacer()
            HStack {
                HStack {
                    Text("\(ticket.status ?? "")")
                    Text("|")
                    Text(String(format: "%.2f", ticket.workingHours))
                }
                Button(action: {
                    UIPasteboard.general.string = "#\(ticket.numberWithPrefix!) - \(ticket.summary ?? "")"
                }) {
                    Text("Copy")
                }
                .buttonStyle(BorderlessButtonStyle())
                SpacerView()
                Button(action: {
                    let urlString = "https://clientportal.assembla.com/spaces/\( ticket.space!.wikiName)/tickets/\(String(ticket.number))"
                    guard let url = URL(string: urlString) else {
                        return
                    }
                    UIApplication.shared.open(url)
                }, label: {
                    Text("View")
                })
                .buttonStyle(BorderlessButtonStyle())
            }
        }
    }
}

struct TicketRowView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
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
        return TicketRowView(ticket: ticket)
    }
}
