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
    var update: (() -> Void)?
    let dispatchGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAchievements()
        dispatchGroup.notify(queue: .main){
            self.collectionView.reloadData()
        }
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
    
    func getAchievements(){
        dispatchGroup.enter()
        let docRef = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid)
        docRef.getDocument{(document, error) in
            if let document = document{
                let property = document.get("achievements")
                self.dataSource = property as! [String]
                self.dispatchGroup.leave()
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print ("Achievement: \(dataSource[indexPath.row])")
    }
}
