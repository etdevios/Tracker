//
//  TrackerRecord.swift
//  Tracker
//
//  Created by Eduard Tokarev on 08.05.2023.
//

import Foundation

struct TrackerRecord: Hashable {
    let id: UUID
    let date: Date
    let trackerId: UUID
    
    init(id: UUID = UUID(), trackerId: UUID, date: Date) {
        self.id = id
        self.trackerId = trackerId
        self.date = date
    }
}
