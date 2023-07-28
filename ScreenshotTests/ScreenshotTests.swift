//
//  ScreenshotTests.swift
//  ScreenshotTests
//
//  Created by Eduard Tokarev on 21.07.2023.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class ScreenshotTests: XCTestCase {
    func testLightViewController() {
        let trackerStore = TrackerStore()
        do {
            try trackerStore.deleteAll()
        } catch {
            print("Failed to clear the database with error: \(error.localizedDescription)")
        }
        
        let trackerVC = TrackerViewController()
        trackerVC.addNewFixTracker()
        guard let testDate = DateHelper().dateFormatterFromString.date(from: "01.01.2001") else { return }
        trackerVC.datePicker.date = testDate
        
        assertSnapshot(
            matching: trackerVC,
            as: .image(
                traits: UITraitCollection(userInterfaceStyle: .light)
            )
        )
    }
    
    func testDarkViewController() {
        let trackerStore = TrackerStore()
        do {
            try trackerStore.deleteAll()
        } catch {
            print("Failed to clear the database with error: \(error.localizedDescription)")
        }
        
        let trackerVC = TrackerViewController()
        trackerVC.addNewFixTracker()
        guard let testDate = DateHelper().dateFormatterFromString.date(from: "01.01.2001") else { return }
        trackerVC.datePicker.date = testDate
        
        assertSnapshot(
            matching: trackerVC,
            as: .image(
                traits: UITraitCollection(userInterfaceStyle: .dark)
            )
        )
    }
}
