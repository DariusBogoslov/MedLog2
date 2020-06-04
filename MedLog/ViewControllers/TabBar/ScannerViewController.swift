//
//  ScannerViewController.swift
//  MedLog
//
//  Created by Darius Bogoslov on 05/05/2020.
//  Copyright © 2020 Darius Bogoslov. All rights reserved.
//

import UIKit
import SwiftUI
import Loaf

class ScannerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

         let swiftUIController = UIHostingController(rootView: Scanner(scannerVC: self))
                
                addChild(swiftUIController)

                swiftUIController.view.translatesAutoresizingMaskIntoConstraints = true
                swiftUIController.view.backgroundColor = UIColor.clear
                view.addSubview(swiftUIController.view)
                swiftUIController.view.frame.size.height = 800
                swiftUIController.view.frame.size.width =  (self.navigationController?.view.bounds.width)!
                swiftUIController.view.centerXAnchor.constraint(
                    equalTo: view.centerXAnchor).isActive = true
                 swiftUIController.didMove(toParent: self)
    }
	
	func showToastMessage(_ message: String, _ state: String, _ delay: Double = 0.0) {
		Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { (t) in
			switch(state) {
				case "success":
					Loaf(message, state: .success, sender: self).show(.short)
				case "failure":
					Loaf(message, state: .error, sender: self).show(.short)
				case "warning":
					Loaf(message, state: .warning, sender: self).show(.custom(5))
				default:
					Loaf("Nothing to show", sender:self).show()
			}
		}
	}

}
