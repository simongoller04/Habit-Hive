//
//  AchievementsCollectionViewCell.swift
//  HabitHive
//
//  Created by Sebastian Weidlinger on 11.06.21.
//

import UIKit

class AchievementsCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var achievementNameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    func configure(with achievementName: String) {
        achievementNameLabel.text = achievementName
        let randomNumber = Int.random(in: 0...2)
        switch randomNumber {
        case 0:
            imageView.image = UIImage(named: "Trophy3.png")
        case 1:
            imageView.image = UIImage(named: "Trophy4.png")
            imageView.sizeToFit()
        default:
            imageView.image = UIImage(named: "Trophy2.png")
            imageView.sizeToFit()
        }
    }
}
