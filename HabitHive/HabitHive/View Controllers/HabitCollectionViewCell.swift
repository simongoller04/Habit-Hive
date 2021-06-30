//
//  HabitCollectionViewCell.swift
//  HabitHive
//
//  Created by Sebastian Weidlinger on 29.06.21.
//

import UIKit

class HabitCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var habitNameLabel: UILabel!
    @IBOutlet private weak var habitCountLabel: UILabel!
    @IBOutlet private weak var streakLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    
    func configure(with habit: Habit) {
        habitNameLabel.text = habit.name
        habitCountLabel.text = "\(habit.currentCount)/\(habit.goal)"
        streakLabel.text = "Streak: \(habit.streak)"
        var color = UIColor()
        let current = habit.color
        switch current{
        case 1:
            color = UIColor.systemBlue
        case 2:
            color = UIColor.systemGreen
        case 3:
            color = UIColor.systemYellow
        case 4:
            color = UIColor.systemOrange
        case 5:
            color = UIColor.systemPurple
        default:
            color = UIColor.systemGray
        }
        imageView.tintColor = color
        imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
    }
}
