//
//  EditProfileViewController.swift
//  MedLog
//
//  Created by Darius Bogoslov on 06/05/2020.
//  Copyright © 2020 Darius Bogoslov. All rights reserved.
//

import UIKit
import Promises

class EditProfileViewController: UIViewController {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var firstNameLabel: UITextField!
    @IBOutlet weak var lastNameLabel: UITextField!
    @IBOutlet weak var emailLabel: UITextField!
    @IBOutlet weak var ageLabel: UITextField!
    @IBOutlet weak var addressLabel: UITextField!
    @IBOutlet weak var cityLabel: UITextField!
    @IBOutlet weak var countyLabel: UITextField!
    @IBOutlet weak var emailLock: UIButton!
	
	
    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
        setupElements()
    }
    
    func loadData() {
        let userProfileData = FirebaseWorker.worker.userProfileData
        
        firstNameLabel.text = userProfileData["firstName"] != nil ? userProfileData["firstName"] as! String : ""
        lastNameLabel.text = userProfileData["lastName"] != nil ? userProfileData["lastName"] as! String : ""
        emailLabel.text = UserDefaults.standard.string(forKey: "userEmail")
        ageLabel.text = userProfileData["age"] != nil ? userProfileData["age"] as! String : ""
        addressLabel.text = userProfileData["address"] != nil ? userProfileData["address"] as! String : ""
        cityLabel.text = userProfileData["city"] != nil ? userProfileData["city"] as! String : ""
        countyLabel.text = userProfileData["county"] != nil ? userProfileData["county"] as! String : ""
    }
    
    
    @IBAction func dismissEditProfile(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setupElements() {
        let buttonConfig = UIImage.SymbolConfiguration(pointSize: 20.0, weight: .bold)
        
        emailLock.setTitle("", for: UIControl.State.normal)
        emailLock.setImage(UIImage(systemName: "checkmark.shield.fill", withConfiguration: buttonConfig), for: UIControl.State.normal)
        emailLock.tintColor = UIColor.init(red: 72/255, green: 227/255, blue: 123/255, alpha: 1)
        
        
        closeButton.setTitle("", for: UIControl.State.normal)
        closeButton.setImage(UIImage(systemName: "x.circle.fill", withConfiguration: buttonConfig), for: UIControl.State.normal)
        closeButton.tintColor = UIColor.init(red: 36/255, green: 93/255, blue: 153/255, alpha: 1)
        
        doneButton.setTitle("", for: UIControl.State.normal)
        doneButton.setImage(UIImage(systemName: "checkmark.circle.fill", withConfiguration: buttonConfig), for: UIControl.State.normal)
        doneButton.tintColor = UIColor.init(red: 36/255, green: 93/255, blue: 153/255, alpha: 1)
    }
    
    @IBAction func updateProfile(_ sender: Any) {
        self.view.endEditing(true)
        var updatedData: [String: Any] = [:]
        
        updatedData["firstName"] = firstNameLabel.text
        updatedData["lastName"] = lastNameLabel.text
        updatedData["age"] = ageLabel.text
        updatedData["address"] = addressLabel.text
        updatedData["city"] = cityLabel.text
        updatedData["county"] = countyLabel.text
        
        FirebaseWorker.worker.updateLocalData(updatedData)
		FirebaseWorker.worker.updateUserProfileData(updatedData)
			.then {response in
				if(response is Error) {
					let alert = UIAlertController(title: "Error", message: "Profile data couldn't be updated", preferredStyle: UIAlertController.Style.alert)
					
					self.present(alert, animated: true)
				} else {
					self.dismiss(animated: true, completion: nil)
				}
		}
    }
}
