//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Eduard Tokarev on 03.05.2023.
//

import UIKit



final class TrackersViewController: UIViewController {
    private var currentDate = Date()
    private var mockCategories: [TrackerCategory] = []
    private var completedTrackers: Set<TrackerRecord> = []
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var textOfSearchQuery = ""
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.calendar.firstWeekday = 2
        datePicker.addTarget(self, action: #selector(handleDatePicker), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var searchBar: UISearchController = {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        return searchController
    }()
    
    private lazy var trackerCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier)
        collectionView.register(HeaderCollectionView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderCollectionView.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    private lazy var infoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "star")
        return imageView
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .trBlack
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mockCategories = [TrackerCategory(title: "Домашняя кухня", trackers: [Tracker(id: UUID(), text: "New", emoji: "🍏", color: .trBlue, schedule: nil)])]
        mockCategories.append(TrackerCategory(title: "УБорка", trackers: [Tracker(id: UUID(), text: "NEws", emoji: "♻️", color: .trRed, schedule: nil)]))
        categories = mockCategories
        
        updateVisibleCategories()
        setBar()
        setupView()
        addSubviews()
        addViewConstraints()
    }
    
    private func setBar() {
        navigationItem.title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addTracker))
        navigationItem.leftBarButtonItem?.tintColor = .trBlack
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.searchController = searchBar
    }
    
    @objc private func addTracker() {
        let typeNewTrackerVC = TypeNewTrackerViewController(categories: categories)
        typeNewTrackerVC.delegate = self
        present(typeNewTrackerVC, animated: true)
    }
    
    @objc private func handleDatePicker() {
        currentDate = datePicker.date
        print(currentDate)
    }
    
    private func setupView() {
        view.backgroundColor = .trWhite
        
        if categories.isEmpty {
            trackerCollectionView.isHidden = true
            infoLabel.isHidden = false
            infoImageView.isHidden = false
        } else {
            trackerCollectionView.isHidden = false
            infoLabel.isHidden = true
            infoImageView.isHidden = true
        }
    }
    
    private func addSubviews() {
        [infoImageView, infoLabel, trackerCollectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0) }
    }
    
    private func addViewConstraints() {
        NSLayoutConstraint.activate([
            infoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            infoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoImageView.heightAnchor.constraint(equalToConstant: 80),
            infoImageView.widthAnchor.constraint(equalToConstant: 80),
            
            infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoLabel.topAnchor.constraint(equalTo: infoImageView.bottomAnchor, constant: 8),
            infoLabel.heightAnchor.constraint(equalToConstant: 18),
            
            trackerCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            trackerCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackerCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            trackerCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func updateVisibleCategories() {
        var categoriesFiltered = categories.map { filterTrackerCategory(category: $0) }
        categoriesFiltered = categoriesFiltered.filter { !$0.trackers.isEmpty }
        visibleCategories = categoriesFiltered
        trackerCollectionView.reloadData()
    }


    private func filterTrackerCategory(category: TrackerCategory) -> TrackerCategory {
        let trackers = category.trackers.filter( { ($0.text.contains(textOfSearchQuery) || textOfSearchQuery == "") })
        let filterCategory = TrackerCategory(title: category.title, trackers: trackers)
        return filterCategory
    }
    
}

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        textOfSearchQuery = searchController.searchBar.text ?? ""
        updateVisibleCategories()
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        trackerCollectionView.isHidden = visibleCategories.count == 0 ? true : false
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.identifier, for: indexPath) as? TrackerCollectionViewCell else { return UICollectionViewCell() }
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        let daysCount = completedTrackers.filter { $0.id == tracker.id }.count
        let isDoneToday = completedTrackers.contains(where: { $0.id == tracker.id && $0.id == tracker.id }) ? true : false
        cell.delegate = self
        cell.configCell(tracker: tracker)
        cell.configRecord(countDays: daysCount, isDoneToday: isDoneToday)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderCollectionView.identifier, for: indexPath) as? HeaderCollectionView  else { return UICollectionReusableView() }
        view.setTitle(visibleCategories[indexPath.section].title)
        return view
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    private var lineSpacing: CGFloat { return 16 }
    private var interitemSpacing: CGFloat { return 9 }
    private var sideInset: CGFloat { return 16 }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - interitemSpacing - 2 * sideInset) / 2
        return CGSize(width: width, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        
        return headerView.systemLayoutSizeFitting(
            CGSize(width: collectionView.frame.width,
                   height: UIView.layoutFittingExpandedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        lineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        interitemSpacing
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 12, left: sideInset, bottom: sideInset, right: sideInset)
    }
}

extension TrackersViewController: TrackerCollectionViewCellDelegate {
    func plusButtonTapped(cell: TrackerCollectionViewCell) {
        let indexPath: IndexPath = trackerCollectionView.indexPath(for: cell) ?? IndexPath()
        let id = visibleCategories[indexPath.section].trackers[indexPath.row].id
        var daysCount = completedTrackers.filter { $0.id == id }.count
        if !completedTrackers.contains(where: { $0.id == id && $0.date == currentDate }) {
            completedTrackers.insert(TrackerRecord(id: id, date: currentDate))
            daysCount += 1
            cell.configRecord(countDays: daysCount, isDoneToday: true)
        } else {
            completedTrackers.remove(TrackerRecord(id: id, date: currentDate))
            daysCount -= 1
            cell.configRecord(countDays: daysCount, isDoneToday: false)
        }
    }
}

extension TrackersViewController: TypeNewTrackerDelegate {
    func addNewTrackerCategory(_ newTrackerCategory: TrackerCategory) {
        dismiss(animated: true)
        if categories.contains(where: { $0.title == newTrackerCategory.title}) {
            let index = categories.firstIndex(where: { $0.title == newTrackerCategory.title })!
            let oldCategory = categories[index]
            let updatedTrackers = oldCategory.trackers + newTrackerCategory.trackers
            let updatedTrackerByСategory = TrackerCategory(title: newTrackerCategory.title, trackers: updatedTrackers)
            categories[index] = updatedTrackerByСategory
        } else {
            categories.append(newTrackerCategory)
        }
        trackerCollectionView.reloadData()
        updateVisibleCategories()
    }
}
