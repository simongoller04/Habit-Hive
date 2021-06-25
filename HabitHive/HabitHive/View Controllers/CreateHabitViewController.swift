//
//  CreateHabitViewController.swift
//  HabitHive
//
//  Created by Sebastian Weidlinger on 31.05.21.
//
import Firebase
import UIKit
import FirebaseAuth

class newHabit: NSObject {
    var name: String
    var color: UIColor
    //    var timed: UIDatePicker?  wie?
    var counted: Int?
    var addToCalendar: Bool
    var remindMe: Bool
    var shareWithHive: Bool
    
    init(name: String, color: UIColor, counted: Int?, addToCalendar: Bool, remindMe: Bool, shareWithHive: Bool) {
        self.name = name
        self.color = color
        self.counted = counted
        self.addToCalendar = addToCalendar
        self.remindMe = remindMe
        self.shareWithHive = shareWithHive
        
    }
}

class CreateHabitViewController: UIViewController, UIColorPickerViewControllerDelegate {
    
    var userDefaults = UserDefaults.standard
    
    var valueCounter = 0
    var isCounted: Bool = false
    var habitCounter = 8
    //    var timer
    
    @IBOutlet weak var timedHabit: UIButton!
    @IBOutlet weak var countedHabit: UIButton!
    
    @IBOutlet weak var addHabit: UIButton!
    @IBOutlet weak var habitName: UITextField!
    @IBOutlet weak var habitColor: UIButton!
    
    // Reminder Days
    @IBOutlet weak var mondayReminder: UIButton!
    @IBOutlet weak var tuesdayReminder: UIButton!
    @IBOutlet weak var wednesdayReminder: UIButton!
    @IBOutlet weak var thursdayReminder: UIButton!
    @IBOutlet weak var fridayReminder: UIButton!
    @IBOutlet weak var saturdayReminder: UIButton!
    @IBOutlet weak var sundayReminder: UIButton!
    
    // Switches
    @IBOutlet weak var externalCalendar: UISwitch!
    @IBOutlet weak var remindeMe: UISwitch!
    @IBOutlet weak var shareHive: UISwitch!
    let dispatchGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // adds Action to habitColor Button
        habitColor.addTarget(self, action: #selector(colorPicker), for: .touchUpInside)
        
    }
    
    @objc private func colorPicker (){
        let colorPickerVC = UIColorPickerViewController()
        colorPickerVC.delegate = self
        present(colorPickerVC, animated: true)
    }
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        let color = viewController.selectedColor
        habitColor.backgroundColor = color
        //            add color to variable
    }
    
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        let color = viewController.selectedColor
        habitColor.backgroundColor = color
        //            add color to variable
    }
    
    @IBAction func timedButtonTapped(_ sender: Any) {
        let timeVC = storyboard?.instantiateViewController(withIdentifier: "SetTimeVC") as! SetTimeViewController
        timeVC.timeDelegate = self
        isCounted = false
        present(timeVC, animated: true, completion: nil)
    }
    
    @IBAction func countedButtonTapped(_ sender: Any) {
        let amountVC = storyboard?.instantiateViewController(withIdentifier: "SetAmountVC") as! SetAmountViewController
        amountVC.amountDelegate = self
        isCounted = true
        present(amountVC, animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addHabitButtonTapped(_ sender: Any) {
        let newHabit = newHabit(name: habitName.text ?? "new Habit", color: habitColor.backgroundColor ?? .orange, counted: valueCounter, addToCalendar: externalCalendar.isOn, remindMe: remindeMe.isOn, shareWithHive: shareHive.isOn)
        
        let habitCounterRef = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid)
        habitCounterRef.getDocument{(document, error) in
            if let document = document {
                print("before: \(self.habitCounter)")
                print(document.get("habitCounter") as! Int)
                self.habitCounter = document.get("habitCounter") as! Int
                print("after: \(self.habitCounter)")
            }
            Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).collection("habits").document("habit\(self.habitCounter)").setData(["name": newHabit.name, "color": 5, "counted": self.isCounted, "goal": newHabit.counted!, "externalCalendar": self.shareHive.isOn, "remindeMe": self.remindeMe.isOn, "share": self.shareHive.isOn])
            
            habitCounterRef.updateData(["habitCounter": self.habitCounter + 1])
            print("huso")
            
            let homeScreen = self.storyboard?.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarViewController
            homeScreen.modalPresentationStyle = .fullScreen
            self.present(homeScreen, animated: true, completion: nil)
        }
    }
}

extension CreateHabitViewController: SetAmountDelegate, SetTimeDelegate {
    
    func didTapConfirmAmount(amount: Int, color: UIColor) {
        valueCounter = amount
        countedHabit.backgroundColor = color
        timedHabit.backgroundColor = .systemGray5
    }
    
    func didTapConfirmTime(time: UIDatePicker, color: UIColor) {
        //        timer = time
        countedHabit.backgroundColor = .systemGray5
        timedHabit.backgroundColor = color
    }
}


