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
    var achievements: [String] = [""]
    var numberForAchievement = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAchievements()
        firstNameLabel.text = UserDefaults.standard.string(forKey: "firstName")
    }
    
    func getAchievements(){
        let docRef = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid)
        docRef.getDocument{(document, error) in
            if let document = document{
                let property = document.get("achievements")
                self.achievements = property as! [String]
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "achievements"{
            getAchievements()
            let vc = segue.destination as! AchievementsCollectionViewController
            vc.dataSource = self.achievements
        }
    }
    
    func addAchievement(){
        let ref = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid)
        ref.updateData(["achievements": FieldValue.arrayUnion(["\(numberForAchievement)"])])
        numberForAchievement = numberForAchievement + 1
    }
    
    @IBAction func addAchievementButtonTapped(_ sender: Any) {
        addAchievement()
    }
}
