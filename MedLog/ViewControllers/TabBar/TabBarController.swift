//
//  TabBarController.swift
//  MedLog
//
//  Created by Darius Bogoslov on 26/04/2020.
//  Copyright © 2020 Darius Bogoslov. All rights reserved.
//

import Foundation
import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        let userClass = UserDefaults.standard.string(forKey: "userClass")
        if(userClass != "admin" && userClass != "doctor") {
            self.viewControllers?.remove(at: 3)
        }
    }
}
