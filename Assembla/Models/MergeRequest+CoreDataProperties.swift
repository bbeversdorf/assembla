//
//  MergeRequest+CoreDataProperties.swift
//  Assembla
//
//  Created by Brian Beversdorf on 12/11/20.
//
//

import Foundation
import CoreData


extension MergeRequest {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MergeRequest> {
        return NSFetchRequest<MergeRequest>(entityName: "MergeRequest")
    }

    @NSManaged public var status: Int16
    @NSManaged public var id: Int64
    @NSManaged public var title: String?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var comments: NSSet?

}

// MARK: Generated accessors for comments
extension MergeRequest {

    @NSManaged func addToComments(_ value: MergeRequestComment)

    @NSManaged func removeFromComments(_ value: MergeRequestComment)
}

extension MergeRequest : Identifiable {

}
