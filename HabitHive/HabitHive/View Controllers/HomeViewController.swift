//
//  HomeViewController.swift
//  HabitHiveTestLogin
//
//  Created by Sebastian Weidlinger on 30.05.21.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getFirstName()
    }

    func getFirstName(){
        let docRef = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid)
        docRef.getDocument{(document, error) in
            if let document = document{
                let property = document.get("firstName")
                UserDefaults.standard.set(property as! String, forKey: "firstName")
            }
        }
    }
    
    @IBAction func ProfileButtonTapped(_ sender: Any) {
        let profileViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.profileViewController) as? ProfileViewController
        let navVC = UINavigationController(rootViewController: profileViewController!)
        navVC.modalPresentationStyle = .fullScreen
        navVC.navigationBar.tintColor = UIColor(red: 238/255.0, green: 190/255.0, blue: 49/255.0, alpha: 1)
        navVC.navigationBar.prefersLargeTitles = true
        present(navVC, animated: true)
    }
}
