//
//  TabBarViewController.swift
//  HabitHive
//
//  Created by Sebastian Weidlinger on 25.06.21.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setUp()
    }
    
    func setUp() {
        let profileViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.profileViewController) as? ProfileViewController
        let navVC = UINavigationController(rootViewController: profileViewController!)
        navVC.modalPresentationStyle = .fullScreen
        navVC.navigationBar.tintColor = UIColor(red: 252/255.0, green: 190.0/255.0, blue: 44.0/255.0, alpha: 1)
        navVC.navigationBar.prefersLargeTitles = true
        
        let homeVC = storyboard?.instantiateViewController(identifier: "homeVC") as? HabitCollectionViewController
        let navHomeVC = UINavigationController(rootViewController: homeVC!)
        navHomeVC.modalPresentationStyle = .fullScreen
        navHomeVC.title = "Habit Hive"
        navHomeVC.navigationBar.tintColor = UIColor(red: 252/255.0, green: 190.0/255.0, blue: 44.0/255.0, alpha: 1)
        navHomeVC.navigationBar.prefersLargeTitles = true
       
        self.setViewControllers([navHomeVC, navVC], animated: false)
        self.tabBar.tintColor = UIColor(red: 252/255.0, green: 190.0/255.0, blue: 44.0/255.0, alpha: 1)
    }

}
