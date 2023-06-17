//
//  WeekDaysMarshalling.swift
//  Tracker
//
//  Created by Eduard Tokarev on 15.06.2023.
//

import Foundation

final class WeekDaysMarshalling {
    func convertWeekDaysToString(_ days: [WeekDay]) -> String {
        let schedule = days.map { $0.rawValue + " " }.joined()
        return schedule
    }
    
    func convertStringToWeekDays(_ string: String?) -> [WeekDay] {
        guard let scheduleStringArray = string?.components(separatedBy: [" "]) else { return [] }
        let scheduleArray = scheduleStringArray.compactMap { WeekDay(rawValue: $0) }
        return scheduleArray
    }
}
