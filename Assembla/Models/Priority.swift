//
//  Priority+CoreDataClass.swift
//  Assembla
//
//  Created by Brian Beversdorf on 6/27/21.
//
//

import UIKit
import CoreData

public class Priority: NSManagedObject {

    var color: UIColor? {
        guard let ticket = ticket else {
            return nil
        }
        switch ticket.priority {
        case 1:
            return .red
        case 2:
            return .orange
        case 3:
            return nil
        case 4:
            return .systemTeal
        case 5:
            return .systemIndigo
        default:
            return nil
        }
    }
    var textColor: UIColor {
        guard let ticket = ticket else {
            return .tertiaryLabel
        }
        switch ticket.priority {
        case 1:
            return .white
        case 2:
            return .black
        case 4:
            return .black
        case 5:
            return .white
        default:
            return .label
        }
    }
}
