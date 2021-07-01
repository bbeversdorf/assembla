//
//  Milestone+CoreDataProperties.swift
//  Assembla
//
//  Created by Brian Beversdorf on 12/8/20.
//
//

import Foundation
import CoreData

extension Milestone {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Milestone> {
        return NSFetchRequest<Milestone>(entityName: "Milestone")
    }

    @NSManaged public var id: Int64
    @NSManaged public var title: String?

}

extension Milestone : Identifiable {

}
