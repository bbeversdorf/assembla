//
//  MergeRequestComment+CoreDataProperties.swift
//  Assembla
//
//  Created by Brian Beversdorf on 12/11/20.
//
//

import Foundation
import CoreData


extension MergeRequestComment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MergeRequestComment> {
        return NSFetchRequest<MergeRequestComment>(entityName: "MergeRequestComment")
    }

    @NSManaged public var mergeRequestId: Int64
    @NSManaged public var content: String?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var spaceId: String?
    @NSManaged public var id: Int64
    @NSManaged public var createdAt: Date?
    @NSManaged public var userId: String?
    @NSManaged public var mergeRequest: MergeRequest?
    @NSManaged public var space: Space?

}

extension MergeRequestComment : Identifiable {

}
