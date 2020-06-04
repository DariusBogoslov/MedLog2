//
//  RelativesViewController.swift
//  MedLog
//
//  Created by Darius Bogoslov on 04/05/2020.
//  Copyright © 2020 Darius Bogoslov. All rights reserved.
//

import UIKit
import SwiftUI

class MedicalRecordsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
		print(FirebaseWorker.worker.userMedicalRecords)
		let swiftUIController = UIHostingController(rootView: MedicalRecords(medicalRecords: FirebaseWorker.worker.userMedicalRecords as! [[[String : [String : Int]]]]))
        
        addChild(swiftUIController)

        swiftUIController.view.translatesAutoresizingMaskIntoConstraints = true
        swiftUIController.view.backgroundColor = UIColor.clear
        view.addSubview(swiftUIController.view)
        swiftUIController.view.frame.size.height = (self.navigationController?.view.bounds.height)!
        swiftUIController.view.frame.size.width =  (self.navigationController?.view.bounds.width)!
        swiftUIController.view.centerXAnchor.constraint(
            equalTo: view.centerXAnchor).isActive = true
         swiftUIController.didMove(toParent: self)
    }
    

}
