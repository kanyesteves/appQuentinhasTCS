//
//  UserBlePeripheral.swift
//  BleFrame
//
//  Created by Kanydian Esteves on 29/04/23.
//

import CoreBluetooth

class UserBlePeripheral: Identifiable, ObservableObject {
    
    @Published var id: UUID
    @Published var userPeripheral: CBPeripheral
    @Published var userServices: [UserBleService]
    @Published var name: String
    @Published var rssi: Int
    
    init(_userPeripheral: CBPeripheral,
         _userServices: [UserBleService],
         _name: String,
         _rssi: Int
         )
    {
        id = UUID()
        userServices = _userServices
        userPeripheral = _userPeripheral
        name = _name
        rssi = _rssi

    }
    
}
