//
//  WeekDay.swift
//  Tracker
//
//  Created by Eduard Tokarev on 10.05.2023.
//

import Foundation

enum WeekDay: String, CaseIterable {
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
}
