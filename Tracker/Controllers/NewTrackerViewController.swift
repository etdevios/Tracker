//
//  NewTrackerViewController.swift
//  Tracker
//
//  Created by Eduard Tokarev on 09.05.2023.
//

import UIKit

protocol NewTrackerViewControllerDelegate: AnyObject {
    func addNewTrackerCategory(_ newTrackerCategory: TrackerCategory)
}

final class NewTrackerViewController: UIViewController {
    weak var delegate: NewTrackerViewControllerDelegate?
    var typeOfNewTracker: TypeTracker?
    private var heightTableView: CGFloat = 74
    private var currentCategory: String?
    private var trackerText = ""
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .trBlack
        switch typeOfNewTracker {
        case .habitTracker: label.text = "Новая привычка"
        case .eventTracker: label.text = "Новое нерегулярное событие"
        case .none: break
        }
        return label
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.clearButtonMode = .whileEditing
        let leftInsetView = UIView(frame: CGRect(x: 0, y: 0, width: 17, height: 30))
        textField.leftView = leftInsetView
        textField.leftViewMode = .always
        textField.backgroundColor = .trBackground
        textField.layer.cornerRadius = 16
        textField.clipsToBounds = true
        textField.delegate = self
        return textField
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .trBackground
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = .trGray
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.trRed, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .trWhite
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.trRed.cgColor
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.trWhite, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .trGray
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .trWhite
        addSubviews()
        addConstraints()
    }
    
    func addSubviews() {
        [titleLabel,textField, tableView, saveButton, cancelButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    func addConstraints() {
        switch typeOfNewTracker {
        case .habitTracker: heightTableView = 149
        case .eventTracker: heightTableView = 74
        case .none: break
        }
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -32),
            
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: heightTableView),
            
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cancelButton.trailingAnchor.constraint(equalTo: saveButton.leadingAnchor, constant: -8),
            cancelButton.heightAnchor.constraint(equalToConstant: 50),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            saveButton.heightAnchor.constraint(equalTo: cancelButton.heightAnchor),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.centerYAnchor.constraint(equalTo: cancelButton.centerYAnchor),
            saveButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor)
        ])
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        delegate?.addNewTrackerCategory(TrackerCategory(title: "Новая категория", trackers: [Tracker(id: UUID(), text: trackerText, emoji: "❤️", color: .trRed, schedule: nil)]))
        
        dismiss(animated: true)
    }
}

extension NewTrackerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch typeOfNewTracker {
        case .habitTracker: return 2
        case .eventTracker: return 1
        case .none: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.detailTextLabel?.textColor = .trGray
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Категория"
            cell.detailTextLabel?.text = currentCategory
        case 1:
            cell.textLabel?.text = "Расписание"
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

extension NewTrackerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        trackerText = textField.text ?? ""
        textField.resignFirstResponder()
        return true
    }
}

extension NewTrackerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            break
        case 1:
            let scheduleVC = ScheduleViewController()
            present(scheduleVC, animated: true)
        default: break
        }
    }
}