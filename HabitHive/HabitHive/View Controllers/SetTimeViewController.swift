//
//  SetTimeViewController.swift
//  HabitHive
//
//  Created by Simon Goller on 16.06.21.
//

import UIKit

protocol SetTimeDelegate {
    func didTapConfirmTime(time: UIDatePicker, color: UIColor)
}

class SetTimeViewController: UIViewController {
    
    var timeDelegate: SetTimeDelegate?

    @IBOutlet weak var timePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
       
    @IBAction func confirmButton(_ sender: Any) {
        timeDelegate?.didTapConfirmTime(time: timePicker, color: UIColor(red: 252/255.0, green: 190.0/255.0, blue: 44.0/255.0, alpha: 1))
        dismiss(animated: true, completion: nil)
    }
}
