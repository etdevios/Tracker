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
                return "Трекеры"
            case .statistic:
                return "Статистика"
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
                return UINavigationController(rootViewController: TrackersViewController())
            case .statistic:
                return UINavigationController(rootViewController: StatisticViewController())
            }
        }
        
        viewControllers?.enumerated().forEach {
            $1.tabBarItem.title = dataSource[$0].title
            $1.tabBarItem.image = UIImage(systemName: dataSource[$0].iconName)
        }
    }
    
    private func wrappedInNavigationController(with: UIViewController, title: Any?) -> UIViewController {
        return UINavigationController(rootViewController: with)
    }
    
}

