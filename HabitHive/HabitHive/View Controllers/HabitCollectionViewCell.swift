//
//  HabitCollectionViewCell.swift
//  HabitHive
//
//  Created by Sebastian Weidlinger on 29.06.21.
//

import UIKit

class HabitCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var habitNameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    func configure(with habitName: String) {
        habitNameLabel.text = habitName
        
        let randomNumber = Int.random(in: 0...2)
        switch randomNumber {
        case 0:
            imageView.tintColor = UIColor.systemGray
        case 1:
            imageView.tintColor = UIColor.systemBlue
        default:
            imageView.tintColor = UIColor.systemYellow
        }
        imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
    }
}
