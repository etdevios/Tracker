//
//  DateHelper.swift
//  Tracker
//
//  Created by Eduard Tokarev on 15.06.2023.
//

import Foundation

class DateHelper {
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()
}
