//
//  DetailView.swift
//  BleFrame
//
//  Created by Kanydian Esteves on 29/04/23.
//

import SwiftUI

import CoreBluetooth

struct DetailView: View {
    
    @StateObject public var oneDev: UserBlePeripheral
    @StateObject public var bleViewModel: BleCommViewModel
    @State var connectionStatus: String = "Conectando ..."
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        NavigationStack{
            
            Text(oneDev.name)
            Spacer().frame(height: 20)
            
            if oneDev.userPeripheral.state == CBPeripheralState.connected {
                Text("Conectado")
                
                ForEach (bleViewModel.connectedUserBlePeripheral?.userServices ?? []) { item in
                    
                    GroupBox(
                        label:
                            VStack {
                                Text("Serviço: \(item.serviceName)")
                                Text("\(item.uuid.uuidString) \n").font(.subheadline)

                            }
                    ) {
                        
                        ForEach (item.userCharacteristices) { userChar in
                            
                            Divider().padding(.vertical, 2)
                            Text("Característica: ")
                            Text("\(userChar.uuid.uuidString) \n").font(.subheadline)
                        }

                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue, lineWidth: 1)
                    ).padding(.horizontal, 10)
                    
                }
            }
            else {
                
                Text("\(connectionStatus)")
                
                var count = 0
                let _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                    if (count >= 3) {
                        connectionStatus = "Não conectado"
                        timer.invalidate()
                    }
                    count += 1
                }
            }
            
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading:
                Button(action: goBack) {
                Text("Voltar")
                    .padding()
                    .frame(width: 80.0, height: 30.0)
                    .foregroundColor(Color.white)
                    .background(Color.purple)
                    .cornerRadius(8)
                }
        )
        .onAppear{
            bleViewModel.centralManager?.connect(oneDev.userPeripheral)
        }
        
    }
    
    func goBack(){
        self.presentationMode.wrappedValue.dismiss()
        bleViewModel.centralManager?.cancelPeripheralConnection(oneDev.userPeripheral)
    }

}
