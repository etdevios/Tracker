//
//  CategoriesViewController.swift
//  Tracker
//
//  Created by Eduard Tokarev on 20.06.2023.
//

import UIKit

protocol CategoriesViewControllerDelegate: AnyObject {
    func didSelectCategory(_ category: TrackerCategory)
}

final class CategoriesViewController: UIViewController {
    weak var delegate: CategoriesViewControllerDelegate?
    var provideSelectedCategory: ((TrackerCategory) -> Void)?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = NSLocalizedString("category", comment: "")
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private lazy var categoryTableView: UITableView = {
        let table = UITableView()
        table.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.identifier)
        table.backgroundColor = .clear
        table.layer.masksToBounds = true
        table.layer.cornerRadius = 16
        table.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        table.separatorColor = .trGray
        table.rowHeight = UITableView.automaticDimension
        return table
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .toggleBlackWhiteColor
        button.setTitle(NSLocalizedString("addCategory", comment: ""), for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapAddCategoryButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var emptyCategoriesImageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "star")
        return image
    }()
    
    private lazy var emptyCategoriesLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("emptyCategories.text", comment: "")
        label.numberOfLines = 2
        label.textColor = .trBlack
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private let viewModel: CategoriesViewModel
    
    init(viewModel: CategoriesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        
        viewModel.delegate = self
        viewModel.loadCategories()
        
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
    }
    
    private func setLayout() {
        view.backgroundColor = .trWhite
        
        [titleLabel,
         addCategoryButton,
         categoryTableView,
         emptyCategoriesLabel,
         emptyCategoriesImageView
        ].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            
            categoryTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            categoryTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryTableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -16),
            
            addCategoryButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            
            emptyCategoriesImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyCategoriesImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            emptyCategoriesLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyCategoriesLabel.topAnchor.constraint(equalTo: emptyCategoriesImageView.bottomAnchor, constant: 8)
        ])
    }
    
    private func deleteCategory(category: TrackerCategory) {
        let alert = UIAlertController(title: nil,
                                      message: NSLocalizedString("alertCategory.text", comment: ""),
                                      preferredStyle: .actionSheet
        )
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel)
        let deleteAction = UIAlertAction(title: NSLocalizedString("delete", comment: ""), style: .destructive) { [weak self] _ in
            self?.viewModel.deleteCategory(category: category)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        present(alert, animated: true)
    }
    
    @objc
    private func didTapAddCategoryButton() {
        let createCategoryVC = CreateCategoryViewController()
        createCategoryVC.delegate = self
        createCategoryVC.modalPresentationStyle = .pageSheet
        present(createCategoryVC, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension CategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.identifier) as? CategoryCell else { return UITableViewCell() }
        
        let category = viewModel.categories[indexPath.row]
        cell.configCell(with: category.title)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let isLastCell = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        
        if isLastCell {
            cell.contentView.layer.cornerRadius = 16
            cell.contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0)
        }
        else {
            cell.contentView.layer.cornerRadius = 0
            cell.contentView.layer.maskedCorners = []
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
}

// MARK: - UITableViewDelegate
extension CategoriesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectCategory(indexPath: indexPath)
        provideSelectedCategory?(viewModel.selectedCategory!)
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let category = viewModel.categories[indexPath.row]
        
        return UIContextMenuConfiguration(actionProvider:  { _ in
            UIMenu(children: [
                UIAction(title: NSLocalizedString("edit", comment: "")) {_ in
                },
                UIAction(title: NSLocalizedString("delete", comment: ""), attributes: .destructive) { [weak self] _ in
                    self?.deleteCategory(category: category)
                }
            ])
        })
    }
    
}

// MARK: - CreateCategoryViewControllerDelegate
extension CategoriesViewController: CreateCategoryViewControllerDelegate {
    
    func addCategory(newCategoryLabel newCategory: String) {
        viewModel.checkRewriteCategory(with: newCategory)
        categoryTableView.reloadData()
        dismiss(animated: true)
    }
}


// MARK: - CategoriesViewModelDelegate
extension CategoriesViewController: CategoriesViewModelDelegate {
    func updateCategories() {
        if viewModel.categories.isEmpty {
            emptyCategoriesLabel.isHidden = false
            emptyCategoriesImageView.isHidden = false
        } else {
            emptyCategoriesLabel.isHidden = true
            emptyCategoriesImageView.isHidden = true
        }
        categoryTableView.reloadData()
    }
    
    func didSelectCategories(category: TrackerCategory) {
        delegate?.didSelectCategory(category)
    }
}
