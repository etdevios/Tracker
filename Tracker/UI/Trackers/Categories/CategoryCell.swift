//
//  CategoryCell.swift
//  Tracker
//
//  Created by Eduard Tokarev on 27.07.2023.
//

import UIKit

final class CategoryCell: UITableViewCell {
    static let identifier = "CategoryCell"
    
    private let checkmarkImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark")
        imageView.isHidden = true
        return imageView
    }()
    
    private var label: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupContent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            checkmarkImage.isHidden = false
        } else {
            checkmarkImage.isHidden = true
        }
    }
    
    func configCell(with label: String) {
        self.label.text = label
    }
    
    private func setupContent() {
        selectionStyle = .none
        contentView.backgroundColor = .trBackground
        
        [label, checkmarkImage].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 27),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -26),
            label.trailingAnchor.constraint(equalTo: checkmarkImage.leadingAnchor, constant: -6),
            
            checkmarkImage.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            checkmarkImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
}
