//
//  ProfileViewController.swift
//  MedLog
//
//  Created by Darius Bogoslov on 26/04/2020.
//  Copyright © 2020 Darius Bogoslov. All rights reserved.
//

import UIKit
import FirebaseAuth
import SwiftUI

class ProfileViewController: UIViewController {

    
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var qrCodeView: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var countyLabel: UILabel!
    @IBOutlet weak var ageText: UILabel!
    @IBOutlet weak var addressText: UILabel!
    @IBOutlet weak var cityText: UILabel!
    @IBOutlet weak var countyText: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = UserDefaults.standard.string(forKey: "userFullName")
        setupElements()
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupElements()
    }
        
    func setupElements() {
        Utilities.styleFilledButton(signOutButton, UIColor.init(red: 128/255, green: 0/255, blue: 32/255, alpha: 1))
        Utilities.styleFilledButton(qrCodeView)
        
        nameLabel.font = UIFont.systemFont(ofSize: 32, weight: UIFont.Weight.heavy)
        nameLabel.text = UserDefaults.standard.string(forKey: "userFullName")
        nameLabel.sizeToFit()
        
        let buttonConfig = UIImage.SymbolConfiguration(pointSize: 20.0, weight: .bold)
        editProfileButton.setTitle("", for: UIControl.State.normal)
        editProfileButton.setImage(UIImage(systemName: "pencil.and.ellipsis.rectangle", withConfiguration: buttonConfig), for: UIControl.State.normal)
        editProfileButton.tintColor = UIColor.init(red: 36/255, green: 93/255, blue: 153/255, alpha: 1)
        
        let userDetails = FirebaseWorker.worker.userProfileData
        addStyleToUserDetails(ageLabel)
        addStyleToUserDetails(ageText)
        ageText.text = userDetails["age"] as? String != "" ? userDetails["age"] as? String : "No data"
        addStyleToUserDetails(addressLabel)
        addStyleToUserDetails(addressText)
        addressText.text = userDetails["address"] as? String != "" ? userDetails["address"] as? String : "No data"
        addStyleToUserDetails(cityLabel)
        addStyleToUserDetails(cityText)
        cityText.text = userDetails["city"] as? String != "" ? userDetails["city"] as? String : "No data"
        addStyleToUserDetails(countyLabel)
        addStyleToUserDetails(countyText)
        countyText.text = userDetails["county"] as? String != "" ? userDetails["county"] as? String : "No data"
    }
    
    func addStyleToUserDetails(_ label: UILabel) {
        label.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.medium)
        label.textColor = UIColor.gray
        label.numberOfLines = 0
        label.sizeToFit()
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        let editVC: EditProfileViewController = (self.storyboard?.instantiateViewController(identifier: "editProfile"))!
		
        editVC.modalPresentationStyle = .overCurrentContext
        self.present(editVC, animated: true, completion: nil)
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
        let alert = UIAlertController(title: "", message: "Are you sure you want to sign out?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default))
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.destructive, handler: {action in
            self.signOut()
        }))
        
        self.present(alert, animated: true)
    }
    
    @IBAction func showQRCode(_ sender: Any) {
        viewQR()
    }
	
    func viewQR() {
        let QRViewController = UIViewController()
        let QRimage = generateQRCode(from: UserDefaults.standard.string(forKey: "userFID")!)
        let QRview = UIView()
        let QRcontainer = UIImageView()
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = QRViewController.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        
        QRcontainer.contentMode = UIView.ContentMode.scaleAspectFit
        QRcontainer.frame.size.width = 350
        QRcontainer.frame.size.height = 350
        QRcontainer.center = QRViewController.view.center
        QRcontainer.image = QRimage
        
        QRview.addSubview(QRcontainer)
        QRViewController.view.addSubview(blurEffectView)
        QRViewController.view.addSubview(QRview)
        
        
        QRViewController.modalPresentationStyle = .popover
        self.present(QRViewController, animated: true, completion: nil)
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIAztecCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
    
    func signOut() {
            do {
                try Auth.auth().signOut()
            } catch let error {
                print("Error signing out: %@", error)
            }
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            self.transitionToAuth()
    }
    
    func transitionToAuth() {
        let authViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.authViewController) as! ViewController
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        
        navigationController?.pushViewController(authViewController, animated: false)
    }
    
}
