//
//  CategoriesViewModel.swift
//  Tracker
//
//  Created by Eduard Tokarev on 20.06.2023.
//

import Foundation

final class CategoriesViewModel {
    @Observable
    private(set) var categories: [TrackerCategory]?
    
    @Observable
    private(set) var alertModel: AlertModel?
    
    @Observable
    private(set) var selectedCategoryName: String?
    
    private let categoryStore: TrackerCategoryStore
    
    init(categoryStore: TrackerCategoryStore, lastCategory: String?) {
        self.selectedCategoryName = lastCategory
        self.categoryStore = categoryStore
        categories = getCategoriesFromStore()
    }
    
    func showAlertToDelete(_ category: TrackerCategory) {
        let alertModel = AlertModel(
            title: nil,
            message: "Эта категория точно не нужна?",
            buttonText: "Удалить",
            completion: { [weak self] _ in
                self?.deleteCategory(category: category)
            },
            cancelText: "Отменить",
            cancelCompletion: nil
        )
        
        self.alertModel = alertModel
    }
    
    func selectCategory(with name: String) {
        selectedCategoryName = name
    }
    
    func addNewCategory(with label: String?) {
        guard let label = label else { return }
        do {
            try categoryStore.makeCategory(with: label)
            categories = getCategoriesFromStore()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func editCategory(from existingLabel: String?, with label: String?) {
        guard let existingLabel = existingLabel,
              let label = label
        else { return }
        
        do {
            try categoryStore.editCategory(from: existingLabel, with: label)
        } catch {
            print(error.localizedDescription)
        }
        categories = getCategoriesFromStore()
    }
    
    func deleteCategory(category: TrackerCategory) {
        do {
            try categoryStore.deleteCategory(with: category)
            categories = getCategoriesFromStore()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func getCategoriesFromStore() -> [TrackerCategory] {
        return categoryStore.categories.map {
            TrackerCategory(title: $0.title, trackers: $0.trackers)
        }
    }
}

extension CategoriesViewModel: TrackerCategoryStoreDelegate {
    func storeDidUpdate(_ store: TrackerCategoryStore) {
        categories = getCategoriesFromStore()
    }
}
