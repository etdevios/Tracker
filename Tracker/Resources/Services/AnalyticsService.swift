//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Eduard Tokarev on 21.07.2023.
//

import Foundation
import YandexMobileMetrica

enum Events: String {
    case click = "click"
    case open = "open"
    case close = "close"
}

enum Screens: String {
    case main = "Main"
}

enum Items: String {
    case addTrack = "add_track"
    case track = "track"
    case filter = "filter"
    case edit = "edit"
    case delete = "delete"
}

struct AnalyticsService {
    static func initAppMetrica() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "fbd90a54-bcad-4f17-8190-c86ff053a480") else { return }
        YMMYandexMetrica.activate(with: configuration)
    }
    
    
    func reportEvent(event: Events, screen: Screens, item: Items) {
        let params = [
            "screen": screen.rawValue,
            "item" : item.rawValue
        ]
        YMMYandexMetrica.reportEvent(event.rawValue, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
    
    func reportScreen(event: Events, onScreen: Screens) {
        let params = ["screen" : onScreen.rawValue]
        YMMYandexMetrica.reportEvent(event.rawValue, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}
