//
//  Date+Extension.swift
//  Tracker
//
//  Created by Eduard Tokarev on 11.05.2023.
//

import Foundation

extension Date {
    func onlyDate() -> Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        let date = Calendar.current.date(from: components)
        return date!
    }
}
