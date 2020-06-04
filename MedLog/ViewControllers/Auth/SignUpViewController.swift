//
//  SignUpViewController.swift
//  MedLog
//
//  Created by Darius Bogoslov on 25/04/2020.
//  Copyright © 2020 Darius Bogoslov. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        // Do any additional setup after loading the view.
        setupElements()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func setupElements() {
        errorLabel.alpha = 0
        
        Utilities.styleTextField(firstNameTextField)
        Utilities.styleTextField(lastNameTextField)
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(signUpButton)
        
        let buttonConfig = UIImage.SymbolConfiguration(pointSize: 20.0, weight: .bold)
        backButton.setTitle("", for: UIControl.State.normal)
        backButton.setImage(UIImage(systemName: "arrowtriangle.left.circle.fill", withConfiguration: buttonConfig), for: UIControl.State.normal)
        backButton.tintColor = UIColor.init(red: 36/255, green: 93/255, blue: 153/255, alpha: 1)
    }

    func validateFields() -> String? {
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all the fields."
        }
        
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if(Utilities.isPasswordValid(cleanedPassword) == false) {
            return "Please make sure your password is at least 8 characters, contains a special character and a number."
        }
        
        return nil
    }
        
    @IBAction func backToAuth(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        let error = validateFields()
        
        if error != nil {
            showError(error!)
        } else {
            let userData = [
                "firstName": firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines),
                "lastName": lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines),
                "email": emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines),
                "password": passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            ]
            
            Auth.auth().createUser(withEmail: userData["email"]!, password: userData["password"]!) { (result, err) in
                if err != nil {
                    self.showError("Error creating user")
                } else {
                    
                    FirebaseWorker.worker.db.collection("users").document(result!.user.uid).setData([
                        "firstName": userData["firstName"]! as String,
                        "lastName": userData["lastName"]! as String,
                        "email": userData["email"]! as String,
						"userClass": "basic",
						"address": "",
						"age": "",
						"city": "",
						"county": "",
                    ]) {(error) in
                        if error != nil {
                            self.showError("User data couldn't be saved 😢")
                        }
                    }
                    
                    self.transitionToTabBar()                }
            }
        }
    }
    
    func showError(_ error: String) {
        errorLabel.text = error
        errorLabel.alpha = 1
    }
    
    func transitionToTabBar() {
        let tabBarController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.tabBarController) as! UITabBarController
        
        navigationController?.pushViewController(tabBarController, animated: true)
    }
}
