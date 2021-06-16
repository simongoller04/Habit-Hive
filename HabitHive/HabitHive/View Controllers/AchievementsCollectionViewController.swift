//
//  AchievementsCollectionViewController.swift
//  HabitHive
//
//  Created by Sebastian Weidlinger on 11.06.21.
//

import UIKit
import FirebaseAuth
import Firebase

class AchievementsCollectionViewController: UICollectionViewController {
    
    var dataSource: [String] = [""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return dataSource.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell =  UICollectionViewCell()
        
        if let achievementCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? AchievementsCollectionViewCell{
            achievementCell.configure(with: dataSource[indexPath.row])
            
            cell = achievementCell
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
        print ("Achievement: \(dataSource[indexPath.row])")
    }
}
