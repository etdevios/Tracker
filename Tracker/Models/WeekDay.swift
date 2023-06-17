//
//  WeekDay.swift
//  Tracker
//
//  Created by Eduard Tokarev on 10.05.2023.
//

import Foundation

enum WeekDay: String, Comparable, CaseIterable {
    case Понедельник
    case Вторник
    case Среда
    case Четверг
    case Пятница
    case Суббота
    case Воскресенье
    
    var dayNumberOfWeek: Int {
        switch self {
        case .Понедельник:
            return 2
        case .Вторник:
            return 3
        case .Среда:
            return 4
        case .Четверг:
            return 5
        case .Пятница:
            return 6
        case .Суббота:
            return 7
        case .Воскресенье:
            return 1
        }
    }
    
    var shortName: String {
        switch self {
        case .Понедельник:
            return "Пн"
        case .Вторник:
            return "Вт"
        case .Среда:
            return "Ср"
        case .Четверг:
            return "Чт"
        case .Пятница:
            return "Пт"
        case .Суббота:
            return "Сб"
        case .Воскресенье:
            return "Вс"
        }
    }
    
    private var sortOrder: Int {
        switch self {
        case .Понедельник:
            return 0
        case .Вторник:
            return 1
        case .Среда:
            return 2
        case .Четверг:
            return 3
        case .Пятница:
            return 4
        case .Суббота:
            return 5
        case .Воскресенье:
            return 6
        }
    }
    
    static func < (lhs: WeekDay, rhs: WeekDay) -> Bool {
        return lhs.sortOrder < rhs.sortOrder
    }
}
