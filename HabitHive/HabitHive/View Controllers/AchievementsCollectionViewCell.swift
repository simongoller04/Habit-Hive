//
//  AchievementsCollectionViewCell.swift
//  HabitHive
//
//  Created by Sebastian Weidlinger on 11.06.21.
//

import UIKit

class AchievementsCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var achievementNameLabel: UILabel!
    
    func configure(with achievementName: String){
        achievementNameLabel.text = achievementName
    }
}
