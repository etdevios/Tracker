//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Eduard Tokarev on 08.05.2023.
//

import UIKit

protocol TrackerCollectionViewCellDelegate: AnyObject {
    func didTapDoneButton(of cell: TrackerCollectionViewCell, with tracker: Tracker)
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    static let identifier = "TrackerCollectionViewCell"
    weak var delegate: TrackerCollectionViewCellDelegate?
    
    private var tracker: Tracker?
    
    private lazy var colorView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let trackerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textColor = .white
        return label
    }()
    
    private let emojiView: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 12
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        return label
    }()
    
    private let daysCounterLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .toggleBlackWhiteColor
        return label
    }()
    
    private lazy var plusButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.backgroundColor = colorView.backgroundColor
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 17
        button.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        button.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let pinImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "pin.fill")
        imageView.tintColor = .white
        imageView.isHidden = true
        return imageView
    }()
    
    private var days = 0 {
        didSet {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .currency
            numberFormatter.locale = Locale.current
            daysCounterLabel.text = String.localizedStringWithFormat(
                NSLocalizedString("numberOfDays", comment: "Number of checked days"),
                days
            )
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setCellLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configCell(with tracker: Tracker, days: Int, isDone: Bool, interaction: UIInteraction) {
        self.tracker = tracker
        self.days = tracker.completedDaysCount
        colorView.backgroundColor = tracker.color
        plusButton.backgroundColor = tracker.color
        trackerLabel.text = tracker.text
        emojiView.text = tracker.emoji
        toggleDoneButton(isDone)
        colorView.addInteraction(interaction)
        changePin(for: tracker)
    }
    
    func toggleDoneButton(_ isDone: Bool) {
        if isDone {
            plusButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            plusButton.layer.opacity = 0.3
        } else {
            plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
            plusButton.layer.opacity = 1
        }
    }
    
    private func changePin(for tracker: Tracker) {
        pinImage.isHidden = !tracker.isPinned
    }
    
    func increaseCount() {
        days += 1
    }
    
    func decreaseCount() {
        days -= 1
    }
    
    private func formatDayString(for days: Int) -> String {
        let mod10 = days % 10
        let mod100 = days % 100
        
        if mod100 >= 11 && mod100 <= 19 {
            return "\(days) дней"
        } else if mod10 == 1 {
            return "\(days) день"
        } else if mod10 >= 2 && mod10 <= 4 {
            return "\(days) дня"
        } else {
            return "\(days) дней"
        }
    }
    
    
    private func setCellLayout() {
        [colorView, plusButton, daysCounterLabel].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [trackerLabel, emojiView, pinImage].forEach {
            colorView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        setConstraints()
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorView.heightAnchor.constraint(equalToConstant: 90),
            
            trackerLabel.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 12),
            trackerLabel.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: -12),
            trackerLabel.bottomAnchor.constraint(equalTo: colorView.bottomAnchor, constant: -12),
            
            emojiView.topAnchor.constraint(equalTo: colorView.topAnchor, constant: 12),
            emojiView.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 12),
            emojiView.heightAnchor.constraint(equalToConstant: 24),
            emojiView.widthAnchor.constraint(equalToConstant: 24),
            
            plusButton.topAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 8),
            plusButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            plusButton.heightAnchor.constraint(equalToConstant: 34),
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            
            daysCounterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysCounterLabel.centerYAnchor.constraint(equalTo: plusButton.centerYAnchor),
            
            pinImage.topAnchor.constraint(equalTo: colorView.topAnchor, constant: 18),
            pinImage.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: -12),
            pinImage.heightAnchor.constraint(equalToConstant: 12),
            pinImage.widthAnchor.constraint(equalToConstant: 8)
        ])
        
    }
    
    @objc
    private func plusButtonTapped() {
        guard let tracker else { return }
        delegate?.didTapDoneButton(of: self, with: tracker)
    }
}
