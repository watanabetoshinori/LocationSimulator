//
//  Device.swift
//  LocationSimulator
//
//  Created by Watanabe Toshinori on 6/14/18.
//  Copyright © 2018 Watanabe Toshinori. All rights reserved.
//

import Cocoa
import CoreLocation

class Device: NSObject {
    
    private var UDID = ""
    
    // MARK: - Find Connected Device
    
    class func findConnectedDevice() -> Device? {
        let output = Process.execute("idevice_id -l")

        if output.isEmpty == false {
            if let udid = output.components(separatedBy: CharacterSet.newlines).first {
                let device = Device(UDID: udid)
                return device
            }
        }
        
        return nil
    }
    
    // MARK: - Initializing Device
    
    convenience init(UDID: String) {
        self.init()
        self.UDID = UDID
    }
    
    // MARK: - Managing locations
    
    func simulateLocation(_ location: CLLocationCoordinate2D) {
        let lat = location.latitude
        let lng = location.longitude
        
        let output = Process.execute("idevicelocation \(lat) \(lng) -u \(UDID)")
        print(output)
    }
    
    func disableSimulation() {
        let output = Process.execute("idevicelocation -s -u \(UDID)")
        print(output)
    }

}
