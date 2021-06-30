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

class HabitCollectionViewController: UICollectionViewController {
    var habitArray = [Habit]()
    var localHabitCounter = 0
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    let dispatchGroup = DispatchGroup()
    
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
            activityIndicator.startAnimating()
            dispatchGroup.notify(queue: .main){
                self.collectionView.reloadData()
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    func notificationCenter() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in }
        let content = UNMutableNotificationContent()
        content.title = "Hey I'm a notification!"
        content.body = "Look at me!"
        let calendar = Calendar.current
        let components = DateComponents(hour: 9)
        let components2 = DateComponents(hour: 21)
        let amDate = calendar.date(from: components)
        let pmDate = calendar.date(from: components2)
        let comp1 = calendar.dateComponents([.hour, .minute], from: amDate!)
        let comp2 = calendar.dateComponents([.hour, .minute], from: pmDate!)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: comp1, repeats: true)
        let trigger2 = UNCalendarNotificationTrigger(dateMatching: comp2, repeats: true)
        let uuidString = UUID().uuidString
        let uuidString2 = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        let request2 = UNNotificationRequest(identifier: uuidString2, content: content, trigger: trigger2)
        center.add(request) { (error) in
            print(error?.localizedDescription ?? "error")
        }
        center.add(request2) { (error) in
            print(error?.localizedDescription ?? "error")
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
                UserDefaults.standard.set(property as! String, forKey: "firstName")
            }
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
        
        var cell =  UICollectionViewCell()
        
        if let habitCell = collectionView.dequeueReusableCell(withReuseIdentifier: "habitCell", for: indexPath) as? HabitCollectionViewCell{
            habitCell.configure(with: habitArray[indexPath.row])
            cell = habitCell
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (habitArray[indexPath.row].currentCount < habitArray[indexPath.row].goal){
            habitArray[indexPath.row].currentCount += 1
            let habitRef = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).collection("habits")
            habitRef.document("habit\(habitArray.count-indexPath.row-1)").updateData(["currentCount" : habitArray[indexPath.row].currentCount])
            collectionView.reloadData()
        }
        // streak implementation could be like this: if addFirebase flag of certain habit is true at like 23:59 streak counter gets reset to zero for this habit
        if (habitArray[indexPath.row].currentCount == habitArray[indexPath.row].goal){
            print("finished")
            if (habitArray[indexPath.row].addFirebase){
                let docRef = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid)
                docRef.getDocument{(document, error) in
                    if let document = document{
                        let property = document.get("finishedHabits") as! Int
                        docRef.updateData(["finishedHabits": property + 1])
                    }
                    
                    Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).collection("habits").document("habit\(self.habitArray.count-indexPath.row-1)").updateData(["addFirebase": false])
                    self.habitArray[indexPath.row].addFirebase = false
                    self.collectionView.reloadData()
                }
            }
            
        }
    }
    
    func fetchFirebaseHabits(){
        habitArray.removeAll()
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
                            let remindMe = document.get("remindMe")
                            let currentCount = document.get("currentCount")
                            let externalCalendar = document.get("externalCalendar")
                            let addFirebase = document.get("addFirebase")
                            let streak = document.get("streak")
                            
                            let habit = Habit(name: name as! String, color: color as! Int, counted: counted as! Bool, externalCalendar: externalCalendar as! Bool, goal: goal as! Int, currentCount: currentCount as! Int, remindMe: remindMe as! Bool, addFirebase: addFirebase as! Bool, streak: streak as! Int)
                            self.habitArray.append(habit)
                            self.collectionView.reloadData()
                        }
                    }
                }
            }
        }
        dispatchGroup.leave()
    }
    
    func updateFirebaseHabits() {
        let habitRef = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).collection("habits")
        
        for n in 0...localHabitCounter {
            habitRef.document("habit\(n)").updateData(["color": habitArray[n].color, "counted": habitArray[n].counted, "currentCount": habitArray[n].currentCount, "externalCalendar": habitArray[n].externalCalendar, "goal": habitArray[n].goal, "name": habitArray[n].name, "remindMe": habitArray[n].remindMe])
        }
    }
}

struct Habit{
    let name: String
    let color: Int
    let counted: Bool
    let externalCalendar: Bool
    let goal: Int
    var currentCount: Int
    let remindMe: Bool
    var addFirebase: Bool
    var streak: Int
}
