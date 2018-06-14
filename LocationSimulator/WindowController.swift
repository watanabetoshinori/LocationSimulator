//
//  WindowController.swift
//  LocationSimulator
//
//  Created by Watanabe Toshinori on 6/11/18.
//  Copyright © 2018 Watanabe Toshinori. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {

    @IBOutlet weak var currentLocationButton: NSButton!
    
    @IBOutlet weak var typeSegmented: NSSegmentedControl!

    private var autoFocusCurrentLocationNotification: Any?

    // MARK: - Window lifecycle

    override func windowDidLoad() {
        super.windowDidLoad()

        autoFocusCurrentLocationNotification = NotificationCenter.default.addObserver(forName: .AutoFoucusCurrentLocationDidChanged, object: nil, queue: .main) { (notification) in
            if let isOn = notification.object as? Bool, isOn == true {
                self.currentLocationButton.state = .on
            } else {
                self.currentLocationButton.state = .off
            }
        }
        
        if Process.isExists("idevice_id") == false {
            let alert = NSAlert()
            alert.messageText = "Library not found"
            alert.informativeText = "The libimobiledevice library not found.\nPlease install the library via following command:\n\nbrew install libimobiledevice"
            alert.alertStyle = .critical
            alert.runModal()
            exit(0)
            
        } else {
            if Process.isExists("idevicelocation") == false {
                let alert = NSAlert()
                alert.messageText = "Library not found"
                alert.informativeText = "The idevicelocation library not found.\nPlease install the library from github repository.\n\nhttps://github.com/JonGabilondoAngulo/idevicelocation"
                alert.addButton(withTitle: "OK")
                alert.alertStyle = .critical
                alert.runModal()
                exit(0)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(autoFocusCurrentLocationNotification!)
    }

    // MARK: - Actions

    @IBAction func currentLocationDidClicked(_ sender: NSButton) {
        guard let viewController = contentViewController as? ViewController else {
            return
        }

        if viewController.currentLocation == nil {
            sender.state = .off
            return
        }

        viewController.isAutoFocusCurrentLocation = (sender.state == .on)
    }
    
    @IBAction func typeSegmentDidChanged(_ sender: NSSegmentedControl) {
        guard let viewController = contentViewController as? ViewController else {
            return
        }
        
        viewController.moveType = ViewController.MoveType(rawValue: sender.selectedSegment)!
    }
    
    @IBAction func resetDidClicked(_ sender: NSButton) {
        guard let viewController = contentViewController as? ViewController else {
            return
        }

        viewController.disableSimulation()
    }

}
