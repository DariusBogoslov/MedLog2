//
//  Access.swift
//  MedLog
//
//  Created by Darius Bogoslov on 06/05/2020.
//  Copyright © 2020 Darius Bogoslov. All rights reserved.
//

import SwiftUI
import CarBode
import Loaf
import Promises

struct Access: View {
    @State private var pickerSelectedItem = 0
    @State private var showScanner: Bool = false
    @State private var showAddEmail: Bool = false
    @State private var searchEmail: String = ""
    @State var userInvitations: [[String: String]]
	@State var inviteMadeBy: [[Int: String]]
    var requestsVC: RequestsViewController
	
	
    var body: some View {
        VStack {
            Picker(selection: $pickerSelectedItem, label: Text("")) {
                Text("Require access").tag(0)
                Text("Invites").tag(1)
            }.pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 20)
            Spacer()
            if(pickerSelectedItem == 0) {
                RequireAccess(showScanner: $showScanner, showAddEmail: $showAddEmail, searchEmail: searchEmail, requestsVC: requestsVC)
			} else {
				if(userInvitations.count == 0)
				{
					Text("No invites")
				} else {
					ScrollView(.vertical, showsIndicators: false) {
						ForEach(0..<userInvitations.count, id: \.self) {index in
							return Invites(data: self.userInvitations[index], inviteMadeBy: self.inviteMadeBy[index], requestsVC: self.requestsVC)
						}
					}
				}
			}
            Spacer()
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
	
	func removeInvite() {
		print("")
	}
}

struct RequireAccess: View {
    @Binding var showScanner: Bool
    @Binding var showAddEmail: Bool
    @State var searchEmail: String
    var requestsVC: RequestsViewController
    
    var body: some View {
        VStack {
            Button(action: {
                self.showScanner.toggle()
            }) {
                ZStack{
                    Capsule()
                        .fill(Color(#colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)))
                        .overlay(
                            HStack {
                                Image(systemName: "qrcode.viewfinder").foregroundColor(.white).font(.system(size: 40))
                                Text("Add using QR code").foregroundColor(.white)
                        })
                        .frame(width: 200, height: 50)
                }
            }
            .sheet(isPresented: $showScanner) {
                ZStack {
                    CBScanner(supportBarcode: [.qr, .aztec])
                        .interval(delay: 5.0)
                        .found {
                            if($0 == FirebaseWorker.worker.userID) {
                                self.showScanner = false
                                self.requestsVC.showToastMessage("Cannot send yourself an invitation", "warning", 0.5)
                            } else {
                                FirebaseWorker.worker.addRelativeUsingQR($0)
                                    .then{ response in
                                        if(response) {
                                            self.requestsVC.showToastMessage("Invitation sent", "success")
                                        } else {
                                            self.requestsVC.showToastMessage("Error in sending invitation", "failure")
                                        }
                                }
                                self.showScanner = false
                            }
                            
                    }
                }.edgesIgnoringSafeArea(.all)
            }
            
            Button(action: {
                self.showAddEmail.toggle()
            }) {
                ZStack {
                    Capsule()
                        .fill(Color(#colorLiteral(red: 0.140293479, green: 0.3662798405, blue: 0.5998988152, alpha: 1)))
                        .overlay(
                            HStack{
                                Image(systemName: "at.badge.plus").foregroundColor(.white).font(.system(size: 35))
                                Text("Add using email").foregroundColor(.white)
                        })
                        .frame(width: 200, height: 50)
                    
                }
            }.padding(.top, 20)
                .sheet(isPresented: $showAddEmail) {
                    
                    ZStack {
                        Color(#colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1))
                            .edgesIgnoringSafeArea(.all)
                        VStack {
                            VStack(alignment: .leading) {
                                Text("User email")
                                    .foregroundColor(Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)))
                                    .font(.system(size: 18, weight: .medium))
                                    .padding(.leading, 20)
                                TextField("Enter email", text: self.$searchEmail)
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding(20)
                            }
                            
                            VStack {
                                
                                Button(action: {
                                    if(self.searchEmail == FirebaseWorker.worker.userEmail)
                                    {
                                        self.showAddEmail = false
                                        self.requestsVC.showToastMessage("Cannot send yourself an invitation", "warning", 0.5)
                                    } else {
                                        FirebaseWorker.worker.verifyIfUserExists(self.searchEmail)
                                            .then {response in
                                                if(response == false) {
                                                    FirebaseWorker.worker.addRelativeByEmail(self.searchEmail)
                                                        .then { response in
                                                            if(response) {
                                                                self.requestsVC.showToastMessage("Invitation sent", "success")
                                                            } else {
                                                                self.requestsVC.showToastMessage("Error in sending invitation", "failure")
                                                            }
                                                    }
                                                   
                                                } else if(response == true) {
                                                    self.requestsVC.showToastMessage("Email not linked to any user", "warning", 0.5)
                                                }
                                                 self.showAddEmail = false
                                        }
                                    }
                                })
                                {
                                    ZStack {
                                        Capsule()
                                            .fill(Color(#colorLiteral(red: 0.140293479, green: 0.3662798405, blue: 0.5998988152, alpha: 1)))
                                            .overlay(
                                                HStack {
                                                    Image(systemName: "plus.square.fill").foregroundColor(.white).font(.system(size: 40))
                                                    Text("Send invitation").foregroundColor(.white)
                                            })
                                            .frame(width: 200, height: 50)
                                    }
                                }
                            }
                        }
                    }
            }
        }
    }
}

struct Invites: View {
    @State var data: [String: String]
	@State var inviteMadeBy: [Int: String]
	@State var showingSheet = false
	@State var showInvite = true
	var requestsVC: RequestsViewController
	
    var body: some View {
        ZStack{
			if(self.showInvite) {
            Button(action: {
				self.showingSheet.toggle()
            }) {
                ZStack{
                    Rectangle()
                        .fill(Color(#colorLiteral(red: 0.7033629442, green: 0.7033629442, blue: 0.7033629442, alpha: 0.4535798373)))
                        .cornerRadius(12)
                        .frame(width: 330, height: 100)
                    VStack {
                        VStack {
                            Text(Array(data)[0].key)
                                .foregroundColor(.white)
                        }
                        VStack(alignment: .trailing){
                            invitationState(Array(data)[0].value)
                        }
                    }
                }
			}
			.actionSheet(isPresented: $showingSheet) {
				if(Array(data)[0].value == "pending") {
					if(Array(inviteMadeBy)[0].value == "true") {
						return ActionSheet(title: Text("Actions"), message: Text("Select an option"), buttons: [
							.destructive(Text("Delete request")) {self.showInvite = false
								self.requestsVC.removeInvite(self.data)},
							.cancel()
						])
					} else {
						return ActionSheet(title: Text("Actions"), message: Text("Select an option"), buttons: [
							.default(Text("Approve")) {
								self.requestsVC.acceptInvite(self.data)
								self.data["state"] = "true"
							},
							.destructive(Text("Delete request")) {self.showInvite = false
								self.requestsVC.removeInvite(self.data)},
							.cancel()
						])
					}
				} else if(Array(data)[0].value == "false") {
					return ActionSheet(title: Text("Actions"), message: Text("Select an option"), buttons: [
						.default(Text("Retry")),
						.destructive(Text("Delete request")) {self.showInvite = false
							self.requestsVC.removeInvite(self.data)},
						.cancel()
					])
				} else {
					return ActionSheet(title: Text("Actions"), message: Text("Select an option"), buttons: [
						.destructive(Text("Remove access")) {self.showInvite = false
							self.requestsVC.removeInvite(self.data)},
						.cancel()
					])
				}
			}
			}
        }
    }
    
    
    func invitationState(_ state: String) -> AnyView {
        switch state {
        case "true":
            return AnyView(HStack {
                Image(systemName: "checkmark.seal.fill")
                Text("Approved")
            }.foregroundColor(Color(#colorLiteral(red: 0.2804591525, green: 0.8888034948, blue: 0.4827814814, alpha: 1))))
        case "pending":
            return AnyView(HStack {
                Image(systemName: "questionmark.diamond.fill")
                Text("Pending")
            }.foregroundColor(Color(#colorLiteral(red: 0.8888034948, green: 0.8503283456, blue: 0.205595538, alpha: 1))))
        case "false":
            return AnyView(HStack {
                Image(systemName: "xmark.seal.fill")
                Text("Denied")
            }.foregroundColor(Color(#colorLiteral(red: 0.8888034948, green: 0.078649739, blue: 0.04561639489, alpha: 1))))
        default:
            return AnyView(Text(""))
        }
    }
    
    
}
