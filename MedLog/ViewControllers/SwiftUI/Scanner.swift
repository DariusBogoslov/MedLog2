//
//  Scanner.swift
//  MedLog
//
//  Created by Darius Bogoslov on 05/05/2020.
//  Copyright © 2020 Darius Bogoslov. All rights reserved.
//

import SwiftUI
import CarBode

struct Scanner: View {
    @State var showEdit: Bool = false
    @State var name: String = ""
	@State var uuid: String = ""
	var scannerVC: ScannerViewController
	
    var body: some View {
        VStack {
            if showEdit {
				MedicalRecordEntry(showEdit: $showEdit, name: name, uuid: uuid, scannerVC: scannerVC)
            } else {
				ScannerButton(showEdit: $showEdit, name: $name, uuid: $uuid)
            }
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
}

struct ScannerButton: View {
    @State var showScanner: Bool = false
    @Binding var showEdit: Bool
    @Binding var name: String
	@Binding var uuid: String
    
    var body: some View {
        
        VStack{
            
            Text("Scan QR Code to add entry")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)))
                .padding(.bottom, 20)
            
            Button(action: {
                self.showScanner.toggle()
            }) {
                ZStack{
                    Capsule()
                        .fill(Color(#colorLiteral(red: 0.140293479, green: 0.3662798405, blue: 0.5998988152, alpha: 1)))
                        .overlay(Image(systemName: "qrcode.viewfinder").foregroundColor(.white).font(.system(size: 40)))
                        .frame(width: 200, height: 50)
                }
            }
            .sheet(isPresented: $showScanner) {
                ZStack {
                    CBScanner(supportBarcode: [.qr, .aztec])
                        .interval(delay: 5.0)
                        .found {
							self.uuid = $0
							FirebaseWorker.worker.getNameByUID($0)
								.then { name in
									self.showEdit = true
									self.name = name
							}
                    }
                }.edgesIgnoringSafeArea(.all)
            }
        }
    }
}

struct MedicalRecordEntry: View {
    @Binding var showEdit: Bool
    @State var name: String
	@State var uuid: String
	@State var bloodPressure: String = ""
	@State var temperature: String = ""
	var scannerVC: ScannerViewController
	
    var body: some View {
        VStack {
			HStack {
				Text("Patient name:")
					.font(.system(size: 18, weight: .semibold))
					.foregroundColor(.gray)
				Text(name)
					.font(.system(size: 20, weight: .medium))
					.foregroundColor(Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)))
			}.padding()
			
			TextField("Enter BPM", text: self.$bloodPressure)
				.keyboardType(.numberPad)
				.textFieldStyle(RoundedBorderTextFieldStyle())
				.padding(20)
			TextField("Enter temperature", text: self.$temperature)
				.keyboardType(.numberPad)
				.textFieldStyle(RoundedBorderTextFieldStyle())
				.padding(20)
			
			Button(action: {
				FirebaseWorker.worker.addMedicalEntry(self.bloodPressure, self.temperature, self.uuid)
					.then{ response in
						if(response) {
							self.showEdit = false
							self.scannerVC.showToastMessage("Entry successfully added", "success")
						} else {
							self.scannerVC.showToastMessage("Error writing entry to database", "failure")
						}
				}
			}) {
				Capsule()
					.fill(Color(#colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)))
					.overlay(Text("Add entry").foregroundColor(.white))
					.frame(width: 100, height: 50)
			}
			
            Button(action: {self.showEdit = false}) {
                Capsule()
                    .fill(Color(#colorLiteral(red: 0.5019607843, green: 0, blue: 0.1254901961, alpha: 1)))
                    .overlay(Text("Cancel").foregroundColor(.white))
                    .frame(width: 100, height: 50)
            }
        }
    }
}
