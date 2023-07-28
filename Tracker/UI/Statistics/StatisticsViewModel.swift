//
//  StatisticsViewModel.swift
//  Tracker
//
//  Created by Eduard Tokarev on 27.07.2023.
//

import Foundation

enum StatisticsCases: CaseIterable, CustomStringConvertible {
    case bestPeriod
    case perfectDays
    case complitedTrackers
    case mediumValue
    
    var description: String {
        switch self {
        case .bestPeriod:
            return NSLocalizedString("bestPeriod", comment: "")
        case .perfectDays:
            return NSLocalizedString("perfectDays", comment: "")
        case .complitedTrackers:
            return NSLocalizedString("complitedTrackers", comment: "")
        case .mediumValue:
            return NSLocalizedString("mediumValue", comment: "")
        }
    }
}

final class StatisticsViewModel {
    private let trackerRecordStore = TrackerRecordStore.shared
    
    var cellModels: [StatisticsCellModel] = {
        var result = [StatisticsCellModel]()
        for item in StatisticsCases.allCases {
            let model = StatisticsCellModel(value: "0", description: item.description)
            result.append(model)
        }
        return result
    }()
    
    // MARK: - Observables
    
    @Observable
    private (set) var bestPeriod: Int = 0
    
    @Observable
    private (set) var perfectDays: Int = 0
    
    @Observable
    private (set) var complitedTrackers: Int = 0
    
    @Observable
    private (set) var mediumValue: Int = 0
    
    @Observable
    private (set) var isEmptyPlaceholderHidden: Bool = false
    
    //   MARK: - Methods
    
    func startObserve() {
        observeBestPeriod()
        observePerfectDays()
        observeComplitedTrackers()
        observeMediumValue()
        checkIsStatisticsEmpty()
    }
    
    private func observeBestPeriod() { }
    
    private func observePerfectDays() { }
    
    private func observeComplitedTrackers() {
        guard let trackers = try? trackerRecordStore.loadCompletedTrackers().count else { return }
        self.complitedTrackers = trackers
    }
    
    private func observeMediumValue() { }
    
    private func checkIsStatisticsEmpty() {
        if bestPeriod == 0 && perfectDays == 0 && complitedTrackers == 0 && mediumValue == 0 {
            isEmptyPlaceholderHidden = false
            return
        }
        isEmptyPlaceholderHidden = true
    }
}
