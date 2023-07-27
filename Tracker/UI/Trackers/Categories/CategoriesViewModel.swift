//
//  CategoriesViewModel.swift
//  Tracker
//
//  Created by Eduard Tokarev on 27.07.2023.
//

import Foundation

protocol CategoriesViewModelDelegate: AnyObject {
    func updateCategories()
    func didSelectCategories(category: TrackerCategory)
}

final class CategoriesViewModel {
    private var trackerCategoryStore = TrackerCategoryStore.shared
    
    weak var delegate: CategoriesViewModelDelegate?
    
    private(set) var categories: [TrackerCategory] = [] {
        didSet {
            delegate?.updateCategories()
        }
    }
    
    private(set) var selectedCategory: TrackerCategory? = nil {
        didSet {
            guard let selectedCategory else { return }
            delegate?.didSelectCategories(category: selectedCategory)
        }
    }
    
    init(selectedCategory: TrackerCategory?) {
        self.selectedCategory = selectedCategory
        self.trackerCategoryStore.delegate = self
    }
    
    func loadCategories() {
        categories = getCategoriesFromStore()
    }
    
    func selectCategory(indexPath: IndexPath) {
        selectedCategory = categories[indexPath.row]
    }
    
    func deleteCategory(category: TrackerCategory) {
        do {
            try trackerCategoryStore.deleteCategory(category)
            categories = getCategoriesFromStore()
            if category == selectedCategory {
                selectedCategory = nil
            }
        } catch {}
    }
    
    func checkRewriteCategory(with label: String) {
        if categories.contains(where: { $0.title == label }) {
            updateCategory(with: label)
        } else {
            addCategory(with: label)
        }
    }
    
    private func getCategoriesFromStore() -> [TrackerCategory] {
        do {
            let categories = try trackerCategoryStore.categoriesCoreData.map {
                try trackerCategoryStore.getCategory(from: $0)
            }
            return categories
        } catch {
            return []
        }
    }
    
    private func addCategory(with label: String) {
        do {
            try trackerCategoryStore.addCategory(with: label)
            loadCategories()
        } catch {}
    }
    
    private func updateCategory(with label: String) {
        
    }
}

// MARK: - TrackerCategoryStoreDelegate
extension CategoriesViewModel: TrackerCategoryStoreDelegate {
    func didUpdate() {
        categories = getCategoriesFromStore()
    }
}

