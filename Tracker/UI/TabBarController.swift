//
//  ViewController.swift
//  Tracker
//
//  Created by Eduard Tokarev on 23.04.2023.
//

import UIKit

final class TabBarController: UITabBarController {
    private enum TabBarItem: Int {
        case tracker
        case statistic
        
        var title: String {
            switch self {
            case .tracker:
                return NSLocalizedString("trackers", comment: "")
            case .statistic:
                return NSLocalizedString("statistics", comment: "")
            }
        }
        
        var iconName: String {
            switch self {
            case .tracker:
                return "record.circle.fill"
            case .statistic:
                return "hare.fill"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBar()
    }
    
    private func setupTabBar() {
        tabBar.backgroundColor = .trWhite
        
        let dataSource: [TabBarItem] = [.tracker, .statistic]
        
        self.viewControllers = dataSource.map {
            switch $0 {
            case .tracker:
                return TrackersViewController(trackerStore: TrackerStore())
            case .statistic:
                return StatisticViewController(viewModel: StatisticsViewModel())
            }
        }
        
        viewControllers?.enumerated().forEach {
            $1.tabBarItem.title = dataSource[$0].title
            $1.tabBarItem.image = UIImage(systemName: dataSource[$0].iconName)
        }
    }
}
