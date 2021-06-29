//
//  HabitCollectionViewController.swift
//  HabitHive
//
//  Created by Sebastian Weidlinger on 29.06.21.
//

import UIKit
import Firebase
import FirebaseAuth

class HabitCollectionViewController: UICollectionViewController {
    
    var dataSource: [String] = ["Peda","Hansl","Saufkollege", "Radlertrinker"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.reloadData()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))

        getFirstName()
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
        
        navigationController?.pushViewController(vc, animated: true)
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return dataSource.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell =  UICollectionViewCell()
        
        if let habitCell = collectionView.dequeueReusableCell(withReuseIdentifier: "habitCell", for: indexPath) as? HabitCollectionViewCell{
            habitCell.configure(with: dataSource[indexPath.row])
            
            cell = habitCell
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print ("Achievement: \(dataSource[indexPath.row])")
    }
    @IBAction func longButtonPress(_ sender: Any) {
        print("Huso")
    }
}
