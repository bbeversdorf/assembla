//
//  MentionsListView.swift
//  Assembla
//
//  Created by Brian Beversdorf on 6/23/21.
//

import SwiftUI
import CoreData

struct MentionsListView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Mention.entity(),
                  sortDescriptors: [
                    NSSortDescriptor(keyPath: \Mention.createdAt, ascending: false)]) var mentions: FetchedResults<Mention>
    var mentionsModel: MentionsModel = MentionsModel()
    let timer = Timer.publish(every: 5 * 60, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            if mentions.isEmpty {
                Text("No mentions 😢")
            } else {
                List {
                    ForEach(mentions) { item in
                        MentionView(mention: item)
                    }
                }
            }
        }
        .onAppear {
            mentionsModel.fetch(context: managedObjectContext)
        }
        .onReceive(timer) { _ in
            mentionsModel.fetch(context: managedObjectContext)
        }
        .navigationBarItems(trailing:
            Button(action: {
                mentionsModel.fetch(context: managedObjectContext)
            }) {
                Image(systemName: "arrow.clockwise").imageScale(.large)
            }
        )
    }
}

struct MentionsListView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let mention = Mention(context: context)
        mention.id = 1234
        mention.link = "234"
        mention.authorId = "1234"
        let mentions = MentionsModel()
        return MentionsListView(mentionsModel: mentions)
            .environment(\.managedObjectContext, context)
    }
}

class MentionsModel: ObservableObject {
    func fetch(context: NSManagedObjectContext) {
        guard let fetchOperation = Mention.get(context: context) else {
            return
        }
        RequestOperationQueue.shared.addOperation(fetchOperation)
    }
}
