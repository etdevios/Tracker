//
//  Tracker.swift
//  Tracker
//
//  Created by Eduard Tokarev on 08.05.2023.
//

import UIKit

struct Tracker {
    let id: UUID
    let text: String
    let emoji: String
    let color: UIColor
    var schedule: [WeekDay]?
    let completedDaysCount: Int
    var isPinned: Bool
    let category: TrackerCategory
    
    init(id: UUID = UUID(), color: UIColor, text: String, emoji: String, completedDaysCount: Int, schedule: [WeekDay]?, isPinned: Bool, category: TrackerCategory) {
        self.id = id
        self.color = color
        self.text = text
        self.emoji = emoji
        self.completedDaysCount = completedDaysCount
        self.schedule = schedule
        self.isPinned = isPinned
        self.category = category
    }
}
