//
//  HomeViewController.swift
//  HabitHiveTestLogin
//
//  Created by Sebastian Weidlinger on 30.05.21.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var logOutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func logOutButtonTapped(_ sender: Any) {
        
        let loginViewController =
            self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.loginViewController) as? LoginViewController
     
        self.view.window?.rootViewController = loginViewController
        self.view.window?.makeKeyAndVisible()
    }
    
}
