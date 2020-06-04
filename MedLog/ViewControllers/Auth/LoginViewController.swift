//
//  LoginViewController.swift
//  MedLog
//
//  Created by Darius Bogoslov on 25/04/2020.
//  Copyright © 2020 Darius Bogoslov. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    fileprivate var spinner: UIView?
    
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
        
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(loginButton)
        
        let buttonConfig = UIImage.SymbolConfiguration(pointSize: 20.0, weight: .bold)
        backButton.setTitle("", for: UIControl.State.normal)
        backButton.setImage(UIImage(systemName: "arrowtriangle.left.circle.fill", withConfiguration: buttonConfig), for: UIControl.State.normal)
        backButton.tintColor = UIColor.init(red: 36/255, green: 93/255, blue: 153/255, alpha: 1)
        
        if(UserDefaults.standard.bool(forKey: "userIsLogged")) {
            emailTextField.text = Auth.auth().currentUser?.email
        }
    }

    func validateFields() -> String? {
        if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all the fields."
        }
        
        return nil
    }
    
    func showError(_ error: String) {
        errorLabel.text = error
        errorLabel.alpha = 1
    }
        
    @IBAction func loginTapped(_ sender: Any) {
        let error = validateFields()
        
        if error != nil {
            showError(error!)
        } else {
            let userData = [
                "email": emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines),
                "password": passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            ]
            
            Auth.auth().signIn(withEmail: userData["email"]!, password: userData["password"]!) {(result, error) in
                if error != nil {
                    self.showError("Couldn't sign in.")
                } else {
                    self.view.endEditing(true)
                    self.showSpinner()
                    UserDefaults.standard.set(true, forKey: "userIsLogged")
                    UserDefaults.standard.set(Auth.auth().currentUser?.uid, forKey: "userFID")
                    UserDefaults.standard.set(Auth.auth().currentUser?.email, forKey: "userEmail")
                    FirebaseWorker.worker.provisionFromFirebase()
                    Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { (t) in
                        self.transitionToTabBar()
                    }                    
                }
            }
        }
    }
    
    func showSpinner() {
        spinner = UIView(frame: self.view.bounds)
        spinner?.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.7)
        
        let indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        indicator.center = spinner!.center
        indicator.startAnimating()
        
        spinner?.addSubview(indicator)
        self.view.addSubview(spinner!)
    }
    
    func transitionToTabBar() {
        let tabBarController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.tabBarController) as! UITabBarController
        
        navigationController?.pushViewController(tabBarController, animated: true)
    }
    
    @IBAction func backToAuth(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
