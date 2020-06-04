//
//  MedicalRecords.swift
//  MedLog
//
//  Created by Darius Bogoslov on 04/05/2020.
//  Copyright © 2020 Darius Bogoslov. All rights reserved.
//

import SwiftUI

struct MedicalRecords: View {
	@State var pickerSelectedItem = 0
	var medicalRecords: [[[String: [String: Int]]]]
	
	var body: some View {
		VStack {
			Picker(selection: $pickerSelectedItem, label: Text("")) {
				Text("Personal").tag(0)
				Text("Relatives").tag(1)
			}.pickerStyle(SegmentedPickerStyle())
				.padding(.horizontal, 20)
			Spacer()
			if(pickerSelectedItem == 0) {
				if(medicalRecords[pickerSelectedItem].count == 0) {
					Text("No data available")
				} else {
				ScrollView(.vertical, showsIndicators: false)
				{
					ForEach(medicalRecords[pickerSelectedItem], id: \.self) {dict in
						return PersonalCard(dict: dict)
					}
				}
				}
			} else {
				if(medicalRecords[pickerSelectedItem].count == 0) {
					Text("No relatives approved")
				} else {
					ScrollView(.vertical, showsIndicators: false ) {
						ForEach(medicalRecords[pickerSelectedItem], id:\.self) { dict in
							return RelativesCard(data: dict)
						}
					}
				}
			}
			Spacer()
		}
		.navigationBarTitle("")
		.navigationBarHidden(true)
	}
}



struct RelativesCard: View {
	//let index: Int
	@State private var show_modal: Bool = false
	let data: [String: [String: Int]]
	var body: some View {
		ZStack {
			Button(action: {
				self.show_modal.toggle()
			}) {
				ZStack {
					Rectangle()
						.fill(Color(#colorLiteral(red: 0.7033629442, green: 0.7033629442, blue: 0.7033629442, alpha: 0.4535798373)))
						.cornerRadius(12)
						.frame(width: 330, height: 100)
					Text(Array(data)[0].key)
						.font(.system(size: 18, weight: .semibold))
						.foregroundColor(Color(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)))
				}.sheet(isPresented: self.$show_modal) {
					RelativeModalView(data: self.returnArray(Array(self.data)[0].value))
				}
			}
		}
	}
	
	func returnArray(_ dict: [String: Int]) -> [(String, Int)] {
		let daysOfWeek = [
			"M": 0,
			"Tu": 1,
			"W": 2,
			"Th": 3,
			"F": 4,
			"Sa": 5,
			"Su": 6
		]
		
		var returnArr: [(String, Int)] = []
		
		_ = dict.map { key, value in
			returnArr.append((key, value))
		}
		
		returnArr.sort(by: {daysOfWeek[$0.0]! < daysOfWeek[$1.0]!})
		
		return returnArr
	}
}

struct RelativeModalView: View {
	var data: [(first: String,second: Int)]
	var body: some View {
		ZStack {
			Color(#colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1))
				.edgesIgnoringSafeArea(.all)
			VStack {
				ZStack{
					Rectangle()
						.fill(Color(#colorLiteral(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)))
						.cornerRadius(12)
						.frame(width: 330, height: 300)
					VStack{
						ForEach(0..<data.count, id: \.self) {index in
							Text("\(self.getDayName(self.data[index].first)): \(self.data[index].second)")
								.font(.system(size: 16, weight: .semibold))
								.foregroundColor(Color(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)))
						}
					}
				}
			}
		}
	}
	
	func getDayName(_ shortName: String) -> String {
		let days = [
			"M": "Monday",
			"Tu": "Tuesday",
			"W": "Wednesday",
			"Th": "Thursday",
			"F": "Friday",
			"Sa": "Saturday",
			"Su": "Sunday"
		]
		
		return days[shortName]!
	}
}

struct PersonalCard: View {
	@State private var show_modal: Bool = false
	var dict: [String: [String: Int]]
	var body: some View {
		ZStack{
			Button(action: {
				self.show_modal.toggle()
			}) {
				ZStack{
					Rectangle()
						.fill(Color(#colorLiteral(red: 0.7033629442, green: 0.7033629442, blue: 0.7033629442, alpha: 0.4535798373)))
						.cornerRadius(12)
						.frame(width: 330, height: 100)
					Text(Array(dict)[0].key)
						.font(.system(size: 18, weight: .semibold))
						.foregroundColor(Color(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)))
				}
			}.sheet(isPresented: self.$show_modal) {
				ModalView(dateRange: self.weekInterval(Array(self.dict)[0].key),data: self.returnArray(Array(self.dict)[0].value))
			}
		}
	}
	
	func weekInterval(_ weekNo: String) -> String {
		let week = weekNo.filter("0123456789".contains)
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "dd.MM.yyyy"
		let calendar = Calendar.current
		let year = calendar.component(.yearForWeekOfYear, from: Date())
		let startComponents = DateComponents(weekOfYear: Int(week), yearForWeekOfYear: year)
		let startDate = calendar.date(from: startComponents)!
		let endComponents = DateComponents(day:7, second: -1)
		let endDate = calendar.date(byAdding: endComponents, to: startDate)!
		let dateRange = "\(dateFormatter.string(from: startDate)) - \(dateFormatter.string(from: endDate))"
		return dateRange
	}
	
	
	func returnArray(_ dict: [String: Int]) -> [(String, Int)] {
		let daysOfWeek = [
			"M": 0,
			"Tu": 1,
			"W": 2,
			"Th": 3,
			"F": 4,
			"Sa": 5,
			"Su": 6
		]
		
		var returnArr: [(String, Int)] = []
		
		_ = dict.map { key, value in
			returnArr.append((key, value))
		}
		
		returnArr.sort(by: {daysOfWeek[$0.0]! < daysOfWeek[$1.0]!})
		
		return returnArr
	}
}

struct ModalView: View {
	var dateRange: String
	var data: [(first: String,second: Int)]
	var body: some View {
		ZStack {
			Color(#colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1))
				.edgesIgnoringSafeArea(.all)
			VStack {
				Text(dateRange)
					.font(.system(size: 18, weight: .medium))
					.foregroundColor(Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)))
					.padding()
				ZStack{
					Rectangle()
						.fill(Color(#colorLiteral(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)))
						.cornerRadius(12)
						.frame(width: 330, height: 300)
					VStack{
						ForEach(0..<data.count, id: \.self) {index in
							Text("\(self.getDayName(self.data[index].first)): \(self.data[index].second)")
								.font(.system(size: 16, weight: .semibold))
								.foregroundColor(Color(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)))
						}
					}
				}
				
			}
		}
	}
	
	func getDayName(_ shortName: String) -> String {
		let days = [
			"M": "Monday",
			"Tu": "Tuesday",
			"W": "Wednesday",
			"Th": "Thursday",
			"F": "Friday",
			"Sa": "Saturday",
			"Su": "Sunday"
		]
		
		return days[shortName]!
	}
}
