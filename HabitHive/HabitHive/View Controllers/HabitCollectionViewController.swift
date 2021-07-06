//
//  HabitCollectionViewController.swift
//  HabitHive
//
//  Created by Sebastian Weidlinger on 29.06.21.
//

import UIKit
import Firebase
import FirebaseAuth
import UserNotifications

class HabitCollectionViewController: UICollectionViewController, UIGestureRecognizerDelegate {
    var habitArray = [Habit]()
    var localHabitCounter = 0
    var indexPathGlobal = IndexPath()
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var cellsWhichAreLongPressed = [HabitCollectionViewCell]()
    let dispatchGroup = DispatchGroup()
    var timerArray = [Timer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userSignedin = authenticateUser()
        if (userSignedin) {
            notificationCenter()
            collectionView.reloadData()
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
            activityIndicator.color = UIColor.black
            getFirstName()
            fetchFirebaseHabits()
            let tap = UISwipeGestureRecognizer(target: self, action: #selector (handlePressOnCollectionView))
            self.collectionView.addGestureRecognizer(tap)
            activityIndicator.startAnimating()
            dispatchGroup.notify(queue: .main){
                self.collectionView.reloadData()
                self.activityIndicator.stopAnimating()
            }
            setupLongGestureRecognizerOnCollection()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let today = Date()
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.day, .month, .year], from: today)
        let currentDay = calendar.date(from: comps)
        let yesterday = UserDefaults.standard.object(forKey: "palmiIsCool")
        let dispatchGroupTest = DispatchGroup()
        
        if (Auth.auth().currentUser != nil){
            if(currentDay != yesterday as? Date) {
                dispatchGroupTest.enter()
                Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).updateData(["finishedHabits": 0])
                let habitRef = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).collection("habits")
                if (habitArray.count - 1 > -1){
                    for n in 0...habitArray.count - 1 {
                        habitArray[n].currentCount = 0
                        if (habitArray[n].addFirebase){
                            habitArray[n].streak = 0
                        }
                        else{
                            habitArray[n].streak += 1
                        }
                        habitArray[n].addFirebase = true
                    }
                    var achievementName = [String]()
                    for n in 0...habitArray.count - 1 {
                        habitRef.document("habit\(n)").updateData(["currentCount": 0, "goal": habitArray[n].goal, "name": habitArray[n].name,"timeArray": habitArray[n].timeOriginal, "addFirebase": habitArray[n].addFirebase, "streak": habitArray[n].streak])
                        if (habitArray[n].streak == 1){
                            achievementName.append("\(habitArray[n].name) for 10 days")
                            Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).updateData(["achievements": achievementName])
                        }
                        else if (habitArray[n].streak == 25){
                            achievementName.append("\(habitArray[n].name) for 25 days")
                            Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).updateData(["achievements": achievementName])
                        }
                        else if (habitArray[n].streak == 50){
                            achievementName.append("\(habitArray[n].name) for 50 days")
                            Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).updateData(["achievements": achievementName])
                        }
                        
                    }
                    dispatchGroupTest.leave()
                }
                dispatchGroupTest.notify(queue: .main){
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    func authenticateUser() -> Bool {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let navVC = self.storyboard?.instantiateViewController(identifier: "NavigationVC")
                self.present(navVC!, animated: true, completion: nil)
            }
            return false
        }
        return true
    }
    
    func getFirstName(){
        let docRef = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid)
        docRef.getDocument{(document, error) in
            if let document = document{
                let property = document.get("firstName")
                UserDefaults.standard.set(property as? String ?? "User", forKey: "firstName")
            }
        }
    }
    
    @objc func handlePressOnCollectionView(sender: UISwipeGestureRecognizer) {
        if (cellsWhichAreLongPressed.count - 1 > -1){
            for n in 0...cellsWhichAreLongPressed.count - 1{
                resetCellsToStandard(cell: cellsWhichAreLongPressed[n])
            }
            cellsWhichAreLongPressed.removeAll()
        }
    }
    
    func resetCellsToStandard(cell: HabitCollectionViewCell){
        cell.habitNameLabel.isHidden = false
        cell.deleteButton.isHidden = true
        cell.editButton.isHidden = true
        cell.habitCountLabel.isHidden = false
        cell.streakLabel.isHidden = false
    }
    
    func setupLongGestureRecognizerOnCollection() {
        let longPressedGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
        longPressedGesture.minimumPressDuration = 0.5
        longPressedGesture.delegate = self
        longPressedGesture.delaysTouchesBegan = true
        collectionView?.addGestureRecognizer(longPressedGesture)
    }
    
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if (gestureRecognizer.state != .began) {
            return
        }
        
        let p = gestureRecognizer.location(in: collectionView)
        
        if let indexPath = collectionView?.indexPathForItem(at: p) {
            let cell = collectionView.cellForItem(at: indexPath) as! HabitCollectionViewCell
            if (!(cell.timerRunning ?? false)){
                cell.habitNameLabel.isHidden = true
                cell.deleteButton.isHidden = false
                cell.editButton.isHidden = false
                cell.habitCountLabel.isHidden = true
                cell.streakLabel.isHidden = true
                if (!habitArray[indexPath.row].counted){
                    cell.startCountdown(CV: collectionView, index: indexPath, start: false)
                }
                indexPathGlobal = indexPath
                cellsWhichAreLongPressed.append(cell)
                let current = habitArray[indexPath.row].color
                
                var currentColor = UIColor()
                switch current{
                case 1:
                    currentColor = UIColor.systemBlue
                case 2:
                    currentColor = UIColor.systemGreen
                case 3:
                    currentColor = UIColor.systemYellow
                case 4:
                    currentColor = UIColor.systemOrange
                case 5:
                    currentColor = UIColor.systemPurple
                default:
                    currentColor = UIColor.systemGray
                }
                
                cell.deleteButton.backgroundColor = currentColor.adjust(by: -20)
                cell.editButton.backgroundColor = currentColor.adjust(by: -20)
            }
        }
    }
    
    func notificationCenter() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound])
        {(granted, error) in
        }
        
        let content = UNMutableNotificationContent()
        content.title = "This is your friendly Habit Hive reminder"
        content.body = "Already finished all your Habits?"
        
        let components = DateComponents(hour: 20)
        let date = Calendar.current.date(from: components)
        let comp = Calendar.current.dateComponents([.hour, .minute], from: date!)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comp, repeats: true)
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        center.add(request) { (error) in
        }
    }
    
    @objc func addButtonTapped(){
        let vc = storyboard?.instantiateViewController(identifier: "CreateHabitVC") as! CreateHabitViewController
        vc.update = {
            DispatchQueue.main.async {
                self.fetchFirebaseHabits()
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return habitArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
            if (timerArray.count - 1 > 0){
                for n in 0...timerArray.count - 1{
                    timerArray[n].invalidate()
                }
                timerArray.removeAll()
            }
        
        let habitCell = collectionView.dequeueReusableCell(withReuseIdentifier: "habitCell", for: indexPath) as! HabitCollectionViewCell
        habitCell.timerDelegate = self
        habitCell.indexPathCell = indexPath
        habitCell.originalTimerArray = habitArray[indexPath.row].timeOriginal
        habitCell.counted = habitArray[indexPath.row].counted
        habitCell.configure(with: habitArray[indexPath.row])
        habitCell.deleteButton.addTarget(self, action: #selector(deleteHabit(_:)), for: .touchUpInside)
        habitCell.editButton.addTarget(self, action: #selector(editHabit(_:)), for: .touchUpInside)
        return habitCell
    }
    
    func deleteHabitAction(dispatchGroupDelete: DispatchGroup){
        collectionView.deleteItems(at: [indexPathGlobal])
        habitArray.remove(at: indexPathGlobal.row)
        dispatchGroupDelete.enter()
        let habitRef = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).collection("habits")
        habitRef.document("habit\(indexPathGlobal.row)").delete() { err in
            if let err = err{
                print("Error removing Habit: \(err)")
            }
            
            if (self.habitArray.count != self.indexPathGlobal.row){
                habitRef.document("habit\(self.habitArray.count)").delete()
            }
            
            Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).updateData(["habitCounter" : self.habitArray.count]) { err in
                if let err = err{
                    print("Error removing Habit: \(err)")
                }
                self.updateFirebaseHabits(dispatchGroup: dispatchGroupDelete)
            }
        }
    }
    
    @objc func deleteHabit(_ sender: UIButton){
        let dispatchGroupDelete = DispatchGroup()
        deleteHabitAction(dispatchGroupDelete: dispatchGroupDelete)
        dispatchGroupDelete.notify(queue: .main){
            self.fetchFirebaseHabits()
        }
    }
    
    @objc func editHabit(_ sender: UIButton){
        let vc = storyboard?.instantiateViewController(identifier: "EditHabitVC") as! EditHabitViewController
        vc.habit = habitArray[indexPathGlobal.row]
        vc.indexPath = indexPathGlobal
        vc.update = {
            DispatchQueue.main.async {
                self.fetchFirebaseHabits()
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath) as! HabitCollectionViewCell
        
        let calendar = Calendar.current
        let today = Date()
        let component = calendar.dateComponents([.day, .month, .year], from: today)
        let yesterday = calendar.date(from: component)
        UserDefaults.standard.setValue(yesterday, forKey: "palmiIsCool")
        
        if (!habitArray[indexPath.row].addFirebase){
            if (selectedCell.deleteButton.isHidden == false){
                collectionView.reloadItems(at: [indexPath])
            }
        }
        else{
            if (selectedCell.deleteButton.isHidden == false){
                collectionView.reloadItems(at: [indexPath])
            }
            else{
                if habitArray[indexPath.row].counted == false {
                    UIView.animate(withDuration: 0.5){
                        selectedCell.imageView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                    }
                    UIView.animate(withDuration: 0.5, delay: 0.5){
                        selectedCell.imageView.transform = CGAffineTransform(scaleX: 1, y: 1)
                    }
                    UIView.animate(withDuration: 0.5, delay: 1){
                        selectedCell.imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
                    }
                    if selectedCell.startVar == true {
                        selectedCell.startCountdown(CV: collectionView, index: indexPath, start: false)
                        selectedCell.habitNameLabel.isHidden = false
                        selectedCell.streakLabel.isHidden = false
                        selectedCell.habitCountLabel.isHidden = false
                        selectedCell.timerLabel.isHidden = true
                        selectedCell.timerRunning = false
                    }
                    else {
                        UIView.animate(withDuration: 0.5, delay: 0.5){
                            selectedCell.imageView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                        }
                        UIView.animate(withDuration: 0.5, delay: 1){
                            selectedCell.imageView.transform = CGAffineTransform(scaleX: 1, y: 1)
                        }
                        selectedCell.startCountdown(CV: collectionView, index: indexPath, start: true)
                        selectedCell.timerLabel.text = selectedCell.habitCountLabel.text
                        selectedCell.timerLabel.isHidden = false
                        selectedCell.habitNameLabel.isHidden = true
                        selectedCell.streakLabel.isHidden = true
                        selectedCell.habitCountLabel.isHidden = true
                        selectedCell.timerRunning = true
                    }
                }
                else {
                    let offset = collectionView.contentOffset
                    if (habitArray[indexPath.row].currentCount < habitArray[indexPath.row].goal){
                        
                        habitArray[indexPath.row].finishedFirstTime = false
                        habitArray[indexPath.row].currentCount += 1
                        countedButtonPressAnimation(indexPath: indexPath, selectedCell: selectedCell)
                        
                        let habitRef = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).collection("habits")
                        habitRef.document("habit\(indexPath.row)").updateData(["currentCount": habitArray[indexPath.row].currentCount])
                        collectionView.reloadItems(at: [indexPath])
                        collectionView.layoutIfNeeded()
                        collectionView.setContentOffset(offset, animated: false)
                    }
                    
                    if (habitArray[indexPath.row].currentCount == habitArray[indexPath.row].goal){
                        finishedPulseAnimation(indexPath: indexPath, selectedCell: selectedCell)
                        
                        if habitArray[indexPath.row].finishedFirstTime {
                            habitArray[indexPath.row].finishedFirstTime = false
                        }
                        
                        if (habitArray[indexPath.row].addFirebase){
                            let docRef = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid)
                            docRef.getDocument{(document, error) in
                                if let document = document{
                                    let property = document.get("finishedHabits") as! Int
                                    docRef.updateData(["finishedHabits": property + 1])
                                }
                                
                                Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).collection("habits").document("habit\(indexPath.row)").updateData(["addFirebase": false])
                                
                            }
                            self.habitArray[indexPath.row].addFirebase = false
                            selectedCell.configure(with: self.habitArray[indexPath.row])
                        }
                    }
                    collectionView.reloadItems(at: [indexPath])
                    collectionView.layoutIfNeeded()
                    collectionView.setContentOffset(offset, animated: false)
                }
            }
        }
    }
    
    func fetchFirebaseHabits(){
        habitArray.removeAll()
        activityIndicator.startAnimating()
        dispatchGroup.enter()
        let docRef = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid)
        docRef.getDocument{(document, error) in
            if let document = document{
                let property = document.get("habitCounter")
                self.localHabitCounter = property as! Int - 1
            }
            if (self.localHabitCounter != -1){
                for n in 0...self.localHabitCounter{
                    docRef.collection("habits").document("habit\(n)").getDocument{(document, error) in
                        if let document = document{
                            let name = document.get("name")
                            let color = document.get("color")
                            let counted = document.get("counted")
                            let goal = document.get("goal")
                            let currentCount = document.get("currentCount")
                            let addFirebase = document.get("addFirebase")
                            let streak = document.get("streak")
                            let time = document.get("timeArray")
                            let timeOriginal = document.get("timeArrayOriginal")
                            
                            let habit = Habit(name: name as! String, color: color as! Int, counted: counted as! Bool, goal: goal as! Int, currentCount: currentCount as! Int, time: time as! [Int], timeOriginal: timeOriginal as! [Int], addFirebase: addFirebase as! Bool, streak: streak as! Int, habitNumber: n, finishedFirstTime: true)
                            
                            self.habitArray.append(habit)
                        }
                        self.activityIndicator.stopAnimating()
                        self.habitArray.sort(by :{$0.habitNumber < $1.habitNumber})
                        self.collectionView.reloadData()
                    }
                }
            }
            else{
                self.activityIndicator.stopAnimating()
            }
        }
        dispatchGroup.leave()
    }
    
    func updateFirebaseHabits(dispatchGroup: DispatchGroup) {
        let habitRef = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).collection("habits")
        if (habitArray.count - 1 > -1){
            for n in 0...habitArray.count - 1 {
                habitRef.document("habit\(n)").setData(["color": habitArray[n].color, "counted": habitArray[n].counted, "currentCount": habitArray[n].currentCount, "goal": habitArray[n].goal, "name": habitArray[n].name,"timeArray": habitArray[n].time, "addFirebase": habitArray[n].addFirebase, "streak": habitArray[n].streak, "timeArrayOriginal": habitArray[n].timeOriginal])
            }
        }
        Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).updateData(["habitCounter" : self.habitArray.count])
        dispatchGroup.leave()
    }
    
    func countedButtonPressAnimation(indexPath: IndexPath, selectedCell: HabitCollectionViewCell){
        if (habitArray[indexPath.row].currentCount != habitArray[indexPath.row].goal){
            let origin = self.collectionView.layoutAttributesForItem(at: indexPath)?.center
            let pulse = PulseAnimation(numberOfPulse: 1, radius: 80, position: origin!)
            pulse.animationDuration = 0.75
            pulse.backgroundColor = selectedCell.imageView.tintColor.adjust(by: -20)?.cgColor
            collectionView.layer.insertSublayer(pulse, below: self.view.layer)
        }
    }
    
    func finishedPulseAnimation(indexPath: IndexPath, selectedCell: HabitCollectionViewCell){
        let origin = self.collectionView.layoutAttributesForItem(at: indexPath)?.center
        let pulse = PulseAnimation(numberOfPulse: 2, radius: 110, position: origin!)
        pulse.animationDuration = 0.5
        pulse.backgroundColor = selectedCell.imageView.tintColor.adjust(by: -20)?.cgColor
        collectionView.layer.insertSublayer(pulse, below: self.view.layer)
    }
}

extension UIColor {
    
    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }
}

extension HabitCollectionViewController: TimerFinishedDelegate {
    func showAlert(cell: HabitCollectionViewCell, indexPathCell: IndexPath) {
        let alert = UIAlertController(title: "Good Job!", message: "You finished \(cell.habitNameLabel.text ?? "Habit")", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler:  { _ in
            alert.dismiss(animated: true)
        }))
        
        present(alert, animated: true)
        habitArray[indexPathCell.row].addFirebase = false
        cell.habitCell?.addFirebase = false
        cell.originalTimerArray = habitArray[indexPathCell.row].timeOriginal
        cell.configure(with: cell.habitCell!)
        Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).collection("habits").document("habit\(indexPathCell.row)").updateData(["addFirebase": false])
    }
    
    func returnTimeArray(timeArray: [Int], indexPath: IndexPath){
        habitArray[indexPath.row].time = timeArray
    }
    
    func returnTimer(timer: Timer) {
        timerArray.append(timer)
    }
}

struct Habit{
    let name: String
    let color: Int
    var counted: Bool
    let goal: Int
    var currentCount: Int
    var time: [Int]
    var timeOriginal: [Int]
    var addFirebase: Bool
    var streak: Int
    var habitNumber: Int
    var finishedFirstTime: Bool
}
