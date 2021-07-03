//
//  HabitCollectionViewCell.swift
//  HabitHive
//
//  Created by Sebastian Weidlinger on 29.06.21.
//

import UIKit

class HabitCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var habitNameLabel: UILabel!
    @IBOutlet weak var habitCountLabel: UILabel!
    @IBOutlet weak var streakLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    //Timer variables
    var timer = Timer()
    var timeDisplayedHour = 0
    var timeDisplayedMinute = 0
    var timeDisplayedSecond = 0
    var timeDisplayedHourPrev = 0
    var timeDisplayedMinutePrev = 0
    var timeDisplayedSecondPrev = 0
    var startVar = false
    
    
    func configure(with habit: Habit) {
        habitNameLabel.text = habit.name
        habitCountLabel.text = "\(habit.currentCount)/\(habit.goal)"
        streakLabel.text = "Streak: \(habit.streak)"
        habitNameLabel.isHidden = false
        deleteButton.isHidden = true
        editButton.isHidden = true
        habitCountLabel.isHidden = false
        streakLabel.isHidden = false
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
        }
        else {
            timeDisplayedHour = habit.time[0] * 10 + habit.time[1]
            timeDisplayedMinute = habit.time[2] * 10 + habit.time[3]
            
            if timeDisplayedHour < 10 {
                if timeDisplayedMinute < 10 {
                    habitCountLabel.text = "0\(timeDisplayedHour):0\(timeDisplayedMinute):00"
                    timerLabel.text = "0\(timeDisplayedHour):0\(timeDisplayedMinute):00"
                }
                else {
                    habitCountLabel.text = "0\(timeDisplayedHour):\(timeDisplayedMinute):00"
                    timerLabel.text = "0\(timeDisplayedHour):\(timeDisplayedMinute):00"
                }
            }
            
            else {
                if timeDisplayedMinute < 10 {
                    habitCountLabel.text = "\(timeDisplayedHour):0\(timeDisplayedMinute):00"
                    timerLabel.text = "\(timeDisplayedHour):0\(timeDisplayedMinute):00"
                }
                else {
                    habitCountLabel.text = "\(timeDisplayedHour):\(timeDisplayedMinute):00"
                    timerLabel.text = "\(timeDisplayedHour):\(timeDisplayedMinute):00"
                }
            }
        }
    }
    
    func startCountdown(CV: UICollectionView, index: IndexPath, start: Bool) {
        startVar = start
        if startVar == true {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(Action), userInfo: nil, repeats: startVar)
        }
        else {
            timer.invalidate()
        }
    }
    
    @objc func Action() {
        if timeDisplayedHour == 0 && timeDisplayedMinute == 0 && timeDisplayedSecond == 0 {
            timer.invalidate()
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
}
