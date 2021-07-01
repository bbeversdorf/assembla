//
//  MentionView.swift
//  Assembla
//
//  Created by Brian Beversdorf on 12/8/20.
//

import SwiftUI

struct MentionView: View {
    private let mention: Mention
    init(mention: Mention) {
        self.mention = mention
    }
    var body: some View {
        HStack {
            Text(mention.message ?? "")
                .multilineTextAlignment(.leading)
            Spacer()
            Button(action: {
                mention.markAsRead()
            }) {
                Text("Mark as read")
            }
            .buttonStyle(BorderlessButtonStyle())
            SpacerView()
            Button(action: {
                let link: String = {
                    let mentionLink = mention.link ?? ""
                    if mentionLink.contains("assembla.com") {
                        return mentionLink
                    }
                    return "https://clientportal.assembla.com\(mentionLink)"
                }()
                guard let url = URL(string: link) else {
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

struct MentionView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let mention = Mention(context: context)
        mention.id = 1234
        mention.message = "Hello you were mentioned!"
        mention.link = "234"
        mention.authorId = "1234"
        return MentionView(mention: mention)
    }
}
