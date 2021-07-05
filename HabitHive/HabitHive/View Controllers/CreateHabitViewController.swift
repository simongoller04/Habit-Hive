//
//  CreateHabitViewController.swift
//  HabitHive
//
//  Created by Sebastian Weidlinger on 31.05.21.
//
import Firebase
import UIKit
import FirebaseAuth

class CreateHabitViewController: UIViewController {
    
    var userDefaults = UserDefaults.standard
    var update: (() -> Void)?
    var timeArray = [Int]()
    
    @IBOutlet weak var errorLabel: UILabel!
    var valueCounter = 0
    var isCounted: Bool = false
    var habitCounter = 0
    var typeOfHabitSelected = false
    
    //Colorpicker Buttons
    @IBOutlet weak var purpleButton: UIButton!
    @IBOutlet weak var grayButton: UIButton!
    @IBOutlet weak var yellowButton: UIButton!
    @IBOutlet weak var orangeButton: UIButton!
    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var blueButton: UIButton!
    
    
    @IBOutlet weak var timedHabit: UIButton!
    @IBOutlet weak var countedHabit: UIButton!
    @IBOutlet weak var colorPickerButton: UIButton!
    
    @IBOutlet weak var errorLabelType: UILabel!
    @IBOutlet weak var addHabit: UIButton!
    @IBOutlet weak var habitName: UITextField!
    
    
    let dispatchGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addCornerRadius()
        rotateHexagon()
        habitName.becomeFirstResponder()
        
        let current = UserDefaults().integer(forKey: "sectionColor")
        
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
        errorLabel.isHidden = true
        colorPickerButton.layer.cornerRadius = 10
        colorPickerButton.tintColor = color
        errorLabelType.isHidden = true
        self.title = "Create a new Habit"
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
    
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func colorPickerButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func timedButtonTapped(_ sender: Any) {
        let timeVC = storyboard?.instantiateViewController(withIdentifier: "SetTimeVC") as! SetTimeViewController
        timeVC.timeDelegate = self
        present(timeVC, animated: true, completion: nil)
    }
    
    @IBAction func countedButtonTapped(_ sender: Any) {
        let amountVC = storyboard?.instantiateViewController(withIdentifier: "SetAmountVC") as! SetAmountViewController
        amountVC.amountDelegate = self
        present(amountVC, animated: true, completion: nil)
    }
    
    @IBAction func addHabitButtonTapped(_ sender: Any) {
        if typeOfHabitSelected{
            if habitName.hasText {
                if (habitName.text?.count)! < 24{
                    let newHabit = Habit(name: habitName.text ?? "", color: UserDefaults().value(forKey: "sectionColor") as? Int ?? 6, counted: isCounted, goal: valueCounter, currentCount: valueCounter, time: timeArray, timeOriginal: timeArray, addFirebase: true, streak: 0, habitNumber: 0, finishedFirstTime: true)
                    
                    let habitCounterRef = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid)
                    habitCounterRef.getDocument{(document, error) in
                        if let document = document {
                            self.habitCounter = document.get("habitCounter") as! Int
                        }
                        
                        //to fix bug with counted habits when timed
                        if (newHabit.counted){
                            self.timeArray.append(0)
                            self.timeArray.append(0)
                            self.timeArray.append(0)
                            self.timeArray.append(0)
                            self.timeArray.append(0)
                            self.timeArray.append(0)
                        }
                        
                        Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).collection("habits").document("habit\(self.habitCounter)").setData(["name": newHabit.name, "color": newHabit.color, "counted": newHabit.counted, "goal": newHabit.goal, "currentCount": 0, "addFirebase": true, "streak": 0, "timeArray": self.timeArray, "timeArrayOriginal": self.timeArray])
                        
                        habitCounterRef.updateData(["habitCounter": self.habitCounter + 1])
                        
                        self.update?()
                        self.errorLabel.isHidden = true
                        self.navigationController?.popViewController(animated: true)
                    }
                } else{
                    errorLabelType.isHidden = true
                    errorLabel.isHidden = false
                    errorLabel.text = "Your Habit name is too long!"
                }
            }else {
                errorLabelType.isHidden = true
                errorLabel.isHidden = false
                errorLabel.text = "Your Habit needs a name!"
            }
        }
        else{
            errorLabel.isHidden = true
            errorLabelType.isHidden = false
        }
    }
}

extension CreateHabitViewController: SetAmountDelegate, SetTimeDelegate {
    
    func didTapConfirmAmount(amount: Int, color: UIColor) {
        valueCounter = amount
        countedHabit.setTitle("Amount: \(amount)", for: .normal)
        timedHabit.setTitle("Timed", for: .normal)
        countedHabit.backgroundColor = color
        timedHabit.backgroundColor = .systemGray4
        typeOfHabitSelected = true
        isCounted = true
    }
    
    func didTapConfirmTime(time: [Int], color: UIColor) {
        timeArray = time
        countedHabit.backgroundColor = .systemGray4
        countedHabit.setTitle("Counted", for: .normal)
        timedHabit.setTitle("\(timeArray[0])\(timeArray[1]):\(timeArray[2])\(timeArray[3])", for: .normal)
        timedHabit.backgroundColor = color
        typeOfHabitSelected = true
        isCounted = false
    }
}


