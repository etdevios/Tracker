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
    var schedule: [WeekDay]
}
