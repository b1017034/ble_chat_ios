//
//  BLEServiceViewController.swift
//  ble_test
//
//  Created by x on 2019/10/31.
//  Copyright © 2019 x. All rights reserved.
//

import UIKit
import CoreBluetooth

class BLEServiceViewController: UIViewController{

    var centralManager: CBCentralManager!
    var peripheralManager: CBPeripheralManager!
    
    var peripheral: CBPeripheral!
    var serviceUUID : CBUUID!
    var charcteristicUUID: CBUUID!
    let advertisementData = [CBAdvertisementDataLocalNameKey: "Test Device"]
    
    
    var deviceList: [String] = []
    
    @IBOutlet weak var start: UIButton!
    @IBAction func startScan(_ sender: Any) {
        print(#function)
        let services: [CBUUID] = [serviceUUID]
        centralManager?.scanForPeripherals(withServices: services,
                                           options: nil)
        
        peripheralManager.stopAdvertising()
    }
    override func viewDidLoad() {
        print(#function)
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        
        peripheralManager.startAdvertising(advertisementData)
        
        setupButton()
    }
    
    
    func setupButton(){
        print(#function)
        let scanningButton = UIButton()
        let center = self.view.center
        scanningButton.frame = CGRect(x: center.x - 50, y: center.y - 25, width: 100, height: 50)
        self.view.addSubview(scanningButton)
    }
    
    func startScan(){
        print(#function)
        let services: [CBUUID] = [serviceUUID]
        centralManager?.scanForPeripherals(withServices: services,
                                           options: nil)
        
        peripheralManager.stopAdvertising()
    }
    
    func stopScan(){
        if peripheralManager.state != .poweredOn {
            peripheralManager.startAdvertising(advertisementData)
        }
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
}

extension BLEServiceViewController: CBCentralManagerDelegate{
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print ("state: \(central.state)")
        switch central.state {
            
        default:
            break
        }
    }
    
    /// ペリフェラルを発見すると呼ばれる
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        
        //central.connect(peripheral, options: nil)
    }
    
    
    //　ペリフェラルに接続すると呼ばれる
    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        
        peripheral.discoverServices([serviceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {}

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {}
}

extension BLEServiceViewController: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
         guard let services = peripheral.services, !services.isEmpty else { return }
         for service in services {
             if service.uuid == serviceUUID {
                 peripheral.discoverCharacteristics(nil, for: service)
             }
         }
     }

     func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
         guard let characteristics = service.characteristics, !characteristics.isEmpty else { return }
         for characteristic in characteristics {
            print("\(characteristics.count)個のキャラクタリスティックを発見。\(characteristics)")
            if characteristic.uuid == charcteristicUUID {
                 // 通知を有効にします
                 peripheral.setNotifyValue(true, for: characteristic)
             }
         }
     }

     func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
     }

     func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
         guard let data = characteristic.value else {
             return
         }
         if characteristic.uuid == charcteristicUUID {
            print(data)
         }
     }

     func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
     }

     func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
     }
}


extension BLEServiceViewController: CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
            print("periState\(peripheral.state)")
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
            if let error = error {
                print("***Advertising ERROR")
                print(error)
                return
            }
            print("Advertising success")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        print( "Add: \(service.description)")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("Subscription: \(central.description)")
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        print("Unsubscription")
    }

    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        print("IsReady")
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        print("Receive read: \(request.description)")
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any]) {
        print("Restore State: \(dict)")
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) { }
}
