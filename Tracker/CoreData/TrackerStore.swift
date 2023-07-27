//
//  TrackerStore.swift
//  Tracker
//
//  Created by Eduard Tokarev on 15.06.2023.
//

import CoreData
import UIKit

protocol TrackerStoreDelegate: AnyObject {
    func didUpdate()
}

protocol TrackerStoreProtocol {
    var numberOfTrackers: Int { get }
    var numberOfSections: Int { get }
    var delegate: TrackerStoreDelegate? { get set}
    
    func loadFilteredTrackers(date: Date, searchString: String) throws
    func numberOfRowsInSection(_ section: Int) -> Int
    func headerLabelInSection(_ section: Int) -> String?
    func tracker(at indexPath: IndexPath) -> Tracker?
    func addTracker(_ tracker: Tracker, with category: TrackerCategory) throws
    func updateTracker(_ tracker: Tracker, with newData: Tracker) throws
    func deleteTracker(_ tracker: Tracker) throws
    func togglePin(for tracker: Tracker) throws
}

final class TrackerStore: NSObject {
    static let shared = TrackerStore()
    weak var delegate: TrackerStoreDelegate?
    
    private let context: NSManagedObjectContext
    private let trackerCategoryStore = TrackerCategoryStore()
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt",
                                                         ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category",
            cacheName: nil
        )
        
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    convenience override init() {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    func getTracker(from coreData: TrackerCoreData) throws -> Tracker {
        guard
            let id = coreData.trackerId,
            let text = coreData.trackerName,
            let emoji = coreData.trackerEmoji,
            let colorHEX = coreData.trackerColor,
            let categoryCoreData = coreData.category,
            let category = try? trackerCategoryStore.getCategory(from: categoryCoreData),
            let completedDaysCount = coreData.records
        else { throw StoreError.decodeTrackerStoreError }
        let color = UIColor.color(from: colorHEX)
        let scheduleString = coreData.trackerSchedule
        let schedule = WeekDay.decode(from: scheduleString)
        return Tracker(
            id: id,
            color: color,
            text: text,
            emoji: emoji,
            completedDaysCount: completedDaysCount.count,
            schedule: schedule,
            isPinned: coreData.isPinned,
            category: category
        )
    }
    
    func getTrackerCoreData(by id: UUID) throws -> TrackerCoreData? {
        fetchedResultsController.fetchRequest.predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerCoreData.trackerId), id.uuidString
        )
        try fetchedResultsController.performFetch()
        return fetchedResultsController.fetchedObjects?.first
    }
    
}

// MARK: - TrackerStoreProtocol
extension TrackerStore: TrackerStoreProtocol {
    
    var numberOfTrackers: Int {
        fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    var numberOfSections: Int {
        sections.count
    }
    
    private var pinnedTrackers: [Tracker] {
        guard let fetchedObjects = fetchedResultsController.fetchedObjects else { return [] }
        let trackers = fetchedObjects.compactMap { try? getTracker(from: $0) }
        return trackers.filter({ $0.isPinned })
    }
    
    private var sections: [[Tracker]] {
        guard let sectionsCoreData = fetchedResultsController.sections else { return [] }
        var sections: [[Tracker]] = []
        if !pinnedTrackers.isEmpty {
            sections.append(pinnedTrackers)
        }
        
        sectionsCoreData.forEach { section in
            var sectionToAdd: [Tracker] = []
            section.objects?.forEach({ object in
                guard
                    let trackerCoreData = object as? TrackerCoreData,
                    let tracker = try? getTracker(from: trackerCoreData),
                    !tracker.isPinned
                else { return }
                sectionToAdd.append(tracker)
            })
            if !sectionToAdd.isEmpty {
                sections.append(sectionToAdd)
            }
        }
        return sections
    }
    
    func loadFilteredTrackers(date: Date, searchString: String) throws {
        var predicates = [NSPredicate]()
        
        let weekdayIndex = Calendar.current.component(.weekday, from: date)
        let iso860WeekdayIndex = weekdayIndex > 1 ? weekdayIndex - 2 : weekdayIndex + 5
        
        var regex = ""
        for index in 0..<7 {
            if index == iso860WeekdayIndex {
                regex += "1"
            } else {
                regex += "."
            }
        }
        
        predicates.append(NSPredicate(
            format: "%K == nil OR (%K != nil AND %K MATCHES[c] %@)",
            #keyPath(TrackerCoreData.trackerSchedule),
            #keyPath(TrackerCoreData.trackerSchedule),
            #keyPath(TrackerCoreData.trackerSchedule), regex
        ))
        
        if !searchString.isEmpty {
            predicates.append(NSPredicate(
                format: "%K CONTAINS[cd] %@",
                #keyPath(TrackerCoreData.trackerName), searchString
            ))
        }
        
        fetchedResultsController.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        try fetchedResultsController.performFetch()
        delegate?.didUpdate()
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        sections[section].count
    }
    
    func headerLabelInSection(_ section: Int) -> String? {
        if !pinnedTrackers.isEmpty && section == 0 {
            return "Закрепленные"
        }
        guard let category = sections[section].first?.category else { return nil }
        return category.title
    }
    
    func tracker(at indexPath: IndexPath) -> Tracker? {
        let tracker = sections[indexPath.section][indexPath.item]
        return tracker
    }
    
    func addTracker(_ tracker: Tracker, with category: TrackerCategory) throws {
        let categoryCoreData = try trackerCategoryStore.categoryCoreData(with: category.id)
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.trackerId = tracker.id
        trackerCoreData.createdAt = Date()
        trackerCoreData.trackerName = tracker.text
        trackerCoreData.trackerEmoji = tracker.emoji
        trackerCoreData.trackerColor = UIColor.hexString(from: tracker.color)
        trackerCoreData.trackerSchedule = WeekDay.code(tracker.schedule)
        trackerCoreData.category = categoryCoreData
        trackerCoreData.isPinned = tracker.isPinned
        try context.save()
    }
    
    func updateTracker(_ tracker: Tracker, with newData: Tracker) throws {
        
        let trackerCoreData = try getTrackerCoreData(by: tracker.id)
        let categoryCoreData = try trackerCategoryStore.categoryCoreData(with: newData.category.id)
        trackerCoreData?.trackerName = newData.text
        trackerCoreData?.trackerEmoji = newData.emoji
        trackerCoreData?.trackerColor = UIColor.hexString(from: newData.color)
        trackerCoreData?.trackerSchedule = WeekDay.code(newData.schedule)
        trackerCoreData?.category = categoryCoreData
        try context.save()
    }
    
    func deleteTracker(_ tracker: Tracker) throws {
        guard let trackerToDelete = try getTrackerCoreData(by: tracker.id) else { throw StoreError.deleteError }
        context.delete(trackerToDelete)
        try context.save()
    }
    
    func togglePin(for tracker: Tracker) throws {
        guard let trackerToToggle = try getTrackerCoreData(by: tracker.id) else { throw StoreError.pinError }
        trackerToToggle.isPinned.toggle()
        try context.save()
    }
}


// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate()
    }
}
