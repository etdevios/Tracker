//
//  Date+Extension.swift
//  Tracker
//
//  Created by Eduard Tokarev on 11.05.2023.
//

import Foundation

extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
}
