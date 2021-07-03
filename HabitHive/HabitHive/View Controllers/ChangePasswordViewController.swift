//
//  ChangePasswordViewController.swift
//  HabitHive
//
//  Created by Sebastian Weidlinger on 03.06.21.
//

import UIKit
import Firebase
import FirebaseAuth

class ChangePasswordViewController: UIViewController {
    @IBOutlet weak var currentPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmNewPasswordTextField: UITextField!
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpElements()
    }
    
    func setUpElements(){
        
        //Hide error Label
        errorLabel.alpha = 0
    }
    
    func validateFields() -> String?{
        
        //check that all fields are filled returns error message if not filled
        if newPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            confirmNewPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            
            return "Please fill in all the fields"
        }
        if newPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != confirmNewPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines){
            return "Passwords don't match!"
        }
        return nil
    }
    
    func showError(_ message:String){
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    @IBAction func changePasswordButtonTapped(_ sender: Any) {
        //Validate Text Fields
        
        //validate fields
        let error = validateFields()
        
        if error != nil{
            showError(error!)
        }
        else{
            
            //create cleaned text of password
            let newPassword = newPasswordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            //Changing password of user
            Auth.auth().currentUser?.updatePassword(to: newPassword) {error in
                if error != nil{
                    //couldnt sign in
                    self.errorLabel.text = "Something went wrong"
                    self.errorLabel.alpha = 1
                }
                else {
                    self.errorLabel.text = "Password succesfully changed!"
                    self.errorLabel.alpha = 1
                    self.errorLabel.textColor = UIColor.systemGreen
                }
            }
        }
    }
}
