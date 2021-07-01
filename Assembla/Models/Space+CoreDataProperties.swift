//
//  Space+CoreDataProperties.swift
//  Assembla
//
//  Created by Brian Beversdorf on 11/30/20.
//
//

import Foundation
import CoreData

extension Space {
    @NSManaged var id: String
    @NSManaged var status: Int
    @NSManaged var lastPayerChangedAt: Date?
    @NSManaged var teamTabRole: Int
    @NSManaged var createdAt: Date?
    @NSManaged var updatedAt: Date?
    @NSManaged var approved: Bool
    @NSManaged var tabsOrder: String?
    @NSManaged var isManager: Bool
    @NSManaged var isVolunteer: Bool
    @NSManaged var isCommercial: Bool
    @NSManaged var canJoin: Bool
    @NSManaged var canApply: Bool
    @NSManaged var restricted: Bool
    @NSManaged var restrictedDate: Date?
    @NSManaged var sharePermissions: Bool
    @NSManaged var publicPermissions: Int
    @NSManaged var teamPermissions: Int
    @NSManaged var watcherPermissions: Int
    @NSManaged var wikiName: String
    @NSManaged var name: String
    @NSManaged var style: String?
    @NSManaged var parentId: String?
    @NSManaged var defaultShowPage: String?
    @NSManaged var details: String?
    @NSManaged var commercialFrom: Date?
    @NSManaged var banner: String?
    @NSManaged var bannerHeight: Int
    @NSManaged var bannerText: String?
    @NSManaged var bannerLink: String?
}

extension Space : Identifiable {

}
