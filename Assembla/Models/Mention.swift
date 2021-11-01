//
//  Mention.swift
//  Assembla
//
//  Created by Brian Beversdorf on 11/29/20.
//

import Foundation
import UIKit
import CoreData

class Mention: NSManagedObject, HasPrimaryKey, Identifiable {
    static var primaryKeyPath: String {
        return "id"
    }

    required public convenience init(from decoder: Decoder) throws {
        guard let key = CodingUserInfoKey.managedObjectContext,
              let context = decoder.userInfo[key] as? NSManagedObjectContext,
              let entity = NSEntityDescription.entity(forEntityName: String(describing: Self.self), in: context) else {
            throw DecoderConfigurationError.missingManagedObjectContext
        }
        self.init(entity: entity, insertInto: nil)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int64.self, forKey: .id)
        authorId = try container.decodeIfPresent(String.self, forKey: .authorId)
        link = try container.decodeIfPresent(String.self, forKey: .link)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        read = try container.decode(Bool.self, forKey: .read)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(authorId, forKey: .authorId)
        try container.encode(link, forKey: .link)
        try container.encode(message, forKey: .message)
        try container.encode(read, forKey: .read)
        try container.encode(createdAt, forKey: .createdAt)
    }

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case authorId = "author_id"
        case link = "link"
        case message = "message"
        case read = "read"
        case createdAt = "created_at"
    }

    static func get(context: NSManagedObjectContext) -> Operation? {
        guard let url = URL(string: "https://api.assembla.com/v1/user/mentions.json?unread") else {
            return nil
        }
        return RequestOperation<[Self]>(url: url, context: context)
    }


    func markAsRead() {
        defer {
            managedObjectContext?.delete(self)
        }
        guard let url = URL(string: "https://api.assembla.com/v1/user/mentions/\(id)/mark_as_read.json") else {
            return
        }
        let previousCount = UserDefaults.standard.integer(forKey: "mentions")
        let currentCount = previousCount - 1
        UserDefaults.standard.set(currentCount, forKey: "mentions")
        UIApplication.shared.applicationIconBadgeNumber = currentCount
        AssemblaRequest.authorizedRequest(url: url, method: "PUT") { (_: [Self]?, _) in }
    }

    static func updateMentionsBadge(context: NSManagedObjectContext) {
        DispatchQueue.main.async {
            let unread = (try? context.count(for: NSFetchRequest<Mention>(entityName: String(describing: Mention.self)))) ?? 0
            UserDefaults.standard.set(unread, forKey: "mentions")
            UIApplication.shared.applicationIconBadgeNumber = unread
        }
    }
}
