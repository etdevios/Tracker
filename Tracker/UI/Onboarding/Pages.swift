//
//  Pages.swift
//  Tracker
//
//  Created by Eduard Tokarev on 19.06.2023.
//

import Foundation

enum Pages: CaseIterable {
    case pageOne
    case pageTwo
    
    var title: String {
        switch self {
        case .pageOne:
            return NSLocalizedString("backgroundImage.blue.text", comment: "")
        case .pageTwo:
            return NSLocalizedString("backgroundImage.red.text", comment: "")
        }
    }
    
    var index: Int {
        switch self {
        case .pageOne:
            return 0
        case .pageTwo:
            return 1
        }
    }
}
