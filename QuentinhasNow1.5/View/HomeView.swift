//
//  ContentView.swift
//  BleFrame
//
//  Created by Kanydian Esteves on 29/04/23.
//

import SwiftUI

struct HomeView: View {

    @ObservedObject private var bluetoothViewModel = BleCommViewModel()
    
    var body: some View {
        NavigationStack {
            
            List {
                
                ForEach(bluetoothViewModel.foundPeripherals) { ele in
                    
                    NavigationLink(destination: DetailView(oneDev: ele, bleViewModel: bluetoothViewModel)) {
                        PeripheralCell(onePeri: ele)
                    }

                }
                
            }
            .navigationBarTitle("Dispositivos disponíveis")
        }
    }
}

struct PeripheralCell: View {
        
    @ObservedObject var onePeri: UserBlePeripheral
    var body: some View {
        
        LabeledContent {
            Text("\(onePeri.rssi) dBm")
          
        } label: {
            Text(onePeri.name)
            Text(String(onePeri.userPeripheral.identifier.uuidString.suffix(8)))
            
        }
            
    }
        
}

#Preview {
    HomeView()
}
