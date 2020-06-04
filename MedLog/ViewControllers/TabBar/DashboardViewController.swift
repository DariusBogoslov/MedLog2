//
//  DashboardViewController.swift
//  MedLog
//
//  Created by Darius Bogoslov on 26/04/2020.
//  Copyright © 2020 Darius Bogoslov. All rights reserved.
//

import UIKit
import SwiftUI

class DashboardViewController: UIViewController {


    var chartData: [[[String: CGFloat]]] = []
    var currentWeek = NSCalendar.current.component(.weekOfYear, from: Date())
    @IBOutlet weak var welcomeBack: UILabel!
    @IBOutlet weak var fullName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getUserData()
        embedController()
    }
    
    func embedController() {
        welcomeBack.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.medium)
        welcomeBack.textColor = UIColor.gray
        fullName.font = UIFont.systemFont(ofSize: 32, weight: UIFont.Weight.heavy)
        fullName.text = UserDefaults.standard.string(forKey: "userFullName")
        fullName.sizeToFit()
		let swiftUIController = UIHostingController(rootView: Chart(gaugeProgress: FirebaseWorker.worker.gaugeProgress, chartData: chartData))
        
        addChild(swiftUIController)
        swiftUIController.view.translatesAutoresizingMaskIntoConstraints = false
        swiftUIController.view.backgroundColor = UIColor.clear
        view.addSubview(swiftUIController.view)
        swiftUIController.view.centerXAnchor.constraint(
            equalTo: view.centerXAnchor).isActive = true
        swiftUIController.view.centerYAnchor.constraint(
            equalTo: view.centerYAnchor).isActive = true
        
        swiftUIController.didMove(toParent: self)
    }
    
    func getUserData() {
        let daysOfWeek = [
            "M": 0,
            "Tu": 1,
            "W": 2,
            "Th": 3,
            "F": 4,
            "Sa": 5,
            "Su": 6
        ]
        
        var userData: [[String: CGFloat]] = []
        
		if(FirebaseWorker.worker.weeks.count != 0)
		{
			let savedUserData = UserDefaults.standard.dictionary(forKey: "week\(currentWeek)")
			let sortedData = savedUserData!.sorted(by: {daysOfWeek[$0.key]! < daysOfWeek[$1.key]!})
			
			let savedWeekData = FirebaseWorker.worker.weeks.unique()
			let sortedWeekData = savedWeekData.sorted(by: {$0.keys.first! < $1.keys.first!})
			
			sortedData.forEach { (key, value) in
				userData.append([key: value as! CGFloat])
			}
			
			chartData.append(userData)
			chartData.append(sortedWeekData)
		}
    }
}

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
}
