//
//  ViewController.swift
//  MedLog
//
//  Created by Darius Bogoslov on 25/04/2020.
//  Copyright © 2020 Darius Bogoslov. All rights reserved.
//

import UIKit
import CoreData
import FirebaseAuth
import LocalAuthentication
import Promises

class ViewController: UIViewController {

    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        overrideUserInterfaceStyle = .light
        setupElements()
        applyMotionEffects(toView: backgroundImage, magnitude: 25)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        loginButton.backgroundColor = .white
        loginButton.alpha = 0.5
        
        if(UserDefaults.standard.bool(forKey: "userIsLogged")) {
			FirebaseWorker.worker.provisionFromFirebase()
            let buttonConfig = UIImage.SymbolConfiguration(pointSize: 20.0, weight: .bold)
            self.loginButton.setTitle("", for: UIControl.State.normal)
            self.loginButton.setImage(UIImage(systemName: "faceid", withConfiguration: buttonConfig), for: UIControl.State.normal)
            self.loginButton.tintColor = UIColor.systemBlue
        }
    }
    
    func applyMotionEffects (toView: UIView, magnitude: Float) {
        let xMotion = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        xMotion.minimumRelativeValue = -magnitude
        xMotion.maximumRelativeValue = magnitude
        
        let yMotion = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        yMotion.minimumRelativeValue = -magnitude
        yMotion.maximumRelativeValue = magnitude
        
        let group = UIMotionEffectGroup()
        group.motionEffects = [xMotion, yMotion]
        
        view.addMotionEffect(group)
    }
    
    func setupElements() {
        Utilities.styleFilledButton(signUpButton)
        Utilities.styleHollowButton(loginButton)
    }
    
    @objc func BiometricLogin() {
        let context:LAContext = LAContext()
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        {
            
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authentification is needed to proceed", reply: { (wasCorrect, error) in
                DispatchQueue.main.async
                    {
                        if wasCorrect {
                            self.transitionToTabBar()
                        } else {
                            self.transitionToLogin()
                        }
                }
            })
        }

    }
    
    @IBAction func loginAction(_ sender: Any) {
        if(UserDefaults.standard.bool(forKey: "userIsLogged")) {
            BiometricLogin()
        } else {
            self.transitionToLogin()
        }
    }
    
    @IBAction func signUpAction(_ sender: Any) {
        self.transitionToSignUp()
    }
    
    func transitionToTabBar() {
        let tabBarController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.tabBarController) as! UITabBarController
        
        navigationController?.pushViewController(tabBarController, animated: true)
    }
    
    func transitionToLogin() {
        let loginViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.loginViewController) as! LoginViewController
      
        navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    func transitionToSignUp() {
        let signUpViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.signUpViewController) as! SignUpViewController
      
        navigationController?.pushViewController(signUpViewController, animated: true)
    }
    
}

