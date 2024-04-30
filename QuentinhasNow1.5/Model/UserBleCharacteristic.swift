//
//  UserBleCharacteristic.swift
//  BleFrame
//
//  Created by Kanydian Esteves on 29/04/23.
//

import CoreBluetooth

class UserBleCharacteristic: Identifiable, ObservableObject {
    @Published var id: UUID
    @Published var characteristic: CBCharacteristic
    @Published var uuid: CBUUID
    @Published var data: Data?
    
    init(_characteristic: CBCharacteristic,
         _uuid: CBUUID
         
    ) {
        
        id = UUID()
        characteristic = _characteristic
        uuid = _uuid
        
    }
    
}
