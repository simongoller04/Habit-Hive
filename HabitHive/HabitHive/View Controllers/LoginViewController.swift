//
//  LoginViewController.swift
//  HabitHiveTestLogin
//
//  Created by Sebastian Weidlinger on 30.05.21.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpElements()
        activityIndicator.color = UIColor.black
        activityIndicator.stopAnimating()
        emailTextField.becomeFirstResponder()
    }
    
    func setUpElements(){
        
        //Hide error Label
        errorLabel.alpha = 0
    }
    
    func validateFields() -> String?{
        
        //check that all fields are filled returns error message if not filled
        if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "Please fill in all the fields"
        }
        return nil
    }
    
    
    @IBAction func loginTapped(_ sender: Any) {
        //Validate Text Fields
        
        //validate fields
        let error = validateFields()
        
        if error != nil{
            showError(error!)
        }
        else{
            self.activityIndicator.startAnimating()
            //create cleaned text of textfields
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            //Signing in the User
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                
                if error != nil{
                    //couldnt sign in
                    self.errorLabel.text = "Email or Password incorrect"
                    self.errorLabel.alpha = 1
                    self.activityIndicator.stopAnimating()
                }
                else{
                    self.setUpElements()
                    let tabBarViewController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.tabBarController) as? TabBarViewController
                    
                    self.view.window?.rootViewController = tabBarViewController
                    self.view.window?.makeKeyAndVisible()
                }
            }
        }
    }
    
    func showError(_ message:String){
        errorLabel.text = message
        errorLabel.alpha = 1
    }
}

