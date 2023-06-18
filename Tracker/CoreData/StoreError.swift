//
//  StoresError.swift
//  Tracker
//
//  Created by Eduard Tokarev on 15.06.2023.
//

import Foundation

enum StoreError: Error {
    case decodingErrorInvalidId
    case decodingErrorInvalidText
    case decodingErrorInvalidEmoji
    case decodingErrorInvalidColorHex
    case decodingErrorInvalidSchedule
    case decodingErrorInvalidCategoryTitle
    case decodingErrorInvalidTrackers
    case decodingErrorInvalidCategoryEntity
    case decodingErrorInvalidTrackerRecord
    case decodingErrorInvalidTracker
}
