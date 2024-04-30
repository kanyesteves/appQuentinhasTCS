//
//  UserBleService.swift
//  BleFrame
//
//  Created by Kanydian Esteves on 29/04/23.
//

import CoreBluetooth

class UserBleService: Identifiable, ObservableObject {
    
    var id: UUID
    var uuid: CBUUID
    var service: CBService
    var serviceName: String
    var userCharacteristices: [UserBleCharacteristic] = []

    init(_uuid: CBUUID,
         _service: CBService,
         _serviceName: String,
         _userCharacteristices: [UserBleCharacteristic]
    ) {
        
        id = UUID()
        uuid = _uuid
        service = _service
        serviceName = _serviceName
        userCharacteristices = _userCharacteristices
    }
}
