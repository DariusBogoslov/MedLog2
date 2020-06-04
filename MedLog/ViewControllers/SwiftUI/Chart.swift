//
//  Chart.swift
//  MedLog
//
//  Created by Darius Bogoslov on 30/04/2020.
//  Copyright © 2020 Darius Bogoslov. All rights reserved.
//

import SwiftUI



struct Chart: View {
	
	@State var pickerSelectedItem = 0
	
	var gaugeProgress: CGFloat
	var chartData: [[[String: CGFloat]]]
	
	var body: some View {
		
		VStack {
			Picker(selection: $pickerSelectedItem, label: Text("")) {
				Text("Weekday").tag(0)
				Text("Week").tag(1)
			}.pickerStyle(SegmentedPickerStyle())
				.padding(.horizontal, 4)
			Spacer()
			HStack {
				if(chartData.count == 0) {
					Text("No data available")
				} else {
					ForEach(chartData[pickerSelectedItem], id: \.self) {dict in
						return BarView(dict: dict)
					}
				}
			}.animation(.default)
				.padding(.bottom, 50)
			Meter(progress: gaugeProgress)
		}
		.navigationBarTitle("")
		.navigationBarHidden(true)
	}
}

struct BarView: View {
	var dict: [String: CGFloat]
	
	var body: some View {
		VStack {
			ZStack (alignment: .bottom) {
				Capsule().frame(width: 30, height: 150)
					.foregroundColor(Color.black.opacity(0.1))
				Capsule().frame(width: 30, height: Array(dict)[0].value)
					.foregroundColor(Color(#colorLiteral(red: 0.1847055256, green: 0.4087523818, blue: 0.5750542879, alpha: 1)))
				Text("\(Int(Array(dict)[0].value))").font(.system(size: 10, weight: .semibold)).foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
					.padding(.bottom, Array(dict)[0].value - 20)
			}
			Text(Array(dict)[0].key)
				.fontWeight(.semibold)
				.padding(.top, 8)
		}
	}
}

struct Meter: View {
	var progress: CGFloat
	
	var body: some View {
		ZStack {
			ZStack {
				
				Circle()
					.trim(from: 0, to: 0.5)
					.stroke(LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.2804591525, green: 0.8888034948, blue: 0.4827814814, alpha: 1)), Color(#colorLiteral(red: 0.8888034948, green: 0.8503283456, blue: 0.205595538, alpha: 1)), Color(#colorLiteral(red: 0.8888034948, green: 0.078649739, blue: 0.04561639489, alpha: 1))]), startPoint: .trailing, endPoint: .leading), lineWidth: 55).opacity(0.3)
					.frame(width: 280, height: 280)
				
				Circle()
					.trim(from: 0, to: self.setProgress())
					.stroke(AngularGradient(gradient: .init(colors: [Color(#colorLiteral(red: 0.1847055256, green: 0.4087523818, blue: 0.5750542879, alpha: 1)), Color(#colorLiteral(red: 0.1847055256, green: 0.4087523818, blue: 0.5750542879, alpha: 1))]), center: .center, angle: .init(degrees: 180)), lineWidth: 55)
					.frame(width: 280, height: 280)
			}
			.rotationEffect(.init(degrees: 180))
			
			ZStack(alignment: .bottom) {
				Color(#colorLiteral(red: 0.1847055256, green: 0.4087523818, blue: 0.5750542879, alpha: 1))
					.frame(width: 2, height: 95)
				
				Circle()
					.fill(Color(#colorLiteral(red: 0.1847055256, green: 0.4087523818, blue: 0.5750542879, alpha: 1)))
					.frame(width: 15, height: 15)
			}
			.offset(y: -35)
			.rotationEffect(.init(degrees: -90))
			.rotationEffect(.init(degrees: self.setArrow()))
			
			HStack {
				Circle()
					.fill(self.stateColor())
					.frame(width: 15, height: 15)
				Text(self.stateText())
			}
			.background(Capsule().frame(width: self.capsuleWidth(), height: 50)
			.foregroundColor(Color.black.opacity(0.1)))
			.padding(.top, 110)
			
		}
		.padding(.bottom, -140)
	}
	
	func capsuleWidth() -> CGFloat {
		switch progress {
			case 0...50:
				return 200
			case 51...75:
				return 300
			case 76...100:
				return 350
			default:
				return 150
		}
	}
	
	func stateColor() -> Color {
		switch progress {
			case 0...50:
				return Color(#colorLiteral(red: 0.2804591525, green: 0.8888034948, blue: 0.4827814814, alpha: 1))
			case 51...75:
				return Color(#colorLiteral(red: 0.8888034948, green: 0.8503283456, blue: 0.205595538, alpha: 1))
			case 76...100:
				return Color(#colorLiteral(red: 0.8888034948, green: 0.078649739, blue: 0.04561639489, alpha: 1))
			default:
				return Color(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1))
		}
	}
	
	func stateText() -> String {
		switch progress {
			case 0...50:
				return "You are risk free"
			case 51...75:
				return "You have a mild risk for a heart disease"
			case 76...100:
				return "You have a high risk to develop a heart disease"
			default:
				return "No data"
		}
	}
	
	func setProgress() -> CGFloat {
		let temp = progress / 2
		return temp * 0.01
	}
	
	func setArrow() -> Double {
		let temp = progress / 100
		return Double(temp * 180)
	}
}

struct Chart_Previews: PreviewProvider {
	static var previews: some View {
		Chart(gaugeProgress: CGFloat(25.0), chartData: [[["M": 55.0], ["Tu": 75.0], ["W": 86.0], ["Th": 77.0], ["F": 81.0], ["Sa": 95.0], ["Su": 100.0]], [["17": 81.57142857142857], ["18": 81.28571428571429]]])
	}
}
