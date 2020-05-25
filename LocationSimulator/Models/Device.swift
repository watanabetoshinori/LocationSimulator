//
//  Device.swift
//  LocationSimulator
//
//  Created by Watanabe Toshinori on 2020/05/24.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import Cocoa
import CoreLocation

class Device: NSObject {

    private var UDID = ""

    // MARK: - Find Connected Device

    class func find() -> Device? {
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

    func simulate(location: CLLocationCoordinate2D) {
        let lat = location.latitude
        let lng = location.longitude

        var command = "idevicelocation -u \(UDID)"

        switch (lat, lng) {
        case (..<0, ..<0):
            command += " -- \(lat) -- \(lng)"
        case (..<0, 0...):
            command += " -- \(lat) \(lng)"
        case (0..., ..<0):
            command += " \(lat) -- \(lng)"
        default:
            command += " \(lat) \(lng)"
        }

        let output = Process.execute(command)
        print(output)
    }

    func reset() {
        let output = Process.execute("idevicelocation -s -u \(UDID)")
        print(output)
    }

}
