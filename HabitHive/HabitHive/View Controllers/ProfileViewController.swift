//
//  ProfileViewController.swift
//  HabitHive
//
//  Created by Sebastian Weidlinger on 31.05.21.
//

import UIKit
import Firebase
import FirebaseAuth

class ProfileViewController: UIViewController {
    @IBOutlet weak var firstNameLabel: UILabel!
    var numberForAchievement = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstNameLabel.text = UserDefaults.standard.string(forKey: "firstName")
    }
    
    func addAchievement(){
        let ref = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid)
        ref.updateData(["achievements": FieldValue.arrayUnion(["\(numberForAchievement)"])])
        numberForAchievement = numberForAchievement + 1
    }
    
    @IBAction func addAchievementButtonTapped(_ sender: Any) {
        addAchievement()
    }
    @IBAction func achievementButtonTapped(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(identifier: "AchievementsCollectionViewController") as! AchievementsCollectionViewController
        navigationController?.pushViewController(vc, animated: true)
    }
}
