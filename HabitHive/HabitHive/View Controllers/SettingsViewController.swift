//
//  SettingsViewController.swift
//  HabitHive
//
//  Created by Sebastian Weidlinger on 31.05.21.
//

import UIKit
import Firebase
import FirebaseAuth

class SettingsViewController: UIViewController {
    @IBOutlet weak var navigationBarTitle: UINavigationItem!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func signOutButtonTapped(_ sender: Any) {
        do {
            errorLabel.isHidden = true
            try Auth.auth().signOut()
            let navVC = self.storyboard?.instantiateViewController(identifier: "NavigationVC")
            self.present(navVC!, animated: true, completion: nil)
        } catch {
            errorLabel.isHidden = false
        }
    }
}
