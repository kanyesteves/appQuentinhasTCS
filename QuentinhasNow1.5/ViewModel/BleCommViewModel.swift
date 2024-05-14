//
//  BleCommViewModel.swift
//  BleFrame
//
//  Created by Kanydian Esteves on 29/04/23.
//

import SwiftUI
import CoreBluetooth

class BleCommViewModel: NSObject, ObservableObject {
    @Published var centralManager: CBCentralManager?
    @Published var foundOnePeripheral: UserBlePeripheral!
    @Published var foundPeripherals: [UserBlePeripheral] = []
    @Published var connectedUserBlePeripheral: UserBlePeripheral?
    @Published var foundServiceName : String = " "
        
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: .main)
    }
}

extension BleCommViewModel: CBCentralManagerDelegate, CBPeripheralDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Passo 1")
        if(central.state == .poweredOn) {
            self.centralManager?.scanForPeripherals(withServices: nil)
            print("Passo 2")
        }
        
        switch central.state {
                
            case .poweredOff:
                print("Bluetooth Desligado")
                
            case .poweredOn:
                print("Bluetooth ligado, buscandos por Bluetooth BLE")
                self.centralManager?.scanForPeripherals(withServices: nil)
                
            case .unsupported:
                print("Sem suporte")
                
            case .unauthorized:
                print("Sem autorização")
                
            case .unknown:
                print("Desconhecido")
                
            case .resetting:
                print("Redefinindo")
                
            @unknown default:
                print("Erro")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        foundOnePeripheral = UserBlePeripheral (
            _userPeripheral: peripheral,
            _userServices: [],
            _name: peripheral.name ?? "Sem nome",
            _rssi: RSSI.intValue
            )

        if !IsInFoundPeripherals(foundOnePeripheral) {
            if peripheral.name != nil && foundOnePeripheral.name == "ESP32 LUCAS TCS" {
                print(foundOnePeripheral.name)
                foundPeripherals.append(foundOnePeripheral)
            }
        }
    }
    
    func IsInFoundPeripherals (_ onePeripheral: UserBlePeripheral) -> Bool {
        for item in foundPeripherals {
            
            if item.userPeripheral.identifier.uuidString == onePeripheral.userPeripheral.identifier.uuidString {
                return true
            }
        }
        return false
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {

        print("Dispositivo desconectado")
        resetConfigure()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Um dispositivo conectado")
        peripheral.delegate = self;
        
        connectedUserBlePeripheral = UserBlePeripheral(
            _userPeripheral: peripheral,
            _userServices: [],
            _name: peripheral.name ?? "Nenhum nome fornecido",
            _rssi: foundOnePeripheral.rssi
        )
        
        peripheral.discoverServices(nil)
        print("Buscando serviços")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        peripheral.services?.forEach { oneService in
            
            let serName = getServiceName(serviceDescription: oneService.description)
            print("Informações do serviço:\n \(oneService.description)")
            print("\nNome: \(serName)")
            
            foundServiceName = serName
            
            let foundOneService: UserBleService = UserBleService (
                                                    _uuid: oneService.uuid,
                                                    _service: oneService,
                                                    _serviceName: serName,
                                                    _userCharacteristices: []
                                                    )
            
            let oneUserBleService: UserBleService = UserBleService (
                _uuid: foundOneService.uuid,
                _service: foundOneService.service,
                _serviceName: serName,
                _userCharacteristices: []
            )
            connectedUserBlePeripheral?.userServices.append(oneUserBleService)
            
            print("Encontrado um serviço: \(foundOneService.uuid.uuidString)")
            peripheral.discoverCharacteristics(nil, for: foundOneService.service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        service.characteristics?.forEach { characteristic in
            peripheral.readValue(for: characteristic)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let value = characteristic.value {
            let foundOneUserChar : UserBleCharacteristic = UserBleCharacteristic(
                _characteristic: characteristic,
                _uuid: characteristic.uuid,
                _data: value
            )

            for item in connectedUserBlePeripheral?.userServices ?? [] {
                if item.uuid.uuidString == characteristic.service!.uuid.uuidString {
                    print("Achou uma característica: \(foundOneUserChar.uuid.uuidString)")
                    item.userCharacteristices.append(foundOneUserChar)
                }
            }
        }
    }
    
    func getServiceName(serviceDescription: String) -> String {
        let target = "UUID = "
        if let range = serviceDescription.range(of: target) {
            let uuidRange = range.upperBound..<serviceDescription.endIndex
            var serviceName = String(serviceDescription[uuidRange])
            
            if serviceName.hasSuffix(">") {
                serviceName.removeLast()
            }
            return serviceName;
        }
        else {
            return " "
        }
    }

    func resetConfigure() {
        withAnimation {
            connectedUserBlePeripheral = nil
        }
    }
}

