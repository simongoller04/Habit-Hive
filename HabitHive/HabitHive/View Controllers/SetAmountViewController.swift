//
//  SetAmountViewController.swift
//  HabitHive
//
//  Created by Simon Goller on 15.06.21.
//

import UIKit

protocol SetAmountDelegate {
    func didTapConfirmAmount(amount: Int, color: UIColor)
}

class SetAmountViewController: UIViewController {
    var value = 0.0
    var amountDelegate: SetAmountDelegate?
    var editHabit = false
    
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var amountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if editHabit{
            stepper.value = value
            amountLabel.text = String (Int (value))
        }
    }
    
    @IBAction func step(_ sender: Any) {
        amountLabel.text = String (Int (stepper.value))
    }
    
    //Sending the Value of the Stepper to the createHabitVC or editHabitVC 
    @IBAction func confirmButtonTapped(_ sender: Any) {
        amountDelegate?.didTapConfirmAmount(amount: Int(stepper.value), color: UIColor(red: 252/255.0, green: 190.0/255.0, blue: 44.0/255.0, alpha: 1))
        dismiss(animated: true, completion: nil)
    }
}
