//
//  SetTimeViewController.swift
//  HabitHive
//
//  Created by Simon Goller on 16.06.21.
//

import UIKit

protocol SetTimeDelegate {
    func didTapConfirmTime(time: [Int], color: UIColor)
}

class SetTimeViewController: UIViewController {
    var timeString = String()
    var timeArray = [Int]()
    var editHabit = false
    
    public var timeDelegate: SetTimeDelegate?
    @IBOutlet weak var timePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fillArray()
        if editHabit {
            var time = 0.0
            var hour = 0.0
            var minute = 0.0
            hour += Double(timeArray[0] * 10)
            hour += Double(timeArray[1])
            minute += Double(timeArray[2] * 10)
            minute += Double(timeArray[3])
            time = (hour * 3600) + (minute * 60)
            timePicker.countDownDuration = time
        }
        
        let date = Date()
        let dateTimePicker = timePicker.date
        timePicker.setDate(date, animated: true)
        timePicker.setDate(dateTimePicker, animated: true)
        
        timePicker.addTarget(self, action: #selector(timePickerValue(sender:)), for: UIControl.Event.valueChanged)
    }
    
    @objc func timePickerValue(sender: UIDatePicker) {
        timeArray.removeAll()
        let formatter = DateFormatter()
        formatter.dateFormat = "HHmm"
        timeString = formatter.string(from: sender.date)
        for char: Character in timeString {
            timeArray.append(char.wholeNumberValue!)
        }
        timeArray.append(0)
        timeArray.append(0)
    }
    
    func fillArray() {
        timeArray.append(0)
        timeArray.append(0)
        timeArray.append(0)
        timeArray.append(1)
        timeArray.append(0)
        timeArray.append(0)
    }
    
    //Sending the Value of the Datepicker in an Integer Array to the createHabitVC or editHabitVC 
    @IBAction func confirmButton(_ sender: Any) {
        timeDelegate?.didTapConfirmTime(time: timeArray, color: UIColor(red: 252/255.0, green: 190.0/255.0, blue: 44.0/255.0, alpha: 1))
        dismiss(animated: true, completion: nil)
    }
}
