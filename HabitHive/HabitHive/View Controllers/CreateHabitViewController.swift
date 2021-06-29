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
    var color: Int
    //    var timed: UIDatePicker?  wie?
    var counted: Int?
    var addToCalendar: Bool
    var remindMe: Bool
    
    init(name: String, color: Int, counted: Int?, addToCalendar: Bool, remindMe: Bool) {
        self.name = name
        self.color = color
        self.counted = counted
        self.addToCalendar = addToCalendar
        self.remindMe = remindMe
        
    }
}

class CreateHabitViewController: UIViewController {
    
    var userDefaults = UserDefaults.standard
    
    var valueCounter = 0
    var isCounted: Bool = false
    var habitCounter = 8
    //    var timer
    
    @IBOutlet weak var timedHabit: UIButton!
    @IBOutlet weak var countedHabit: UIButton!
    @IBOutlet weak var colorPickerButton: UIButton!
    
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
    let dispatchGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        colorPickerButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        
        var color = UIColor()
        let current = UserDefaults().integer(forKey: "sectionColor")
        switch current{
        case 1:
            color = UIColor.systemBlue
        case 2:
            color = UIColor.systemGreen
        case 3:
            color = UIColor.systemYellow
        case 4:
            color = UIColor.systemOrange
        case 5:
            color = UIColor.systemPurple
        default:
            color = UIColor.systemGray
        }
        colorPickerButton.layer.cornerRadius = 10
        colorPickerButton.tintColor = color
        
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func colorPickerButtonTapped(_ sender: Any) {
        let colorVC = storyboard?.instantiateViewController(withIdentifier: "colorPickerVC") as! SectionColorViewController
        colorVC.colorDelegate = self
        present(colorVC, animated: true, completion: nil)
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
    
    @IBAction func addHabitButtonTapped(_ sender: Any) {
        let newHabit = newHabit(name: habitName.text ?? "new Habit", color: UserDefaults().integer(forKey: "sectionColor") ,counted: valueCounter, addToCalendar: externalCalendar.isOn, remindMe: remindeMe.isOn)
        
        let habitCounterRef = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid)
        habitCounterRef.getDocument{(document, error) in
            if let document = document {
                print("before: \(self.habitCounter)")
                print(document.get("habitCounter") as! Int)
                self.habitCounter = document.get("habitCounter") as! Int
                print("after: \(self.habitCounter)")
            }
            Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).collection("habits").document("habit\(self.habitCounter)").setData(["name": newHabit.name, "color": UserDefaults().value(forKey: "sectionColor")!, "counted": self.isCounted, "goal": newHabit.counted!, "externalCalendar": true, "remindeMe": self.remindeMe.isOn])
            
            habitCounterRef.updateData(["habitCounter": self.habitCounter + 1])
            
            self.navigationController?.popViewController(animated: true)
//            let habitVC = self.storyboard?.instantiateViewController(withIdentifier: "homeVC") as! HabitCollectionViewController
//            habitVC.modalPresentationStyle = .fullScreen
//            self.present(habitVC, animated: true, completion: nil)
        }
    }
}

extension CreateHabitViewController: SetAmountDelegate, SetTimeDelegate, GetColorDelegate {
    
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
    
    func didTapColorPickerButton (color: UIColor){
        colorPickerButton.tintColor = color
    }
    
}


