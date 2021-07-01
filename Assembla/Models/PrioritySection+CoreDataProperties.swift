//
//  PrioritySection+CoreDataProperties.swift
//  Assembla
//
//  Created by Brian Beversdorf on 6/27/21.
//
//

import Foundation
import CoreData


extension PrioritySection {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PrioritySection> {
        return NSFetchRequest<PrioritySection>(entityName: "PrioritySection")
    }

    @NSManaged public var id: Int16
    @NSManaged public var name: String?
    @NSManaged public var priority: Set<PrioritySection>?

}

extension PrioritySection : Identifiable {

}
