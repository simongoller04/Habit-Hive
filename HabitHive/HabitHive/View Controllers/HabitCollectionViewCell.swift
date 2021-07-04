//
//  HabitCollectionViewCell.swift
//  HabitHive
//
//  Created by Sebastian Weidlinger on 29.06.21.
//

import UIKit
import Firebase
import FirebaseAuth

protocol TimerFinishedDelegate {
    func showAlert(cell: HabitCollectionViewCell, indexPathCell: IndexPath)
}

class HabitCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var habitNameLabel: UILabel!
    @IBOutlet weak var habitCountLabel: UILabel!
    @IBOutlet weak var streakLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var checkMarkImage: UIImageView!
    
    //Timer variables
    var timer = Timer()
    var timeDisplayedHour = 0
    var timeDisplayedMinute = 0
    var timeDisplayedSecond = 0
    var timeDisplayedHourPrev = 0
    var timeDisplayedMinutePrev = 0
    var timeDisplayedSecondPrev = 0
    var startVar = false
    var timeArray = [Int]()
    var timeArrayFirebase: Any?
    
    var counted: Bool?
    
    //delegate
    var habitCell: Habit?
    public var timerDelegate: TimerFinishedDelegate?
    var indexPathCell: IndexPath?
    
    
    func configure(with habit: Habit) {
        habitCell = habit
        habitNameLabel.text = habit.name
        habitCountLabel.text = "\(habit.currentCount)/\(habit.goal)"
        streakLabel.text = "Streak: \(habit.streak)"
        habitNameLabel.isHidden = false
        deleteButton.isHidden = true
        editButton.isHidden = true
        habitCountLabel.isHidden = false
        streakLabel.isHidden = false
        timerLabel.isHidden = true
        checkMarkImage.isHidden = true
        var color = UIColor()
        let current = habit.color
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
        imageView.tintColor = color
        imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        
        if habit.counted {
            habitCountLabel.text = "\(habit.currentCount)/\(habit.goal)"
        } else {
            let dispatchGroupStart = DispatchGroup()
            fetchTimeFromFirebase(indexPath: indexPathCell!, dispatchGroup: dispatchGroupStart)
        }
        if (!habit.addFirebase) {
            checkMarkImage.isHidden = false
        }
    }
    
    func startCountdown(CV: UICollectionView, index: IndexPath, start: Bool) {
        self.startVar = start
        let dispatchGroupCountdown = DispatchGroup()
        if self.startVar == true {
            self.fetchTimeFromFirebase(indexPath: index, dispatchGroup: dispatchGroupCountdown)
            dispatchGroupCountdown.notify(queue: .main){
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.Action), userInfo: nil, repeats: self.startVar)
            }
        }
        else {
            self.timer.invalidate()
            createTimeArray(indexPath: index)
        }
    }
    
    //fetching time from firebase for timer
    func fetchTimeFromFirebase(indexPath: IndexPath, dispatchGroup: DispatchGroup){
        dispatchGroup.enter()
        Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).collection("habits").document("habit\(indexPath.row)").getDocument{(document, error) in
            if let document = document{
                self.timeArrayFirebase = document.get("timeArray")
                
                let result = self.timeArrayFirebase as! [Int]
                self.timeDisplayedHour = (result[0]) * 10 + (result[1])
                self.timeDisplayedMinute = (result[2]) * 10 + (result[3])
                self.timeDisplayedSecond = (result[4]) * 10 + (result[5])
            }
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main){
            if (self.counted == false){
                self.setTimerLabels()
            }
        }
    }
    
    //create time array for saving in firebase
    func createTimeArray(indexPath: IndexPath) {
        timeArray.removeAll()
        timeArray.append(Int(timeDisplayedHour / 10))
        timeArray.append(timeDisplayedHour % 10)
        timeArray.append(Int(timeDisplayedMinute / 10))
        timeArray.append(timeDisplayedMinute % 10)
        timeArray.append(Int(timeDisplayedSecond / 10))
        timeArray.append(timeDisplayedSecond % 10)
        
        Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).collection("habits").document("habit\(indexPath.row)").updateData(["timeArray": timeArray])
    }
    
    @objc func Action() {
        if timeDisplayedHour == 0 && timeDisplayedMinute == 0 && timeDisplayedSecond == 0 {
            timer.invalidate()
            timerDelegate?.showAlert(cell: self, indexPathCell: indexPathCell!)
        }
        else {
            if timeDisplayedSecond == 0 {
                timeDisplayedMinutePrev = timeDisplayedMinute
                if timeDisplayedMinutePrev > 0 {
                    timeDisplayedMinute-=1
                    timeDisplayedSecond = 59
                }
                
                if timeDisplayedMinute == 0 {
                    timeDisplayedHourPrev = timeDisplayedHour
                    if timeDisplayedHourPrev > 0 {
                        timeDisplayedHour-=1
                        timeDisplayedMinute = 59
                    }
                }
            }
            
            else {
                timeDisplayedSecondPrev = timeDisplayedSecond
                timeDisplayedSecond-=1
            }
            if timeDisplayedHour < 10 {
                if timeDisplayedMinute < 10 {
                    if timeDisplayedSecond < 10 {
                        habitCountLabel.text = "0\(timeDisplayedHour):0\(timeDisplayedMinute):0\(timeDisplayedSecond)"
                        timerLabel.text = "0\(timeDisplayedHour):0\(timeDisplayedMinute):0\(timeDisplayedSecond)"
                    }
                    else {
                        habitCountLabel.text = "0\(timeDisplayedHour):0\(timeDisplayedMinute):\(timeDisplayedSecond)"
                        timerLabel.text = "0\(timeDisplayedHour):0\(timeDisplayedMinute):\(timeDisplayedSecond)"
                    }
                }
                else {
                    if timeDisplayedSecond < 10 {
                        habitCountLabel.text = "0\(timeDisplayedHour):\(timeDisplayedMinute):0\(timeDisplayedSecond)"
                        timerLabel.text = "0\(timeDisplayedHour):\(timeDisplayedMinute):0\(timeDisplayedSecond)"
                    }
                    else {
                        habitCountLabel.text = "0\(timeDisplayedHour):\(timeDisplayedMinute):\(timeDisplayedSecond)"
                        timerLabel.text = "0\(timeDisplayedHour):\(timeDisplayedMinute):\(timeDisplayedSecond)"
                    }
                }
            }
            
            else {
                if timeDisplayedMinute < 10 {
                    if timeDisplayedSecond < 10 {
                        habitCountLabel.text = "\(timeDisplayedHour):0\(timeDisplayedMinute):0\(timeDisplayedSecond)"
                        timerLabel.text = "\(timeDisplayedHour):0\(timeDisplayedMinute):0\(timeDisplayedSecond)"
                    }
                    else {
                        habitCountLabel.text = "\(timeDisplayedHour):0\(timeDisplayedMinute):\(timeDisplayedSecond)"
                        timerLabel.text = "\(timeDisplayedHour):0\(timeDisplayedMinute):\(timeDisplayedSecond)"
                    }
                }
                else {
                    if timeDisplayedSecond < 10 {
                        habitCountLabel.text = "\(timeDisplayedHour):\(timeDisplayedMinute):0\(timeDisplayedSecond)"
                        timerLabel.text = "\(timeDisplayedHour):\(timeDisplayedMinute):0\(timeDisplayedSecond)"
                    }
                    else {
                        habitCountLabel.text = "\(timeDisplayedHour):\(timeDisplayedMinute):\(timeDisplayedSecond)"
                        timerLabel.text = "\(timeDisplayedHour):\(timeDisplayedMinute):\(timeDisplayedSecond)"
                    }
                }
            }
        }
    }
    
    func setTimerLabels(){
        if timeDisplayedHour < 10 {
            if timeDisplayedMinute < 10 {
                if timeDisplayedSecond < 10 {
                    habitCountLabel.text = "0\(timeDisplayedHour):0\(timeDisplayedMinute):0\(timeDisplayedSecond)"
                    timerLabel.text = "0\(timeDisplayedHour):0\(timeDisplayedMinute):0\(timeDisplayedSecond)"
                }
                else {
                    habitCountLabel.text = "0\(timeDisplayedHour):0\(timeDisplayedMinute):\(timeDisplayedSecond)"
                    timerLabel.text = "0\(timeDisplayedHour):0\(timeDisplayedMinute):\(timeDisplayedSecond)"
                }
            }
            else {
                if timeDisplayedSecond < 10 {
                    habitCountLabel.text = "0\(timeDisplayedHour):\(timeDisplayedMinute):0\(timeDisplayedSecond)"
                    timerLabel.text = "0\(timeDisplayedHour):\(timeDisplayedMinute):0\(timeDisplayedSecond)"
                }
                else {
                    habitCountLabel.text = "0\(timeDisplayedHour):\(timeDisplayedMinute):\(timeDisplayedSecond)"
                    timerLabel.text = "0\(timeDisplayedHour):\(timeDisplayedMinute):\(timeDisplayedSecond)"
                }
            }
        }
        
        else {
            if timeDisplayedMinute < 10 {
                if timeDisplayedSecond < 10 {
                    habitCountLabel.text = "\(timeDisplayedHour):0\(timeDisplayedMinute):0\(timeDisplayedSecond)"
                    timerLabel.text = "\(timeDisplayedHour):0\(timeDisplayedMinute):0\(timeDisplayedSecond)"
                }
                else {
                    habitCountLabel.text = "\(timeDisplayedHour):0\(timeDisplayedMinute):\(timeDisplayedSecond)"
                    timerLabel.text = "\(timeDisplayedHour):0\(timeDisplayedMinute):\(timeDisplayedSecond)"
                }
            }
            else {
                if timeDisplayedSecond < 10 {
                    habitCountLabel.text = "\(timeDisplayedHour):\(timeDisplayedMinute):0\(timeDisplayedSecond)"
                    timerLabel.text = "\(timeDisplayedHour):\(timeDisplayedMinute):0\(timeDisplayedSecond)"
                }
                else {
                    habitCountLabel.text = "\(timeDisplayedHour):\(timeDisplayedMinute):\(timeDisplayedSecond)"
                    timerLabel.text = "\(timeDisplayedHour):\(timeDisplayedMinute):\(timeDisplayedSecond)"
                }
            }
        }
    }
}
