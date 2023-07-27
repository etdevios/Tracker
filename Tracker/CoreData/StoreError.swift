//
//  StoresError.swift
//  Tracker
//
//  Created by Eduard Tokarev on 15.06.2023.
//

import Foundation

enum StoreError: Error {
    case decodeCategoryStoreError
    case decodeTrackerStoreError
    case decodeRecordStoreError
    case deleteError
    case pinError
    case updateError
    case getRecordError
    case saveRecordError
    case deleteRecordError
    case decodeError
    case fetchCategoryError
}
