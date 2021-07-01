//
//  Mention+CoreDataProperties.swift
//  Assembla
//
//  Created by Brian Beversdorf on 2/1/21.
//
//

import Foundation
import CoreData


extension Mention {

    @NSManaged public var id: Int64
    @NSManaged public var authorId: String?
    @NSManaged public var link: String?
    @NSManaged public var message: String?
    @NSManaged public var read: Bool
    @NSManaged public var createdAt: Date?

}
