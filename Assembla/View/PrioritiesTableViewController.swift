//
//  PrioritiesTableViewController.swift
//  Assembla
//
//  Created by Brian Beversdorf on 6/26/21.
//

import UIKit
import CoreData
import SwiftReorder

class PrioritiesTableViewController: UITableViewController {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var sectionedItems: [(title: String, items: [Priority])] = []

    private var isEditable = false

    override func viewDidLoad() {

        var sections: [(title: String, items: [Priority])] = []
        let prioritySectionsFetchRequest = NSFetchRequest<PrioritySection>(entityName: "PrioritySection")
        prioritySectionsFetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        if let prioritySections = (try? context.fetch(prioritySectionsFetchRequest)) {
            sections = prioritySections.reduce([], { (results, section) -> [(title: String, items: [Priority])] in
                var newResults = results
                let sectionName = section.name ?? "Backlog"
                if newResults.contains(where: { $0.title == sectionName}) {
                    return newResults
                }
                newResults.append((title: sectionName, items: []))
                return newResults
            })
        }

        let prioritiesFetchRequest = NSFetchRequest<Priority>(entityName: "Priority")
        prioritiesFetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "row", ascending: true)
        ]
        if let priorities = (try? context.fetch(prioritiesFetchRequest)) {
            sectionedItems = priorities.reduce(sections, { (results, priority) -> [(title: String, items: [Priority])] in
                guard priority.ticket != nil else {
                    return results
                }
                var newResults = results
                let sectionName = priority.section?.name ?? "Backlog"
                guard let index = newResults.firstIndex(where: { $0.title == sectionName}) else {
                    return newResults
                }
                newResults[index].items.append(priority)
                return newResults
            })
        }

        tableView.reorder.delegate = self
        tableView.allowsSelection = false
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let spacer = tableView.reorder.spacerCell(for: indexPath) {
            return spacer
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PrioritiesTableViewCell.self), for: indexPath) as! PrioritiesTableViewCell
        cell.priority = itemFromDataSource(indexPath: indexPath)
        cell.updateCellColors()
        return cell
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionedItems.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionedItems[section].items.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection
                                section: Int) -> String? {
        guard section < sectionedItems.count else {
            return nil
        }
        return sectionedItems[section].title
    }

    fileprivate func itemFromDataSource(indexPath: IndexPath) -> Priority? {
        let section = indexPath.section
        let row = indexPath.row
        guard section < sectionedItems.count else {
            return nil
        }
        let priority = sectionedItems[section].items
        return row < priority.count ? priority[row] : nil
    }
}

class PrioritiesTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var statusLabel: UILabel?

    var priority: Priority? {
        didSet {
            guard let priority = priority, let ticket = priority.tickets?.first else {
                return
            }
            titleLabel?.text = "#\(ticket.numberWithPrefix!) - \(ticket.summary ?? "")"
            statusLabel?.text = ticket.status
        }
    }

    func updateCellColors() {
        titleLabel?.textColor = priority?.textColor
        statusLabel?.textColor = priority?.textColor
        contentView.backgroundColor = priority?.color != nil ? priority?.color : contentView.backgroundColor
    }
}

extension PrioritiesTableViewController: TableViewReorderDelegate {
    func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = sectionedItems[sourceIndexPath.section].items[sourceIndexPath.row]
        sectionedItems[sourceIndexPath.section].items.remove(at: sourceIndexPath.row)
        sectionedItems[destinationIndexPath.section].items.insert(item, at: destinationIndexPath.row)
        let prioritySectionsFetchRequest = NSFetchRequest<PrioritySection>(entityName: "PrioritySection")
        prioritySectionsFetchRequest.predicate = NSPredicate(format: "name = %@", sectionedItems[destinationIndexPath.section].title)
        guard let prioritySections = (try? context.fetch(prioritySectionsFetchRequest))?.first else {
            return
        }
        item.section = prioritySections
        for (index, priority) in sectionedItems[destinationIndexPath.section].items.enumerated() {
            priority.row = Int16(index)
        }
        try? item.managedObjectContext?.save()
    }
}
