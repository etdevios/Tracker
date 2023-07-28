//
//  NewTrackerViewController.swift
//  Tracker
//
//  Created by Eduard Tokarev on 09.05.2023.
//

import UIKit

protocol NewTrackerViewControllerDelegate: AnyObject {
    func didTapCreateButton(_ tracker: Tracker, toCategory category: TrackerCategory)
    func didUpdateTracker(with tracker: Tracker)
    func didTapCancelButton()
}

final class NewTrackerViewController: UIViewController {
    var isRegular: Bool
    var isEditor: Bool
    var editingTracker: Tracker?
    
    weak var delegate: NewTrackerViewControllerDelegate?
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.backgroundColor = .clear
        scroll.showsHorizontalScrollIndicator = false
        scroll.showsVerticalScrollIndicator = false
        scroll.frame = view.bounds
        return scroll
    }()
    
    private lazy var textField: UITextField = {
        let field = UITextField()
        field.layer.masksToBounds = true
        field.returnKeyType = .done
        field.placeholder = NSLocalizedString("tracker.name", comment: "")
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: field.frame.height))
        field.leftView = paddingView
        field.leftViewMode = .always
        field.layer.cornerRadius = 16
        field.backgroundColor = .trBackground
        field.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        return field
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.layer.masksToBounds = true
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = .trGray
        return tableView
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.backgroundColor = .clear
        collection.allowsMultipleSelection = true
        return collection
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        if isEditor {
            button.setTitle(NSLocalizedString("save", comment: ""), for: .normal)
        } else {
            button.setTitle(NSLocalizedString("create", comment: ""), for: .normal)
        }
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.backgroundColor = .trGray
        button.isEnabled = false
        button.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.setTitle(NSLocalizedString("cancel", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.trRed, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.backgroundColor = .clear
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.trRed.cgColor
        button.addTarget(self, action: #selector(didTapCancelButon), for: .touchUpInside)
        return button
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.backgroundColor = .trWhite
        return stack
    }()
    
    private lazy var warningLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.text = NSLocalizedString("stringLengthLimit", comment: "")
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    private lazy var scheduleVC = ScheduleViewController(selectedDays: trackerSchedule ?? [])
    private lazy var categoriesVC = CategoriesViewController(viewModel: CategoriesViewModel(selectedCategory: trackerCategory))
    
    private let trackerCategoryStore = TrackerCategoryStore.shared
    
    private var trackerCategory: TrackerCategory? = nil {
        didSet {
            isTrackerReady()
        }
    }
    
    private var trackerSchedule: [String]?
    private var trackerColor: UIColor?
    private var trackerEmoji: String?
    private var trackerLabel: String?
    private var trackerCompletedDaysCount: Int?
    
    private var isCreateButtonEnable: Bool = false {
        willSet {
            if newValue {
                createButton.backgroundColor = .trBlack
                createButton.isEnabled = true
            } else {
                createButton.backgroundColor = .trGray
                createButton.isEnabled = false
            }
        }
    }
    
    private var params = UICollectionView.GeometricParams(cellCount: 6,
                                                          leftInset: 25,
                                                          rightInset: 25,
                                                          cellSpacing: 5)
    
    private let emojis = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝", "😪",
    ]
    
    private let colors = [
        #colorLiteral(red: 0.9921568627, green: 0.2980392157, blue: 0.2862745098, alpha: 1), #colorLiteral(red: 1, green: 0.5333333333, blue: 0.1176470588, alpha: 1), #colorLiteral(red: 0, green: 0.4823529412, blue: 0.9803921569, alpha: 1), #colorLiteral(red: 0.431372549, green: 0.2666666667, blue: 0.9960784314, alpha: 1), #colorLiteral(red: 0.2, green: 0.8117647059, blue: 0.4117647059, alpha: 1), #colorLiteral(red: 0.9019607843, green: 0.4274509804, blue: 0.831372549, alpha: 1),
        #colorLiteral(red: 0.9764705882, green: 0.831372549, blue: 0.831372549, alpha: 1), #colorLiteral(red: 0.2039215686, green: 0.6549019608, blue: 0.9960784314, alpha: 1), #colorLiteral(red: 0.2745098039, green: 0.9019607843, blue: 0.6156862745, alpha: 1), #colorLiteral(red: 0.2078431373, green: 0.2039215686, blue: 0.4862745098, alpha: 1), #colorLiteral(red: 1, green: 0.4039215686, blue: 0.3019607843, alpha: 1), #colorLiteral(red: 1, green: 0.6, blue: 0.8, alpha: 1),
        #colorLiteral(red: 0.9647058824, green: 0.768627451, blue: 0.5450980392, alpha: 1), #colorLiteral(red: 0.4745098039, green: 0.5803921569, blue: 0.9607843137, alpha: 1), #colorLiteral(red: 0.5137254902, green: 0.1725490196, blue: 0.9450980392, alpha: 1), #colorLiteral(red: 0.6784313725, green: 0.337254902, blue: 0.8549019608, alpha: 1), #colorLiteral(red: 0.5529411765, green: 0.4470588235, blue: 0.9019607843, alpha: 1), #colorLiteral(red: 0.1843137255, green: 0.8156862745, blue: 0.3450980392, alpha: 1)
    ]
    
    init(isRegular: Bool, isEditor: Bool) {
        self.isRegular = isRegular
        self.isEditor = isEditor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        textField.delegate = self
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(SupplementaryView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "header"
        )
        collectionView.register(EmojiAndColorsCollectionCell.self,
                                forCellWithReuseIdentifier: EmojiAndColorsCollectionCell.identifier
        )
        
        setLayout()
        setConstraints()
        if isEditor {
            setEditingForm()
        }
        isTrackerReady()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scheduleVC.provideSelectedDays = { [weak self] Array in
            self?.trackerSchedule = Array
            self?.tableView.reloadData()
        }
        
        categoriesVC.provideSelectedCategory = { [weak self] Category in
            self?.trackerCategory = Category
            self?.tableView.reloadData()
        }
        tableView.reloadData()
    }
    
    private func showWarningLabel(isNeedShow: Bool) {
        UIView.animate(withDuration: 0.8) {
            if isNeedShow {
                self.stackView.addArrangedSubview(self.warningLabel)
                self.warningLabel.layer.opacity = 1
            } else {
                self.warningLabel.layer.opacity = 0
                self.warningLabel.removeFromSuperview()
            }
        }
    }
    
    private func setEditingForm() {
        guard let tracker = editingTracker else { return }
        textField.text = tracker.text
        trackerLabel = tracker.text
        trackerColor = tracker.color
        trackerEmoji = tracker.emoji
        trackerCategory = tracker.category
        trackerCompletedDaysCount = tracker.completedDaysCount
        if tracker.schedule != nil {
            trackerSchedule = tracker.schedule?.compactMap { $0.shortName }
        }
    }
    
    private func isTrackerReady() {
        if isRegular {
            if (trackerColor == nil) || (trackerEmoji == nil) || (textField.text?.isEmpty == true) || (trackerCategory == nil) || (trackerSchedule == nil) {
                isCreateButtonEnable = false
                return
            }
        } else {
            if (trackerColor == nil) || (trackerEmoji == nil) || (textField.text?.isEmpty == true) || (trackerCategory == nil) {
                isCreateButtonEnable = false
                return
            }
        }
        isCreateButtonEnable = true
    }
    
    private func setLayout() {
        view.backgroundColor = .trWhite
        view.addSubview(titleLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [stackView, tableView, collectionView, createButton, cancelButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        stackView.addArrangedSubview(textField)
        
        if isEditor {
            if isRegular {
                titleLabel.text = NSLocalizedString("editHabit", comment: "")
            } else {
                titleLabel.text = NSLocalizedString("editEvent", comment: "")
            }
        } else {
            if self.isRegular {
                titleLabel.text = NSLocalizedString("newHabit", comment: "")
            } else {
                titleLabel.text = NSLocalizedString("newEvent", comment: "")
            }
        }
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            textField.heightAnchor.constraint(equalToConstant: 75),

            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            
            tableView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: (isRegular ? 149 : 74)),
            
            collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 484),
            
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -4),
            cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -34),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            createButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            createButton.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 4),
            createButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -34),
            createButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc
    private func didTapCreateButton() {
        guard
            let category = trackerCategory,
            let color = trackerColor,
            let emoji = trackerEmoji,
            let text = trackerLabel
        else { return }
        let schedule = trackerSchedule?.compactMap { dayString -> WeekDay? in
            WeekDay.allCases.first(where: { $0.shortName == dayString })
        }
        
        let tracker = Tracker(color: color,
                                 text: text,
                                 emoji: emoji,
                                 completedDaysCount: 0,
                                 schedule: schedule,
                                 isPinned: false,
                                 category: category
        )
        
        editingTracker = tracker
        
        if isEditor == true {
            delegate?.didUpdateTracker(with: tracker)
        } else {
            delegate?.didTapCreateButton(tracker, toCategory: category)
        }

        self.presentingViewController?.dismiss(animated: false, completion: nil)
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func didTapCancelButon() {
        delegate?.didTapCancelButton()
        self.presentingViewController?.dismiss(animated: false, completion: nil)
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate
extension NewTrackerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            present(categoriesVC, animated: true)
        case 1:
            scheduleVC.selectedDays = trackerSchedule ?? []
            present(scheduleVC, animated: true)
        default: break
        }
    }
}

// MARK: - UITableViewDataSource
extension NewTrackerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isRegular ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        cell.backgroundColor = .trBackground
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.detailTextLabel?.textColor = .trGray
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = NSLocalizedString("category", comment: "")
            if trackerCategory != nil {
                cell.detailTextLabel?.text = trackerCategory?.title
            }
        case 1:
            cell.textLabel?.text = NSLocalizedString("schedule", comment: "")
            if trackerSchedule?.isEmpty == false {
                if trackerSchedule?.count == 7 {
                    cell.detailTextLabel?.text = NSLocalizedString("everyDay", comment: "")
                } else {
                    cell.detailTextLabel?.text = trackerSchedule?.joined(separator: ", ")
                }
            }
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}

// MARK: - UITextFieldDelegate
extension NewTrackerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        trackerLabel = newText
        
        if newText.count <= 38 {
            showWarningLabel(isNeedShow: false)
            return true
        } else {
            showWarningLabel(isNeedShow: true)
            return false
        }
    }
}

// MARK: - UICollectionViewDataSource
extension NewTrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        emojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiAndColorsCollectionCell.identifier,
                                                      for: indexPath)
        
        guard let collectionCell = cell as? EmojiAndColorsCollectionCell else { return UICollectionViewCell() }
        
        collectionCell.layer.cornerRadius = 16
        collectionCell.layer.masksToBounds = true
        
        switch indexPath.section {
        case 0:
            collectionCell.layer.cornerRadius = 16
            collectionCell.label.text = emojis[indexPath.row]
            collectionCell.label.font = UIFont.systemFont(ofSize: 32)
            if collectionCell.label.text == trackerEmoji {
                collectionCell.backgroundColor = .trLightGray
            }
        case 1:
            let color = colors[indexPath.row]
            collectionCell.layer.cornerRadius = 13
            collectionCell.label.text = ""
            collectionCell.contentView.backgroundColor = color
            if isEditor {
                if UIColor.hexString(from: color) == UIColor.hexString(from: trackerColor ?? UIColor()) {
                    collectionCell.layer.borderColor = collectionCell.contentView.backgroundColor?.withAlphaComponent(0.3).cgColor
                    collectionCell.layer.borderWidth = 3
                }
            }
            
        default:
            break
        }
        collectionCell.prepareForReuse()
        return collectionCell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                   withReuseIdentifier: "header",
                                                                   for: indexPath) as? SupplementaryView
        guard let view = view else { return UICollectionReusableView() }
        
        switch indexPath.section {
        case 0:
            view.headerLabel.text = NSLocalizedString("emoji", comment: "")
        case 1:
            view.headerLabel.text = NSLocalizedString("colors", comment: "")
        default:
            break
        }
        return view
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension NewTrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView,
                                             viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader,
                                             at: indexPath)
        
        return headerView.systemLayoutSizeFitting(
            CGSize(
                width: collectionView.frame.width,
                height: UIView.layoutFittingExpandedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath)
    -> CGSize {
        let availableWidth = collectionView.frame.width - params.paddingWidth
        let cellWidth =  availableWidth / CGFloat(params.cellCount)
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 25,
                            left: params.leftInset,
                            bottom: 25,
                            right: params.rightInset
        )
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return params.cellSpacing
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return params.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath)  as? EmojiAndColorsCollectionCell  {
            
            switch indexPath.section {
            case 0:
                for item in 0..<collectionView.numberOfItems(inSection: 0) {
                    guard let cell = collectionView.cellForItem(at: IndexPath(row: item, section: 0)) else { return }
                    cell.backgroundColor = .clear
                }
                cell.backgroundColor = .trLightGray
                trackerEmoji = cell.label.text
                isTrackerReady()
            case 1:
                for item in 0..<collectionView.numberOfItems(inSection: 1) {
                    guard let cell = collectionView.cellForItem(at: IndexPath(row: item, section: 1)) else { return }
                    cell.backgroundColor = .clear
                    cell.layer.borderWidth = 0
                }
                cell.layer.borderColor = cell.contentView.backgroundColor?.withAlphaComponent(0.3).cgColor
                cell.layer.borderWidth = 3
                trackerColor = cell.contentView.backgroundColor
                isTrackerReady()
            default:
                break
            }
        }
    }
}

