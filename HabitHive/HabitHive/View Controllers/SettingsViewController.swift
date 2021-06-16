//
//  SettingsViewController.swift
//  HabitHive
//
//  Created by Sebastian Weidlinger on 31.05.21.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var navigationBarTitle: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    @IBAction func darkModeSwitch(_ sender: Any) {
        if darkModeSwitch.isOn == true{
            //navigationBarTitle.title = "test"
            overrideUserInterfaceStyle = .dark
            self.navigationController?.title = "Test"
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        }
        else{
            overrideUserInterfaceStyle = .light
        }
    }
}
