//
//  EditHabitViewController.swift
//  HabitHive
//
//  Created by Sebastian Weidlinger on 02.07.21.
//

import UIKit
import Firebase
import FirebaseAuth

class EditHabitViewController: UIViewController {
    //Colorpicker Buttons
    @IBOutlet weak var purpleButton: UIButton!
    @IBOutlet weak var grayButton: UIButton!
    @IBOutlet weak var yellowButton: UIButton!
    @IBOutlet weak var orangeButton: UIButton!
    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var blueButton: UIButton!
    
    @IBOutlet weak var habitName: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var timedHabit: UIButton!
    @IBOutlet weak var countedHabit: UIButton!
    @IBOutlet weak var colorPickerButton: UIButton!
    var update: (() -> Void)?
    var isCounted: Bool = false
    var valueCounter = 0
    var timeArray = [Int]()
    
    var habit = Habit(name: "", color: 0, counted: true, goal: 0, currentCount: 0, time: [Int](), timeOriginal: [Int](), addFirebase: false, streak: 0, habitNumber: 0, finishedFirstTime: false)
    var indexPath = IndexPath()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addCornerRadius()
        rotateHexagon()
        habitName.becomeFirstResponder()
        valueCounter = habit.goal
        
        if (habit.counted) {
            countedHabit.backgroundColor = UIColor(red: 252/255.0, green: 190.0/255.0, blue: 44.0/255.0, alpha: 1)
            timedHabit.backgroundColor = UIColor.systemGray4
            countedHabit.setTitle("Amount: \(habit.goal)", for: .normal)
            timedHabit.setTitle("Timed", for: .normal)
        }
        else {
            timedHabit.backgroundColor = UIColor(red: 252/255.0, green: 190.0/255.0, blue: 44.0/255.0, alpha: 1)
            countedHabit.setTitle("Counted", for: .normal)
            timedHabit.setTitle("\(habit.time[0])\(habit.time[1]):\(habit.time[2])\(habit.time[3])", for: .normal)
        }
        
        let current = habit.color
        
        var color = UIColor()
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
        UserDefaults().setValue(current, forKey: "sectionColor")
        colorPickerButton.layer.cornerRadius = 10
        colorPickerButton.tintColor = color
        errorLabel.isHidden = true
        self.title = "Edit your Habit"
        habitName.text = habit.name
        tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func blueButtonPressed(_ sender: Any) {
        UserDefaults.standard.setValue(1, forKey: "sectionColor")
        colorPickerButton.tintColor = blueButton.tintColor
    }
    
    @IBAction func greenButtonPressed(_ sender: Any) {
        UserDefaults.standard.setValue(2, forKey: "sectionColor")
        colorPickerButton.tintColor = greenButton.tintColor
    }
    
    @IBAction func yellowButtonPressed(_ sender: Any) {
        UserDefaults.standard.setValue(3, forKey: "sectionColor")
        colorPickerButton.tintColor = yellowButton.tintColor
    }
    
    @IBAction func orangeButtonPressed(_ sender: Any) {
        UserDefaults.standard.setValue(4, forKey: "sectionColor")
        colorPickerButton.tintColor = orangeButton.tintColor
    }
    
    @IBAction func purpleButtonPressed(_ sender: Any) {
        UserDefaults.standard.setValue(5, forKey: "sectionColor")
        colorPickerButton.tintColor = purpleButton.tintColor
    }
    
    @IBAction func grayButtonPressed(_ sender: Any) {
        UserDefaults.standard.setValue(6, forKey: "sectionColor")
        colorPickerButton.tintColor = grayButton.tintColor
    }
    
    func rotateHexagon() {
        blueButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        yellowButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        greenButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        orangeButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        purpleButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        grayButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        colorPickerButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
    }
    
    func addCornerRadius() {
        blueButton.layer.cornerRadius = 10
        yellowButton.layer.cornerRadius = 10
        greenButton.layer.cornerRadius = 10
        orangeButton.layer.cornerRadius = 10
        purpleButton.layer.cornerRadius = 10
        grayButton.layer.cornerRadius = 10
    }
    
    @IBAction func editHabit(_ sender: Any) {
        if habitName.hasText {
            if (habitName.text?.count)! < 24{
                let editHabit = Habit(name: habitName.text ?? "", color: UserDefaults().value(forKey: "sectionColor") as! Int, counted: habit.counted, goal: valueCounter, currentCount: 0, time: habit.time, timeOriginal: habit.time, addFirebase: true, streak: habit.streak, habitNumber: habit.habitNumber, finishedFirstTime: habit.finishedFirstTime)
                
                Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).collection("habits").document("habit\(indexPath.row)").updateData(["name": editHabit.name, "color": UserDefaults().value(forKey: "sectionColor")!, "counted": editHabit.counted, "goal": valueCounter, "currentCount": editHabit.currentCount, "timeArray": editHabit.time, "addFirebase": editHabit.addFirebase, "streak": editHabit.streak, "timeArrayOriginal": editHabit.timeOriginal])
                
                self.update?()
                self.errorLabel.isHidden = true
                self.navigationController?.popViewController(animated: true)
            } else{
                errorLabel.isHidden = false
                errorLabel.text = "Your Habit name is too long!"
            }
        }
        else {
            errorLabel.isHidden = false
            errorLabel.text = "Your Habit needs a name!"
        }
    }
    
    @IBAction func timedButtonTapped(_ sender: Any) {
        let timeVC = storyboard?.instantiateViewController(withIdentifier: "SetTimeVC") as! SetTimeViewController
        timeVC.timeDelegate = self
        timeVC.editHabit = true
        timeVC.timeArray = habit.time
        present(timeVC, animated: true, completion: nil)
    }
    
    @IBAction func countedButtonTapped(_ sender: Any) {
        let amountVC = storyboard?.instantiateViewController(withIdentifier: "SetAmountVC") as! SetAmountViewController
        amountVC.amountDelegate = self
        amountVC.value = Double (habit.goal)
        amountVC.editHabit = true
        present(amountVC, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
}

extension EditHabitViewController: SetAmountDelegate, SetTimeDelegate {
    
    func didTapConfirmAmount(amount: Int, color: UIColor) {
        valueCounter = amount
        habit.counted = true
        countedHabit.setTitle("Amount: \(amount)", for: .normal)
        timedHabit.setTitle("Timed", for: .normal)
        countedHabit.backgroundColor = color
        isCounted = true
        timedHabit.backgroundColor = .systemGray4
    }
    
    func didTapConfirmTime(time: [Int], color: UIColor) {
        timeArray = time
        habit.counted = false
        habit.time = time
        countedHabit.backgroundColor = .systemGray4
        timedHabit.backgroundColor = color
        countedHabit.setTitle("Counted", for: .normal)
        isCounted = false
        timedHabit.setTitle("\(timeArray[0])\(timeArray[1]):\(timeArray[2])\(timeArray[3])", for: .normal)
    }
}
