//
//  WSSpace.swift
//  Assembla
//
//  Created by Brian Beversdorf on 11/30/20.
//

import Foundation
import CoreData
import UIKit

class Space: NSManagedObject, Codable {

    enum CodingKeys: String, CodingKey {
        case id
        case status
        case bannerHeight = "banner_height"
        case banner
        case updatedAt = "updated_at"
        case lastPayerChangedAt = "last_payer_changed_at"
        case teamTabRole = "team_tab_role"
        case createdAt = "created_at"
        case approved
        case tabsOrder = "tabs_order"
        case isCommercial = "is_commercial"
        case isManager = "is_manager"
        case teamPermissions = "team_permissions"
        case canJoin = "can_join"
        case bannerText = "banner_text"
        case restricted
        case sharePermissions = "share_permissions"
        case canApply = "can_apply"
        case isVolunteer = "is_volunteer"
        case publicPermissions = "public_permissions"
        case wikiName = "wiki_name"
        case name
        case style
        case parentId = "parent_id"
        case defaultShowPage = "default_showpage"
        case details = "description"
        case bannerLink = "banner_link"
        case commercialFrom = "commercial_from"
        case restrictedDate = "restricted_date"
        case watcherPermissions = "watcher_permissions"
    }

    required convenience init(from decoder: Decoder) throws {
        guard let key = CodingUserInfoKey.managedObjectContext,
              let context = decoder.userInfo[key] as? NSManagedObjectContext,
              let entity = NSEntityDescription.entity(forEntityName: String(describing: Self.self), in: context) else {
            throw DecoderConfigurationError.missingManagedObjectContext
        }
        self.init(entity: entity, insertInto: nil)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        status = try container.decode(Int.self, forKey: .status)
        lastPayerChangedAt = try container.decode(Date?.self, forKey: .lastPayerChangedAt)
        teamTabRole = try container.decode(Int.self, forKey: .teamTabRole)
        createdAt = try container.decode(Date?.self, forKey: .createdAt)
        updatedAt = try container.decode(Date?.self, forKey: .updatedAt)
        approved = try container.decode(Bool.self, forKey: .approved)
        tabsOrder = try container.decode(String?.self, forKey: .tabsOrder)
        isManager = try container.decode(Bool.self, forKey: .isManager)
        isVolunteer = try container.decode(Bool.self, forKey: .isVolunteer)
        isCommercial = try container.decode(Bool.self, forKey: .isCommercial)
        canJoin = try container.decode(Bool.self, forKey: .canJoin)
        canApply = try container.decode(Bool.self, forKey: .canApply)
        restricted = try container.decode(Bool.self, forKey: .restricted)
        restrictedDate = try container.decode(Date?.self, forKey: .restrictedDate)
        sharePermissions = try container.decode(Bool.self, forKey: .sharePermissions)
        publicPermissions = try container.decode(Int.self, forKey: .publicPermissions)
        teamPermissions = try container.decode(Int.self, forKey: .teamPermissions)
        watcherPermissions = try container.decode(Int.self, forKey: .watcherPermissions)
        wikiName = try container.decode(String.self, forKey: .wikiName)
        name = try container.decode(String.self, forKey: .name)
        style = try container.decode(String?.self, forKey: .style)
        parentId = try container.decode(String?.self, forKey: .parentId)
        defaultShowPage = try container.decode(String?.self, forKey: .defaultShowPage)
        details = try container.decode(String?.self, forKey: .details)
        commercialFrom = try container.decode(Date?.self, forKey: .commercialFrom)
        banner = try container.decode(String?.self, forKey: .banner)
        bannerHeight = try container.decodeIfPresent(Int.self, forKey: .bannerHeight) ?? -1
        bannerText = try container.decode(String?.self, forKey: .bannerText)
        bannerLink = try container.decode(String?.self, forKey: .bannerLink)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(status, forKey: .status)
        try container.encode(lastPayerChangedAt, forKey: .lastPayerChangedAt)
        try container.encode(teamTabRole, forKey: .teamTabRole)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(approved, forKey: .approved)
        try container.encode(tabsOrder, forKey: .tabsOrder)
        try container.encode(isManager, forKey: .isManager)
        try container.encode(isVolunteer, forKey: .isVolunteer)
        try container.encode(isCommercial, forKey: .isCommercial)
        try container.encode(canJoin, forKey: .canJoin)
        try container.encode(canApply, forKey: .canApply)
        try container.encode(restricted, forKey: .restricted)
        try container.encode(restrictedDate, forKey: .restrictedDate)
        try container.encode(sharePermissions, forKey: .sharePermissions)
        try container.encode(publicPermissions, forKey: .publicPermissions)
        try container.encode(teamPermissions, forKey: .teamPermissions)
        try container.encode(watcherPermissions, forKey: .watcherPermissions)
        try container.encode(wikiName, forKey: .wikiName)
        try container.encode(name, forKey: .name)
        try container.encode(style, forKey: .style)
        try container.encode(parentId, forKey: .parentId)
        try container.encode(defaultShowPage, forKey: .defaultShowPage)
        try container.encode(details, forKey: .details)
        try container.encode(commercialFrom, forKey: .commercialFrom)
        try container.encode(banner, forKey: .banner)
        try container.encode(bannerHeight, forKey: .bannerHeight)
        try container.encode(bannerText, forKey: .bannerText)
        try container.encode(bannerLink, forKey: .bannerLink)
    }

    static func getAll(context: NSManagedObjectContext, completion: @escaping ([Self]?, Error?) -> Void) {
        guard let url = URL(string: "https://api.assembla.com/v1/spaces.json") else {
            return
        }
        let childContext = context.newChildContext()
        AssemblaRequest.authorizedRequest(url: url, context: childContext) { (spaces: [Self]?, error: Error?) in
            spaces?.forEach { spaceResponse in
                let fetchRequest = NSFetchRequest<Self>(entityName: "Space")
                fetchRequest.predicate = NSPredicate(format: "id = %@", spaceResponse.id)
                if let space = (try? childContext.fetch(fetchRequest).first) {
                    space.update(updatedEntity: spaceResponse)
                    try? childContext.savePrivateContext()
                    return
                }
                childContext.parent?.performAndWait {
                    childContext.parent?.insert(spaceResponse)
                }
            }
            DispatchQueue.main.async {
                let fetchRequest = NSFetchRequest<Self>(entityName: "Space")
                completion(try? context.fetch(fetchRequest), error)
            }
        }
    }
}

extension CodingUserInfoKey {
   static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")
}

enum DecoderConfigurationError: Error {
  case missingManagedObjectContext
}

extension NSManagedObject {
    func update(updatedEntity: NSManagedObject) {
        for key in self.entity.attributesByName.keys {
            let value = updatedEntity.value(forKey: key)
            self.setValue(value, forKey: key)
        }
    }
}
