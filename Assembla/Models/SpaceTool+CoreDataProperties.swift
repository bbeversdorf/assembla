//
//  SpaceTool+CoreDataProperties.swift
//  Assembla
//
//  Created by Brian Beversdorf on 12/10/20.
//
//

import Foundation
import CoreData


extension SpaceTool {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SpaceTool> {
        return NSFetchRequest<SpaceTool>(entityName: "SpaceTool")
    }

    @NSManaged public var id: String
    @NSManaged public var name: String?
    @NSManaged public var spaceId: String?
    @NSManaged public var active: Bool
    @NSManaged public var toolId: Int16
    @NSManaged public var space: Space?

}

extension SpaceTool : Identifiable {

}
