//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Eduard Tokarev on 08.05.2023.
//

import UIKit

protocol TrackerCollectionViewCellDelegate: AnyObject {
    func plusButtonTapped(cell: TrackerCollectionViewCell)
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    static let identifier = "TrackerCollectionViewCell"
    weak var delegate: TrackerCollectionViewCellDelegate?
    
    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.backgroundColor = .trRed
        return view
    }()
    
    private let numberOfDayLabel: UILabel = {
        let label = UILabel()
        label.textColor = .trBlack
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "0 Дней"
        return label
    }()
    
    private let plusButton: UIButton = {
        let button = UIButton()
        button.setTitle("+", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 34 / 2
        button.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        button.backgroundColor = .trRed
        return button
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.backgroundColor = .trBackground
        label.textAlignment = .center
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.text = "🍏"
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "Поливать растения"
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubviews()
        addViewConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configCell(tracker: Tracker) {
        nameLabel.text = tracker.text
        emojiLabel.text = tracker.emoji
        colorView.backgroundColor = tracker.color
        plusButton.backgroundColor = tracker.color
    }
    
    func configRecord(countDays: Int, isDoneToday: Bool) {
        let title = isDoneToday ? "✓" : "+"
        plusButton.setTitle(title, for: .normal)
        
        let opacity: Float = isDoneToday ? 0.3 : 1
        plusButton.layer.opacity = opacity
        
        numberOfDayLabel.text = "\(countDays) Дней"
    }
    
    @objc private func plusButtonTapped() {
        delegate?.plusButtonTapped(cell: self)
    }
    
    private func addSubviews() {
        [colorView, numberOfDayLabel, plusButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        [emojiLabel, nameLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            colorView.addSubview($0)
        }
    }
    
    private func addViewConstraints() {
        let space: CGFloat = 12
        
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -42),
            
            numberOfDayLabel.centerYAnchor.constraint(equalTo: plusButton.centerYAnchor),
            numberOfDayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: space),
            
            plusButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -space),
            plusButton.topAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 8),
            plusButton.heightAnchor.constraint(equalToConstant: 34),
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            
            emojiLabel.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: space),
            emojiLabel.topAnchor.constraint(equalTo: colorView.topAnchor, constant: space),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            
            nameLabel.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: space),
            nameLabel.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: -space),
            nameLabel.bottomAnchor.constraint(equalTo: colorView.bottomAnchor, constant: -space),
            
        ])
    }
}
