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
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .bold()
                .padding(.top, 20)
            Spacer().frame(height: 20)
            
            if oneDev.userPeripheral.state == CBPeripheralState.connected {
                Text("Conectado")
                    .font(.subheadline)
                    .foregroundColor(.green.opacity(0.80))
                
                Button(action: startProcess) {
                    Text("Iniciar")
                        .padding()
                        .frame(width: 100.0, height: 50.0)
                        .foregroundColor(Color.white)
                        .background(Color.green)
                        .cornerRadius(10)
                }
                
                Button(action: stopProcess) {
                    Text("Parar")
                        .padding()
                        .frame(width: 100.0, height: 50.0)
                        .foregroundColor(Color.white)
                        .background(Color.red)
                        .cornerRadius(10)
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
    
    func startProcess(){
        let valueString: String = "start"
        let valueData = valueString.data(using: .utf8)

        print(valueString)
        for userService in bleViewModel.connectedUserBlePeripheral?.userServices ?? [] {
            for userChar in userService.userCharacteristices {
                oneDev.userPeripheral.writeValue(valueData!, for: userChar.characteristic, type: .withResponse)
            }
        }
    }
    
    func stopProcess(){
        let valueString: String = "stop"
        let valueData = valueString.data(using: .utf8)

        
        print(valueString)
        for userService in bleViewModel.connectedUserBlePeripheral?.userServices ?? [] {
            for userChar in userService.userCharacteristices {
                oneDev.userPeripheral.writeValue(valueData!, for: userChar.characteristic, type: .withResponse)
            }
        }
    }
    
    func goBack(){
        self.presentationMode.wrappedValue.dismiss()
        bleViewModel.centralManager?.cancelPeripheralConnection(oneDev.userPeripheral)
    }
}
