//
//  FirebaseWorker.swift
//  MedLog
//
//  Created by Darius Bogoslov on 26/04/2020.
//  Copyright © 2020 Darius Bogoslov. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseCore
import FirebaseAuth
import Promises

class FirebaseWorker: NSObject {
	static let worker = FirebaseWorker()
	var userID: String!
	let db = Firestore.firestore()
	let settings = FirestoreSettings()
	let userEmail = Auth.auth().currentUser?.email
	let currentWeek = NSCalendar.current.component(.weekOfYear, from: Date())
	var flag = false
	var weeks: [[String: CGFloat]] = []
	var userProfileData: [String: Any] = [:]
	var userMedicalRecords: [[[String: Any]]] = [[], []]
	var userInvitations: [[String: String]] = []
	var inviteMadeBy: [[Int: String]] = []
	var gaugeProgress: CGFloat = 0
	var weekBPMAverage: CGFloat = 0
	
	
	lazy var background: DispatchQueue = {
		return DispatchQueue.init(label: "background.queue.Dashboard", attributes: .concurrent)
	}()
	
	func configureDB() {
		settings.isPersistenceEnabled = true
		db.settings = settings
	}
	
	func provisionFromFirebase() {
		loadUserData()
		getFullname()
		loadUserProfile()
		getUserInvitations()
		getRelativesMedicalEntries()
		dashboardGauge()
	}
	
	func getFullname() {
		userID = Auth.auth().currentUser?.uid
		db.collection("users").document(UserDefaults.standard.string(forKey: "userFID")!).getDocument{(document, error) in
			if error != nil {
				print("Error while getting user name")
			}
			
			if((document?.exists) != false) {
				let dataDescription = document!.data()!
				let fullName = "\(dataDescription["firstName"]!) \(dataDescription["lastName"]!)"
				let userClass = "\(dataDescription["userClass"]!)"
				UserDefaults.standard.set(fullName, forKey: "userFullName")
				UserDefaults.standard.set(userClass, forKey: "userClass")
			}
		}
	}
	
	func getNameByUID(_ uid: String) -> Promise<String>{
		return Promise<String> {(resolve, reject) in
			self.db.collection("users").document(uid).getDocument{(document, error) in
				if error != nil {
					print("Error while getting user name")
				}
				
				if((document?.exists) != false) {
					let dataDescription = document!.data()!
					let fullName = "\(dataDescription["firstName"]!) \(dataDescription["lastName"]!)"
					resolve(fullName)
				}
			}
		}
	}
	
	func getAverage(_ document: Dictionary<String, Any>, _ weekNo: Int) {
		
		var sum = 0
		for (_, value) in document {
			sum += value as! Int
		}
		
		if(weekNo == currentWeek) {
			self.weekBPMAverage = CGFloat(sum) / CGFloat(document.keys.count)
			UserDefaults.standard.set(document, forKey: "week\(self.currentWeek)")
		}
		
		self.weeks.append(["\(weekNo)": CGFloat(sum) / CGFloat(document.keys.count)])
	}
	
	func getTemperatureAverage() -> Promise<[String: Any]> {
		return Promise<[String: Any]> {(resolve, reject) in
			self.db.collection("userData").document(self.userID).collection("week\(self.currentWeek)").document("temperature").getDocument {(document, error) in
				if error != nil {
					print("Error while getting week data")
				}
				if((document?.exists) != false) {
					let dataDescription = document!.data()!
					resolve(dataDescription)
				}
			}
		}
	}
	
	
	func dashboardGauge() {
		var sum = 0
		getTemperatureAverage()
			.then{result in
				for (_, value) in result {
					sum += value as! Int
				}
				
				self.gaugeProgress = self.weekBPMAverage / (CGFloat(sum) / CGFloat(result.keys.count))
		}
	}
	
	func getWeekData(_ weekNo: Int) -> Promise<Dictionary<String, Any>> {
		return Promise<[String: Any]> {(resolve, reject) in
			self.db.collection("userData").document(self.userID).collection("week\(weekNo)").document("bloodPressure").getDocument {(document, error) in
				
				if error != nil {
					print("Error while getting week data")
				}
				if((document?.exists) != false) {
					let dataDescription = document!.data()!
					resolve(dataDescription)
				}
			}
		}
	}
	
	func insertUserRecord(_ document: Dictionary<String, Any>, _ week: String) {
		
		var data: [String: Int] = [:]
		for(key, value) in document {
			data[key] = value as? Int
		}
		
		userMedicalRecords[0].append([week: data])
	}
	
	func loadUserData()  {
		self.background.async {
			for index in 0...9 {
				let weekNo = self.currentWeek - index
				let weekData = try! await(self.getWeekData(weekNo))
				if(index <= 4) {
					self.getAverage(weekData, weekNo)
				}
				self.insertUserRecord(weekData, "Week \(weekNo)")
			}
		}
	}
	
	func loadUserProfile() {
		getUserProfileData()
			.then({(data) in
				self.userProfileData = data
			})
	}
	
	func getUserProfileData() -> Promise<[String: Any]> {
		let promise = Promise<[String: Any]> {(resolve, reject) in
			self.db.collection("users").document(UserDefaults.standard.string(forKey: "userFID")!).getDocument {(document, error) in
				if error != nil {
					print("Error while getting user profile data")
				}
				
				if((document?.exists) != false) {
					let dataDescription = document!.data()!
					resolve(dataDescription)
				}
			}
		}
		
		return promise
	}
	
	func updateLocalData(_ updatedData: [String: Any]) {
		updatedData.forEach { (key, value) in
			userProfileData[key] = value as? String != nil ? value : userProfileData[key]
		}
	}
	
	func updateUserProfileData(_ updatedData: [String: Any]) -> Promise<Bool> {
		return Promise<Bool> {(resolve, reject) in
			self.db.collection("users").document(UserDefaults.standard.string(forKey: "userFID")!).updateData([
				"firstName": updatedData["firstName"]!,
				"lastName": updatedData["lastName"]!,
				"age": updatedData["age"]!,
				"address": updatedData["address"]!,
				"city": updatedData["city"]!,
				"county": updatedData["county"]!
			]) { error in
				if error != nil {
					reject(error!)
				} else {
					resolve(true)
				}
			}
		}
	}
	
	func addRelativeByEmail(_ userEmail: String) -> Promise<Bool> {
		return Promise<String> {(resolve, reject) in
			self.db.collection("users").whereField("email", isEqualTo: userEmail).getDocuments {(data, error) in
				resolve(data!.documents[0].documentID)
			}
		}.then{userID in
			return self.addRelativeUsingQR(userID)
		}
	}
	
	func verifyIfUserExists(_ email: String) -> Promise<Bool> {
		return Promise<Bool> {(resolve, reject) in
			Auth.auth().signIn(withEmail: email, password: " ") {(user, error) in
				var canRegister = false
				if error != nil {
					if(error?._code == 17009) {
						canRegister = false
					} else if(error?._code == 17011){
						canRegister = true
					}
				}
				resolve(canRegister)
			}
		}
	}
	
	func addRelativeUsingQR(_ userID: String) -> Promise<Bool>{
		return Promise<Any> {(resolve, reject) in
			self.db.collection("access").document(userID).collection("invites").document(self.userID).setData([
				"name": UserDefaults.standard.string(forKey: "userFullName")!,
				"state": "pending"
			]) { err in
				if err != nil {
					reject(false as! Error)
				} else {
					resolve(true)
				}
			}
		}.then {response in
			
			return Promise<Any> {(resolve, reject) in
				self.db.collection("users").document(userID).getDocument {(document, error) in
					if error != nil {
						print("Error while getting user name")
					}
					
					if((document?.exists) != false) {
						let dataDescription = document!.data()!
						resolve("\(dataDescription["firstName"]!) \(dataDescription["lastName"]!)")
					} else {
						reject("No user" as! Error)
					}
				}
			}
		}.then { fullName in
			return Promise<Bool> {(resolve, reject) in
				self.db.collection("access").document(UserDefaults.standard.string(forKey: "userFID")!).collection("invites").document(userID).setData([
					"name": fullName,
					"state": "pending",
					"selfAdd": "true"
				]) {err in
					if err != nil {
						reject(false as! Error)
					} else {
						resolve(true)
					}
				}
			}
		}
	}
	
	func getUserInvitations() {
		db.collection("access").document(UserDefaults.standard.string(forKey: "userFID")!).collection("invites").getDocuments {(snapshot, error) in
			if error != nil {
				print("Error while getting user profile data")
			}
			
			if(!snapshot!.isEmpty) {
				for (index, document) in snapshot!.documents.enumerated() {
					self.userInvitations.append([(document.data()["name"] as! String): (document.data()["state"] as! String)])
					if(document.data()["selfAdd"] != nil) {
						self.inviteMadeBy.append([index: (document.data()["selfAdd"] as! String)])
					} else {
						self.inviteMadeBy.append([index: "false"])
					}
				}
			}
		}
	}
	
	func removeUserInvite(_ data: [String: String]) -> Promise<Bool> {
		
		return Promise<String> {(resolve, reject) in
			self.db.collection("access").document(self.userID).collection("invites").whereField("name", isEqualTo: Array(data)[0].key).getDocuments {(data, error) in
				if error != nil {
					print("Error while getting user profile data")
				}
				
				if(!data!.isEmpty) {
					let inviteID = data!.documents[0].documentID
					resolve("\(inviteID)")
				}
			}
		}.then {inviteID in
			return Promise<String> {(resolve, reject) in
				self.db.collection("access").document(self.userID).collection("invites").document(inviteID).delete() { error in
					if error != nil {
						print("Error deleting user invite from personal DB")
					}
					resolve(inviteID)
				}
			}
		}.then {inviteID in
			return Promise<Bool> {(resolve, reject) in
				self.db.collection("access").document(inviteID).collection("invites").document(self.userID).delete() { error in
					if error != nil {
						print("Error deleting user from invitee DB")
					}
					
					resolve(true)
				}
			}
		}		
	}
	
	func acceptInvite(_ data: [String: String]) -> Promise<Bool> {
		return Promise<String> {(resolve, reject) in
			self.db.collection("access").document(self.userID).collection("invites").whereField("name", isEqualTo: Array(data)[0].key).getDocuments {(data, error) in
				if error != nil {
					print("Error while getting user profile data")
				}
				
				if(!data!.isEmpty) {
					let inviteID = data!.documents[0].documentID
					resolve("\(inviteID)")
				}
			}
		}.then{inviteID in
			return Promise<String> {(resolve, reject) in
				self.db.collection("access").document(self.userID).collection("invites").document(inviteID).updateData([
					"state": "true"
				]) {err in
					if err != nil {
						reject(false as! Error)
					} else {
						resolve(inviteID)
					}
				}
			}.then {inviteID in
				return Promise<Bool> {(resolve, reject) in
					self.db.collection("access").document(inviteID).collection("invites").document(self.userID).updateData([
						"state": "true"
					]) { err in
						if err != nil {
							reject(false as! Error)
						} else {
							resolve(true)
						}
					}
				}
			}
		}
	}
	
	func addMedicalEntry(_ BPM: String, _ temperature: String, _ uuid: String) -> Promise<Bool> {
		let days = [
			2: "M",
			3: "Tu",
			4: "W",
			5: "Th",
			6: "F",
			7: "Sa",
			1: "Su"
		]
		
		let day = days[NSCalendar.current.component(.weekday, from: Date())]
		
		return Promise<Bool> {(resolve, reject) in
			self.db.collection("userData").document(uuid).collection("week\(self.currentWeek)").document("bloodPressure").updateData([
				day: Int(BPM)!
			]) {error in
				if error != nil {
					reject(error!)
				} else {
					resolve(true)
				}
			}
		}.then { response in
			return Promise<Bool> {(resolve, reject) in				
				self.db.collection("userData").document(uuid).collection("week\(self.currentWeek)").document("temperature").updateData([
					day: Int(temperature)!
				]) {error in
					if error != nil {
						reject(error!)
					} else {
						resolve(true)
					}
				}
			}
		}
	}
	
	func getRelativesMedicalEntries() {
		Promise<[[String: String]]> {(resolve, reject) in
			self.db.collection("access").document(self.userID).collection("invites").getDocuments { (snapshot, error) in
				if error != nil {
					reject(error!)
				}
				
				if(!snapshot!.isEmpty) {
					var ids: [[String: String]] = []
					for document in snapshot!.documents {
						
						ids.append([(document.data()["name"] as! String): document.documentID])
					}
					resolve(ids)
				}
			}
		}.then { ids in
			for id in ids {
				self.getMedicalEntriesForID(id)
			}
		}
	}
	
	func getMedicalEntriesForID(_ id: [String: String]) {
		
		let name = Array(id)[0].key
		let userID = Array(id)[0].value
		
		self.getRelativeWeekData(self.currentWeek, userID)
			.then{response in
				self.parseMedicalEntries(response)
		}.then { response in
			self.userMedicalRecords[1].append([name: response])
		}
	}
	
	func parseMedicalEntries(_ document: Dictionary<String, Any>) -> [String: Int] {
		var data: [String: Int] = [:]
		for(key, value) in document {
			data[key] = value as? Int
		}
		
		return data
	}
	
	func getRelativeWeekData(_ weekNo: Int, _ userID: String) -> Promise<[String: Any]>{
		return Promise<[String: Any]> {(resolve, reject) in
			self.db.collection("userData").document(userID).collection("week\(weekNo)").document("bloodPressure").getDocument {(document, error) in
				if error != nil {
					print("Error while getting week data")
				}
				if((document?.exists) != false) {
					let dataDescription = document!.data()!
					resolve(dataDescription)
				}
			}
		}
	}
}
