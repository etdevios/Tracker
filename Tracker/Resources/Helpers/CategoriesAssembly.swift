//
//  CategoriesAssembly.swift
//  Tracker
//
//  Created by Eduard Tokarev on 20.06.2023.
//

import UIKit

struct CategoryConfiguration {
    let lastCategory: String?
}

final class CategoriesAssembly {
    func assemble(with configuration: CategoryConfiguration) -> UIViewController {
        let categoryStore = TrackerCategoryStore(context: (UIApplication.shared.delegate as! AppDelegate).persistantConteiner.viewContext)
        let lastCategory = configuration.lastCategory
        let viewModel = CategoriesViewModel(categoryStore: categoryStore, lastCategory: lastCategory)
        let viewController = CategoriesViewController(viewModel: viewModel)
        return viewController
    }
}
