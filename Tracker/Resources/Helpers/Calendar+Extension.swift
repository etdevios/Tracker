//
//  Calendar+Extension.swift
//  Tracker
//
//  Created by Eduard Tokarev on 27.07.2023.
//

import Foundation

extension Calendar {
    static let mondayFirst: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        calendar.locale = Locale(identifier: "ru_RU")
        return calendar
    }()
}
